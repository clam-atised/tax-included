import 'package:flutter/material.dart';
import 'package:taxed/models/insert_models.dart';

class ItemRowState {
  ItemRowState()
      : nameController = TextEditingController(),
        amountController = TextEditingController();

  final TextEditingController nameController;
  final TextEditingController amountController;
  int splitCount = 0;

  void dispose() {
    nameController.dispose();
    amountController.dispose();
  }

  ItemEntry toEntry() => ItemEntry(
        name: nameController.text,
        amount: amountController.text,
        splitCount: splitCount,
      );
}

class PersonRowState {
  PersonRowState() : nameController = TextEditingController();

  final TextEditingController nameController;
  String emoji = '';

  void dispose() {
    nameController.dispose();
  }

  PersonEntry toEntry() => PersonEntry(
        name: nameController.text,
        emoji: emoji,
      );
}
