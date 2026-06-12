import os
import datetime
import resend
import random

from django.core.mail import send_mail
from django.contrib.auth.models import User
from django.conf import settings
from django.utils import timezone

from rest_framework import generics, permissions, status
from rest_framework.views import APIView
from rest_framework.response import Response

from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import RegisterSerializer, UserSerializer
from .models import PasswordResetOTP


# =========================
# REGISTER
# =========================
class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        refresh = RefreshToken.for_user(user)

        return Response({
            "user": UserSerializer(user).data,
            "tokens": {
                "refresh": str(refresh),
                "access": str(refresh.access_token),
            }
        }, status=status.HTTP_201_CREATED)


# =========================
# PROFILE
# =========================
class UserProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = UserSerializer
    permission_classes = (permissions.IsAuthenticated,)

    def get_object(self):
        return self.request.user


# =========================
# FORGOT PASSWORD (OTP)
# =========================
class ForgotPasswordView(APIView):
    permission_classes = (permissions.AllowAny,)

    def post(self, request):
        email = request.data.get("email", "").strip().lower()

        if not email:
            return Response(
                {"success": False, "error": "Email is required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = User.objects.filter(email__iexact=email).first()

        # Always return success (security reason)
        if user:
            PasswordResetOTP.objects.filter(email__iexact=email).delete()

            # ✅ GUARANTEED 6-DIGIT OTP
            otp = f"{random.randint(0, 999999):06d}"

            PasswordResetOTP.objects.create(email=email, otp=otp)

            print("==========================================")
            print(f"OTP FOR {email}: {otp}")
            print("==========================================")

            email_sent = False

            # ================= SMTP EMAIL =================
            try:
                send_mail(
                    subject="Solar M7 — Your Password Reset OTP",
                    message=(
                        f"Hi {user.first_name or 'User'},\n\n"
                        f"Your OTP is: {otp}\n\n"
                        f"It expires in 5 minutes.\n\n"
                        f"If you didn't request this, ignore this email."
                    ),
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[email],
                    fail_silently=False,
                )
                print("[SMTP] OTP sent successfully")
                email_sent = True

            except Exception as e:
                print(f"[SMTP ERROR] {e}")

            # ================= RESEND FALLBACK =================
            if not email_sent:
                try:
                    resend.api_key = os.getenv("RESEND_API_KEY")

                    resend.Emails.send({
                        "from": "Solar M7 <onboarding@resend.dev>",
                        "to": [email],
                        "subject": "Solar M7 — Your OTP Code",
                        "text": f"Your OTP is {otp}. It expires in 5 minutes."
                    })

                    print("[RESEND] OTP sent successfully")

                except Exception as e:
                    print(f"[RESEND ERROR] {e}")

        return Response(
            {"success": True, "message": "If the email exists, an OTP has been sent."},
            status=status.HTTP_200_OK
        )


# =========================
# VERIFY OTP
# =========================
class VerifyOTPView(APIView):
    permission_classes = (permissions.AllowAny,)

    def post(self, request):
        email = request.data.get("email", "").strip().lower()
        otp = request.data.get("otp", "").strip()

        if not email or not otp:
            return Response(
                {"success": False, "error": "Email and OTP required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        record = PasswordResetOTP.objects.filter(email__iexact=email, otp=otp).first()

        if not record:
            return Response(
                {"success": False, "error": "Invalid OTP."},
                status=status.HTTP_400_BAD_REQUEST
            )

        expiry_seconds = getattr(settings, "OTP_EXPIRY_SECONDS", 300)

        if timezone.now() - record.created_at > datetime.timedelta(seconds=expiry_seconds):
            record.delete()
            return Response(
                {"success": False, "error": "OTP expired."},
                status=status.HTTP_400_BAD_REQUEST
            )

        return Response({"success": True, "message": "OTP verified"})


# =========================
# RESET PASSWORD
# =========================
class ResetPasswordView(APIView):
    permission_classes = (permissions.AllowAny,)

    def post(self, request):
        email = request.data.get("email", "").strip().lower()
        otp = request.data.get("otp", "").strip()
        password = request.data.get("password", "")

        if not email or not otp or not password:
            return Response(
                {"success": False, "error": "All fields required."},
                status=status.HTTP_400_BAD_REQUEST
            )

        if len(password) < 6:
            return Response(
                {"success": False, "error": "Password too short."},
                status=status.HTTP_400_BAD_REQUEST
            )

        record = PasswordResetOTP.objects.filter(email__iexact=email, otp=otp).first()

        if not record:
            return Response(
                {"success": False, "error": "Invalid OTP."},
                status=status.HTTP_400_BAD_REQUEST
            )

        user = User.objects.filter(email__iexact=email).first()

        if not user:
            return Response(
                {"success": False, "error": "User not found."},
                status=status.HTTP_404_NOT_FOUND
            )

        user.set_password(password)
        user.save()

        record.delete()

        return Response(
            {"success": True, "message": "Password reset successful."},
            status=status.HTTP_200_OK
        )