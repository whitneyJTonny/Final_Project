import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_colors.dart';
import 'monitoring_screen.dart';

class FundKitScreen extends StatefulWidget {
  const FundKitScreen({super.key});

  @override
  State<FundKitScreen> createState() => _FundKitScreenState();
}

class _FundKitScreenState extends State<FundKitScreen> {
  final List<Map<String, dynamic>> _impactLevels = [
    {
      "amount": "230,000",
      "impact": "Powers 1 Home",
      "price": 230000,
      "icon": Icons.home_outlined,
    },
    {
      "amount": "1,150,000",
      "impact": "Powers 5 Homes",
      "price": 1150000,
      "icon": Icons.group_outlined,
    },
    {
      "amount": "2,300,000",
      "impact": "Powers 10 Homes",
      "price": 2300000,
      "icon": Icons.wb_sunny_outlined,
    },
  ];

  int _selectedLevelIndex = 0;
  String _selectedPayment = "MTN";
  String? _errorText;
  String? _detectedNetwork; // What network we think the number belongs to

  final TextEditingController _phoneController = TextEditingController();

  // Uganda network prefixes (9-digit local numbers)
  static const List<String> _mtnPrefixes = ['076', '077', '078', '039', '031'];
  static const List<String> _airtelPrefixes = ['070', '074', '075', '073'];

  /// Cleans the number: removes spaces, dashes, +256, 256, leading 0
  /// Returns the 9-digit local number e.g. "0771234567" → "771234567"
  String _cleanNumber(String raw) {
    String n = raw.replaceAll(RegExp(r'[\s\-]'), '');
    if (n.startsWith('+256'))
      n = n.substring(4);
    else if (n.startsWith('256'))
      n = n.substring(3);
    // Now should start with 0 or digit
    return n;
  }

  /// Returns "MTN", "Airtel", or null if unknown
  String? _detectNetwork(String cleaned) {
    if (cleaned.length < 3) return null;
    final prefix = cleaned.startsWith('0')
        ? cleaned.substring(0, 3) // e.g. "077"
        : '0${cleaned.substring(0, 2)}'; // e.g. "77" → "077"

    if (_mtnPrefixes.contains(prefix)) return "MTN";
    if (_airtelPrefixes.contains(prefix)) return "Airtel";
    return null;
  }

  /// Full validation — returns error string or null if valid
  String? _validate(String raw) {
    final cleaned = _cleanNumber(raw);

    if (cleaned.isEmpty) return "Please enter a phone number.";

    // Strip leading zero for length check
    final digits = cleaned.startsWith('0') ? cleaned.substring(1) : cleaned;
    if (digits.length < 9)
      return "Number is too short. Enter a 9-digit number.";
    if (digits.length > 9) return "Number is too long.";

    final detected = _detectNetwork(cleaned);

    if (detected == null) {
      return "Unrecognized number. Check the number and try again.";
    }

    if (_selectedPayment == "MTN" && detected == "Airtel") {
      return "This is an Airtel number (${cleaned.substring(0, cleaned.startsWith('0') ? 3 : 2)}x). "
          "Switch to Airtel Money or enter an MTN number.";
    }

    if (_selectedPayment == "Airtel" && detected == "MTN") {
      return "This is an MTN number (${cleaned.substring(0, cleaned.startsWith('0') ? 3 : 2)}x). "
          "Switch to MTN MoMo or enter an Airtel number.";
    }

    return null; // ✅ All good
  }

  /// Called on every keystroke — live feedback
  void _onNumberChanged(String value) {
    final cleaned = _cleanNumber(value);
    final detected = _detectNetwork(cleaned);

    setState(() {
      _detectedNetwork = detected;

      // Only show error once they've typed enough digits
      final digits = cleaned.startsWith('0') ? cleaned.substring(1) : cleaned;
      if (digits.length >= 9) {
        _errorText = _validate(value);
      } else if (digits.length > 3) {
        // Soft early warning if network mismatch is already clear
        if (detected != null &&
            detected != _selectedPayment &&
            _selectedPayment != "Card") {
          _errorText =
              "Looks like an $detected number. Switch payment method or enter a ${_selectedPayment == 'MTN' ? 'MTN' : 'Airtel'} number.";
        } else {
          _errorText = null;
        }
      } else {
        _errorText = null;
      }
    });
  }

