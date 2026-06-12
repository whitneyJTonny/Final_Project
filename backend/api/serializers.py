from rest_framework import serializers
from django.contrib.auth.models import User
from django.contrib.auth.password_validation import validate_password


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name')


class RegisterSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(required=True)
    password = serializers.CharField(
        write_only=True,
        required=True,
        validators=[validate_password],
    )
    first_name = serializers.CharField(required=True)
    phone = serializers.CharField(write_only=True, required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ('username', 'email', 'password', 'first_name', 'phone')
        extra_kwargs = {'username': {'required': False}}

    def validate_email(self, value):
        value = value.strip().lower()
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError(
                "This email is already registered. Please log in instead."
            )
        return value

    def validate_first_name(self, value):
        if len(value.strip()) < 2:
            raise serializers.ValidationError(
                "Please enter your full name (at least 2 characters)."
            )
        return value.strip()

    def create(self, validated_data):
        email = validated_data['email'].strip().lower()
        phone = validated_data.pop('phone', '')

        user = User.objects.create_user(
            username=email,
            email=email,
            password=validated_data['password'],
            first_name=validated_data['first_name'],
        )

        from .models import UserProfile
        UserProfile.objects.get_or_create(user=user, defaults={'phone_number': phone})

        return user