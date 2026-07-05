import 'package:flutter/material.dart';
import 'package:taxed/utils/input_limits.dart';
import 'package:taxed/widgets/app_text_field.dart';

class InsertPersonRow extends StatelessWidget {
  const InsertPersonRow({
    super.key,
    required this.nameController,
    required this.emoji,
    required this.onEmojiTap,
    required this.labelColor,
  });

  final TextEditingController nameController;
  final String emoji;
  final VoidCallback onEmojiTap;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: nameController,
              hint: 'Person Name',
              keyboardType: TextInputType.text,
              labelColor: labelColor,
              maxLength: InputLimits.maxPersonNameLength,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onEmojiTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFFD966),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                emoji.isEmpty ? '😉' : emoji,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