  Future<void> _showCardPaymentMock() async {
    final amount = _impactLevels[_selectedLevelIndex]['amount'] as String;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildProcessingDialog(
        "Connecting to secure payment gateway...\nPlease wait.",
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context); // close spinner

    // Save kit to database
    try {
      final box = Hive.box('offline_kits');
      final newKitId = 'KIT-${100000 + Random().nextInt(900000)}';
      final dateStr = DateTime.now().toString().split(' ')[0];
      final level = _impactLevels[_selectedLevelIndex];
      final impactStr = level['impact'] as String;
      
      await box.put(newKitId, {
        'kitId': newKitId,
        'date': dateStr,
        'amount': 'Ush. $amount',
        'impact': impactStr,
        'status': 'PROCESSING',
      });
    } catch (e) {
      debugPrint("Error: $e");
    }

    _showSlidingNotification(
      sender: "Solar M7",
      message: "Payment of Ush. $amount processed via Card. Thank you!",
      isSuccess: true,
    );

    _showSuccessDialog();
  }

  void _showUSSDPromptDialog({
    required String networkName,
    required String amount,
    required String phone,
  }) {
    final TextEditingController pinController = TextEditingController();
    final isAirtel = _selectedPayment == 'Airtel';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isAirtel ? Colors.red : const Color(0xFFFFD54F),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isAirtel ? "Airtel Money" : "MTN MoMo",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  "Authorize payment of Ush. $amount to Solar M7.",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Enter Mobile Money PIN:",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pinController,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 5,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: isDark ? Colors.white12 : Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Transaction cancelled by user."),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Text(
                        "CANCEL",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        final pin = pinController.text.trim();
                        if (pin.length < 4) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter a valid 4 or 5-digit PIN."),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        _processPaymentOutcome(amount, phone);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAirtel ? Colors.red : const Color(0xFFFFC107),
                        foregroundColor: isAirtel ? Colors.white : Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "SEND",
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _processPaymentOutcome(String amount, String phone) async {
    final networkName = _selectedPayment == 'MTN' ? 'MTN Mobile Money' : 'Airtel Money';
    
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.15),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (ctx, _, __) => _buildProcessingDialog("Processing transaction...\nPlease wait."),
    );
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    Navigator.pop(context); // close processing dialog

    final bool isAirtel = _selectedPayment == 'Airtel';
    final bool hasInsufficientFunds = isAirtel && phone.trim().endsWith('0');

