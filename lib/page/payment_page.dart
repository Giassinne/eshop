import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

class PaymentPage extends StatelessWidget {
  final double total;

  const PaymentPage({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    // Controllers for input fields
    final nameController = TextEditingController();
    final cardNumberController = TextEditingController();
    final expiryDateController = TextEditingController();
    final cvvController = TextEditingController();

    Future<void> sendPurchaseRequest(BuildContext context) async {
      const url = "http://ptsv3.com/t/EPSISHOPC1/";
      const fallbackUrl = "http://ptsv3.com/t/EPSISHOPC2/";

      final purchaseData = {
        "name": nameController.text,
        "total": total.toStringAsFixed(2),
        "date": DateTime.now().toIso8601String(),
      };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(purchaseData),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Paiement réussi : ${response.body}")),
          );
        } else {
          final fallbackResponse = await http.post(
            Uri.parse(fallbackUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(purchaseData),
          );

          if (fallbackResponse.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Paiement réussi avec fallback : ${fallbackResponse.body}")),
            );
          } else {
            throw Exception("Échec des deux URLs");
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors du paiement : $e")),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Paiement"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total à payer : ${total.toStringAsFixed(2)} €",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // Full Name Field
              _buildInputField(
                controller: nameController,
                label: "Nom complet",
                hint: "Entrez votre nom complet",
                icon: Icons.person,
                validator: (value) => value!.isEmpty ? "Champ requis" : null,
              ),
              const SizedBox(height: 15),
              // Card Number Field
              _buildInputField(
                controller: cardNumberController,
                label: "Numéro de carte",
                hint: "1234 5678 9123 4567",
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                maxLength: 16,
                validator: (value) => value!.length != 16 ? "Numéro invalide" : null,
              ),
              const SizedBox(height: 15),
              // Expiry Date Field
              _buildInputField(
                controller: expiryDateController,
                label: "Date d'expiration (MM/YY)",
                hint: "MM/YY",
                icon: Icons.calendar_today,
                keyboardType: TextInputType.datetime,
                maxLength: 5,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')), // Only allow numbers and '/'
                  LengthLimitingTextInputFormatter(5), // Limit to 5 characters
                ],
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Champ requis";
                  }
                  // Validate MM/YY format
                  final dateRegExp = RegExp(r"^(0[1-9]|1[0-2])\/([0-9]{2})$");
                  if (!dateRegExp.hasMatch(value)) {
                    return "Format invalide. Utilisez MM/YY";
                  }
                  final now = DateTime.now();
                  final parts = value.split('/');
                  final month = int.parse(parts[0]);
                  final year = int.parse(parts[1]) + 2000;  // Convert YY to YYYY
                  final expiryDate = DateTime(year, month);

                  if (expiryDate.isBefore(now)) {
                    return "La date d'expiration ne peut pas être dans le passé";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              // CVV Field
              _buildInputField(
                controller: cvvController,
                label: "CVV",
                hint: "123",
                icon: Icons.lock,
                keyboardType: TextInputType.number,
                maxLength: 3,
                validator: (value) => value!.length != 3 ? "CVV invalide" : null,
              ),
              const SizedBox(height: 30),
              // Pay Button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Paiement effectué avec succès !")),
                      );
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text(
                    "Payer",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Method for Input Fields
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,  // Accept inputFormatters
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      keyboardType: keyboardType,
      validator: validator,
      maxLength: maxLength,
      inputFormatters: inputFormatters,  // Apply input formatters
    );
  }
}
