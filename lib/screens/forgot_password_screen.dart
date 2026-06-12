import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // ── Controllers ──────────────────────────────────────────────────────────
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 6 separate OTP digit controllers
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  // ── State ────────────────────────────────────────────────────────────────
  int _step = 1; // 1=Email, 2=OTP+Password, 3=Success
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  // Countdown timer for OTP resend
  int _resendCountdown = 60;
  Timer? _resendTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String get _enteredOtp =>
      _otpControllers.map((c) => c.text).join();

  void _showSnack(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            isError ? AppColors.warningRed : AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _startResendTimer() {
    _resendCountdown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          t.cancel();
        }
      });
    });
  }

  // ── Step 1: Send OTP ─────────────────────────────────────────────────────
  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack('Please enter your email address.');
      return;
    }
    if (!RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-z]{2,}$').hasMatch(email)) {
      _showSnack('Please enter a valid email address.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().forgotPassword(email);
      if (mounted) {
        // Clear any old OTP boxes
        for (final c in _otpControllers) {
          c.clear();
        }
        setState(() => _step = 2);
        _startResendTimer();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) _otpFocusNodes[0].requestFocus();
        });
        _showSnack('OTP sent to $email', isError: false);
      }
    } catch (e) {
      _showSnack(_cleanError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Resend OTP ────────────────────────────────────────────────────────────
  Future<void> _handleResendOtp() async {
    if (_resendCountdown > 0) return;
    setState(() => _isLoading = true);
    try {
      await AuthService().forgotPassword(_emailController.text.trim());
      if (mounted) {
        for (final c in _otpControllers) {
          c.clear();
        }
        _startResendTimer();
        _showSnack('New OTP sent!', isError: false);
        Future.delayed(
            const Duration(milliseconds: 100),
            () => _otpFocusNodes[0].requestFocus());
      }
    } catch (e) {
      _showSnack(_cleanError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Step 2: Verify OTP + Reset Password ──────────────────────────────────
  Future<void> _handleResetPassword() async {
    final otp = _enteredOtp;
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (otp.length != 6) {
      _showSnack('Please enter the complete 6-digit OTP.');
      return;
    }
    if (password.length < 6) {
      _showSnack('Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      _showSnack('Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().resetPassword(
        _emailController.text.trim(),
        otp,
        password,
      );
      if (mounted) {
        _resendTimer?.cancel();
        setState(() => _step = 3);
      }
    } catch (e) {
      _showSnack(_cleanError(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _cleanError(Object e) {
    String s = e.toString();
    if (s.startsWith('Exception: ')) s = s.replaceFirst('Exception: ', '');
    return s;
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.primaryDark, size: 20),
          onPressed: () {
            if (_step == 2) {
              _resendTimer?.cancel();
              setState(() => _step = 1);
            } else if (_step == 1) {
              Navigator.pop(context);
            }
            // Step 3: no back
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 10, 28, 40),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position:
                    Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
                        .animate(anim),
                child: child,
              ),
            ),
            child: _step == 1
                ? _buildStep1(key: const ValueKey(1))
                : _step == 2
                    ? _buildStep2(key: const ValueKey(2))
                    : _buildStep3(key: const ValueKey(3)),
          ),
        ),
      ),
    );
  }

  // ── STEP 1: Enter Email ───────────────────────────────────────────────────
  Widget _buildStep1({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // Icon badge
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.lock_reset_rounded,
              color: AppColors.primaryYellow, size: 36),
        ),
        const SizedBox(height: 28),
        Text(
          'Forgot Password?',
          style: GoogleFonts.archivo(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enter your registered email and we\'ll send a 6-digit OTP to reset your password.',
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),

        // Email field
        _buildLabel('Email Address'),
        const SizedBox(height: 8),
        _buildInputBox(
          controller: _emailController,
          hint: 'you@example.com',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 36),

        // Send OTP button
        _buildPrimaryButton(
          label: 'Send OTP',
          icon: Icons.send_rounded,
          onPressed: _handleSendOtp,
        ),
      ],
    );
  }

  // ── STEP 2: OTP boxes + New Password ─────────────────────────────────────
  Widget _buildStep2({Key? key}) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.verified_user_rounded,
              color: AppColors.primaryYellow, size: 36),
        ),
        const SizedBox(height: 28),
        Text(
          'Enter OTP',
          style: GoogleFonts.archivo(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          text: TextSpan(
            style: const TextStyle(
                fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            children: [
              const TextSpan(text: 'We sent a 6-digit code to '),
              TextSpan(
                text: _emailController.text.trim(),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: AppColors.primaryDark),
              ),
            ],
          ),
        ),
        const SizedBox(height: 36),

        // ── 6 OTP boxes ───────────────────────────────────────────────────
        _buildLabel('One-Time Password'),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (i) => _buildOtpBox(i)),
        ),

        // Resend
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _resendCountdown > 0
                  ? 'Resend in ${_resendCountdown}s'
                  : '',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            if (_resendCountdown == 0)
              GestureDetector(
                onTap: _isLoading ? null : _handleResendOtp,
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondaryOrange,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 30),
        const Divider(color: Color(0xFFEEE8DC)),
        const SizedBox(height: 24),

        // New Password
        _buildLabel('New Password'),
        const SizedBox(height: 8),
        _buildInputBox(
          controller: _passwordController,
          hint: 'At least 6 characters',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 20),

        // Confirm Password
        _buildLabel('Confirm New Password'),
        const SizedBox(height: 8),
        _buildInputBox(
          controller: _confirmPasswordController,
          hint: 'Repeat your password',
          icon: Icons.lock_outline_rounded,
          obscureText: _obscureConfirm,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirm
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
            onPressed: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ),
        const SizedBox(height: 36),

        _buildPrimaryButton(
          label: 'Reset Password',
          icon: Icons.check_circle_outline_rounded,
          onPressed: _handleResetPassword,
        ),
      ],
    );
  }

  // ── STEP 3: Success ───────────────────────────────────────────────────────
  Widget _buildStep3({Key? key}) {
    return Column(
      key: key,
      children: [
        const SizedBox(height: 60),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppColors.successGreen, size: 60),
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Password Reset!',
          style: GoogleFonts.archivo(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        const Text(
          'Your password has been successfully updated.\nYou can now log in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: AppColors.primaryYellow,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text(
              'Back to Login',
              style: GoogleFonts.archivo(
                  fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }

  // ── OTP Single Box ────────────────────────────────────────────────────────
  Widget _buildOtpBox(int index) {
    return SizedBox(
      width: 46,
      height: 56,
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: GoogleFonts.archivo(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: AppColors.primaryDark,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0D8C8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE0D8C8), width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
                const BorderSide(color: AppColors.primaryYellow, width: 2.5),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (val) {
          if (val.length == 1 && index < 5) {
            // Move to next box
            _otpFocusNodes[index + 1].requestFocus();
          } else if (val.isEmpty && index > 0) {
            // Move back on delete
            _otpFocusNodes[index - 1].requestFocus();
          }
          // Auto submit check
          if (_enteredOtp.length == 6) {
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }

  // ── Shared Widgets ────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildInputBox({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0D8C8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
            color: AppColors.primaryDark, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.primaryYellow,
          disabledBackgroundColor: AppColors.primaryDark.withValues(alpha: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.primaryYellow,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.archivo(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 18),
                ],
              ),
      ),
    );
  }
}