    if (hasInsufficientFunds) {
      _showSlidingNotification(
        sender: "Airtel Money",
        message: "Airtel Money: Transaction failed. Insufficient funds to pay Ush. $amount to Solar M7. Your balance is Ush. 1,500. Please deposit and try again.",
        isSuccess: false,
      );
      _showInsufficientFundsDialog(networkName);
    } else {
      try {
        final box = Hive.box('offline_kits');
        final newKitId = 'KIT-${100000 + Random().nextInt(900000)}';
        final dateStr = DateTime.now().toString().split(' ')[0];
        final level = _impactLevels[_selectedLevelIndex];
        final impactStr = level['impact'] as String;
        
        await box.put(newKitId, {
          'kitId': newKitId,
          'date': dateStr,
          'amount': 'Ush. $amount',
          'impact': impactStr,
          'status': 'PROCESSING',
        });
      } catch (e) {
        debugPrint("Error: $e");
      }

      _showSlidingNotification(
        sender: _selectedPayment == 'MTN' ? "MTN MoMo" : "Airtel Money",
        message: _selectedPayment == 'MTN'
            ? "MTN MoMo: You have authorized payment of Ush. $amount to Solar M7. Ref: Solar-MoMo-${100000 + Random().nextInt(900000)}."
            : "Airtel Money: Payment of Ush. $amount to Solar M7 completed successfully. Ref: Solar-AM-${100000 + Random().nextInt(900000)}.",
        isSuccess: true,
      );

      _showSuccessDialog();
    }
  }

  void _showSlidingNotification({
    required String sender,
    required String message,
    required bool isSuccess,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Notification",
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogCtx, anim1, anim2) {
        Future.delayed(const Duration(seconds: 5), () {
          if (dialogCtx.mounted) {
            Navigator.of(dialogCtx).pop();
          }
        });

        return Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 50, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSuccess
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSuccess ? Icons.sms_rounded : Icons.sms_failed_rounded,
                      color: isSuccess ? Colors.green : Colors.red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              sender,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            Text(
                              "now",
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white38 : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black54,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(
            CurvedAnimation(
              parent: anim1,
              curve: Curves.easeOutBack,
            ),
          ),
          child: child,
        );
      },
    );
  }

  Future<void> _startPayment() async {
    if (_selectedPayment == "Card") {
      _showCardPaymentMock();
      return;
    }

    final error = _validate(_phoneController.text);
    if (error != null) {
      setState(() => _errorText = error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(error, style: const TextStyle(fontSize: 13)),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    final networkName =
        _selectedPayment == 'MTN' ? 'MTN Mobile Money' : 'Airtel Money';
    final number = _phoneController.text.trim();
    final amount = _impactLevels[_selectedLevelIndex]['amount'] as String;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _buildProcessingDialog(
        "Connecting to $networkName...\nPlease wait.",
      ),
    );
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.pop(context); // close spinner

    _showUSSDPromptDialog(
      networkName: networkName,
      amount: amount,
      phone: number,
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildSuccessDialog(),
    );
  }

  void _showInsufficientFundsDialog(String networkName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mobile_off_rounded,
                    color: Colors.red.shade600, size: 44),
              ),
              const SizedBox(height: 16),
              Text(
                "$networkName\nInsufficient Balance",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "You do not have enough funds in your $networkName account to complete this transaction.\n\nPlease deposit funds and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Dial *165# to deposit or visit your nearest ${_selectedPayment == 'Airtel' ? 'Airtel' : 'MTN'} agent.",
                        style: TextStyle(fontSize: 12, color: Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        // Let user try again
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Try Again",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Network badge shown next to the input field
  Widget _buildNetworkBadge() {
    if (_detectedNetwork == null) return const SizedBox.shrink();
    final isMismatch = _detectedNetwork != _selectedPayment;
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isMismatch ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMismatch ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMismatch
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            size: 14,
            color: isMismatch ? Colors.red.shade700 : Colors.green.shade700,
          ),
          const SizedBox(width: 5),
          Text(
            isMismatch
                ? "Detected: $_detectedNetwork number"
                : "✓ $_detectedNetwork number confirmed",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isMismatch ? Colors.red.shade700 : Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedAmount = _impactLevels[_selectedLevelIndex]['amount'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Fund a Solar Kit",
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // --- SELECT IMPACT LEVEL ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Select Impact Level",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 10),

            ...List.generate(_impactLevels.length, (index) {
              final level = _impactLevels[index];
              final isSelected = _selectedLevelIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedLevelIndex = index),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 6,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryYellow.withOpacity(0.08)
                        : Colors.grey[50],
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryYellow
                          : Colors.grey.shade200,
                      width: isSelected ? 1.8 : 1,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryYellow.withOpacity(0.15)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          level['icon'] as IconData,
                          color: isSelected
                              ? AppColors.primaryYellow
                              : Colors.grey,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ush. ${level['amount']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              level['impact'],
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryYellow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        )
                      else
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 28),

            // --- CHOOSE PAYMENT OPTION ---
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Choose Payment Option",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPayment = "MTN";
                          _errorText = null;
                          _detectedNetwork = null;
                          _phoneController.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _selectedPayment == "MTN"
                              ? AppColors.secondaryOrange
                              : Colors.transparent,
                          border: Border.all(
                            color: _selectedPayment == "MTN"
                                ? AppColors.secondaryOrange
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.phone_android,
                              color: _selectedPayment == "MTN"
                                  ? Colors.white
                                  : Colors.grey,
                              size: 22,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "MTN MoMo",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: _selectedPayment == "MTN"
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPayment = "Airtel";
                          _errorText = null;
                          _detectedNetwork = null;
                          _phoneController.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _selectedPayment == "Airtel"
                              ? AppColors.secondaryOrange
                              : Colors.transparent,
                          border: Border.all(
                            color: _selectedPayment == "Airtel"
                                ? AppColors.secondaryOrange
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.sim_card_outlined,
                              color: _selectedPayment == "Airtel"
                                  ? Colors.white
                                  : Colors.grey,
                              size: 22,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              "Airtel",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: _selectedPayment == "Airtel"
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPayment = "Card";
                    _errorText = null;
                    _detectedNetwork = null;
                    _phoneController.clear();
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: _selectedPayment == "Card"
                        ? AppColors.secondaryOrange
                        : Colors.transparent,
                    border: Border.all(
                      color: _selectedPayment == "Card"
                          ? AppColors.secondaryOrange
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: _selectedPayment == "Card"
                            ? Colors.white
                            : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Pay via PESAPAL / VISA / CARD",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: _selectedPayment == "Card"
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- ACCOUNT NUMBER INPUT ---
            if (_selectedPayment != "Card")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_selectedPayment == 'MTN' ? 'MTN' : 'Airtel'} Account Number",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _errorText != null
                              ? Colors.red.shade400
                              : (_detectedNetwork == _selectedPayment &&
                                    _detectedNetwork != null)
                              ? Colors.green.shade400
                              : Colors.grey.shade300,
                          width: _errorText != null ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Uganda flag + prefix
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: SizedBox(
                                    width: 24,
                                    height: 16,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Container(color: Colors.black),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: const Color(0xFFFFD700),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: const Color(0xFFD21034),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(color: Colors.black),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: const Color(0xFFFFD700),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            color: const Color(0xFFD21034),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "+256",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              onChanged: _onNumberChanged,
                              decoration: InputDecoration(
                                hintText: _selectedPayment == "MTN"
                                    ? "077 000 0000"
                                    : "070 000 0000",
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                counterText: "", // hide maxLength counter
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                // Inline suffix icon
                                suffixIcon: _detectedNetwork != null
                                    ? Icon(
                                        _detectedNetwork == _selectedPayment
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color:
                                            _detectedNetwork == _selectedPayment
                                            ? Colors.green
                                            : Colors.red,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Live network detection badge
                    _buildNetworkBadge(),

                    // Error text
                    if (_errorText != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 13,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _errorText!,
                              style: TextStyle(
                                color: Colors.red.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // --- FUND A KIT BUTTON ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _startPayment,
                  icon: const Icon(Icons.favorite_border, size: 20),
                  label: Text(
                    "FUND A KIT  •  Ush. $selectedAmount",
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryYellow,
                    foregroundColor: AppColors.primaryDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- DIALOGS ---

  Widget _buildProcessingDialog(String message) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryYellow),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  // Phone prompt dialog replaced by interactive USSD PIN dialog

  Widget _buildSuccessDialog() {
    final amount = _impactLevels[_selectedLevelIndex]['amount'];
    final impact = _impactLevels[_selectedLevelIndex]['impact'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.successGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppColors.successGreen,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Funding Successful! 🎉",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "Thank you! Your Ush. $amount contribution will $impact with clean solar energy.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const MonitoringScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                  foregroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Finish & Track",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated waiting dots shown in the phone-prompt dialog ───────────────────
class _WaitingDots extends StatefulWidget {
  const _WaitingDots();

  @override
  State<_WaitingDots> createState() => _WaitingDotsState();
}

class _WaitingDotsState extends State<_WaitingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final t = _ctrl.value;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            // Each dot pulses with a phase offset
            final phase = (t + i * 0.33) % 1.0;
            final scale = 0.6 + 0.4 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.primaryYellow,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
