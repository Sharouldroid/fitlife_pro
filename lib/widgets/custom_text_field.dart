import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    this.hint = '',
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. DETECT DARK MODE
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Text
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            // If Dark: Light Grey. If Light: Black.
            color: isDark ? Colors.grey[300] : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          
          // INPUT TEXT COLOR
          style: TextStyle(
            fontSize: 16, 
            color: isDark ? Colors.white : Colors.black87
          ),
          
          decoration: InputDecoration(
            hintText: hint,
            // Hint Text Color
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[500] : Colors.grey[400], 
              fontSize: 14
            ),
            
            // Icon Color
            prefixIcon: Icon(
              prefixIcon, 
              color: isDark ? Colors.tealAccent : Colors.teal
            ),
            
            filled: true,
            // BACKGROUND COLOR: Dark Grey in Dark Mode, White in Light Mode
            fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
            
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            
            // Borders
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? Colors.grey[700]! : Colors.grey.shade300, 
                width: 1
              ),
            ),
            
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
            
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}