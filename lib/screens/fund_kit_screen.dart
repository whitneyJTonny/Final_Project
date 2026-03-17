import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FundKitScreen extends StatefulWidget {
  const FundKitScreen({super.key});

  @override
  State<FundKitScreen> createState() => _FundKitScreenState();
}

class _FundKitScreenState extends State<FundKitScreen> {
  // Form Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  int selectedAmount = 50;
  String selectedPayment = 'momo';
  bool isProcessing = false;

  // Preset amounts like a real donation site
  final List<int> amounts = [25, 50, 100, 250, 500];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _processDonation() {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in donor details"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isProcessing = true);

    // Simulate processing
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // ✅ FIXED: Added mounted check

      setState(() => isProcessing = false);

      // Create the new kit data
      final newKit = {
        "id": DateTime.now().millisecondsSinceEpoch.toString(),
        "name": "Solar Kit #${DateTime.now().day}${DateTime.now().month}",
        "donor": _nameController.text,
        "amount": selectedAmount,
        "status": "Active",
        "date": DateTime.now().toString().substring(0, 10),
        "location": "Uganda",
        "battery": 100,
      };

      // Navigate back to Home and pass the new kit data
      Navigator.pop(context, newKit);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Donate to a Project",
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryDark),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image Area
            Container(
              width: double.infinity,
              height: 200,
              color: AppColors.primaryDark,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: const NetworkImage(
                          "https://solarm7.com/assets/images/solar-panel.jpg",
                        ), // Example placeholder
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withValues(alpha: 0.5),
                          BlendMode.darken,
                        ), // ✅ FIXED: withOpacity to withValues
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.volunteer_activism,
                        color: AppColors.primaryYellow,
                        size: 40,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Help Us Power Communities",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        "100% goes to the project",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- AMOUNT SELECTION ---
                  const Text(
                    "SELECT AMOUNT",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Grid of Amounts
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.2,
                        ),
                    itemCount: amounts.length,
                    itemBuilder: (context, index) {
                      final amount = amounts[index];
                      final isSelected = selectedAmount == amount;
                      return InkWell(
                        onTap: () => setState(() => selectedAmount = amount),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryYellow
                                : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryYellow
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              "\$$amount",
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // --- DONOR DETAILS ---
                  const Text(
                    "YOUR DETAILS",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildInputField("Full Name", _nameController, Icons.person),
                  const SizedBox(height: 10),
                  _buildInputField(
                    "Email Address",
                    _emailController,
                    Icons.email,
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    "Phone (MoMo)",
                    _phoneController,
                    Icons.phone,
                    isNumber: true,
                  ),

                  const SizedBox(height: 20),

                  // --- PAYMENT METHOD ---
                  const Text(
                    "PAYMENT METHOD",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildPaymentCard(
                          "Mobile Money",
                          "momo",
                          Icons.phone_android,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildPaymentCard(
                          "Credit Card",
                          "card",
                          Icons.credit_card,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- DONATE BUTTON ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: isProcessing ? null : _processDonation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryYellow,
                        foregroundColor: AppColors.primaryDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: isProcessing
                          ? const CircularProgressIndicator(
                              color: AppColors.primaryDark,
                            )
                          : Text(
                              "DONATE \$$selectedAmount NOW",
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String hint,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(icon, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(String label, String key, IconData icon) {
    final isSelected = selectedPayment == key;
    return GestureDetector(
      onTap: () => setState(() => selectedPayment = key),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryDark : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryDark : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryYellow : Colors.grey,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
