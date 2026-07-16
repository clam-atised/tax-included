import 'package:flutter/material.dart';
import 'package:taxed/models/insert_models.dart';

class ItemRowState {
  ItemRowState()
      : nameController = TextEditingController(),
        amountController = TextEditingController();

  final TextEditingController nameController;
  final TextEditingController amountController;
  int quantity = 0;
  VoidCallback? _nameListener;

  void attachNameListener(VoidCallback listener) {
    _nameListener = listener;
    nameController.addListener(listener);
  }

  void dispose() {
    if (_nameListener != null) {
      nameController.removeListener(_nameListener!);
      _nameListener = null;
    }
    nameController.dispose();
    amountController.dispose();
  }

  ItemEntry toEntry() => ItemEntry(
        name: nameController.text,
        amount: amountController.text,
        quantity: quantity,
      );
}

class PersonRowState {
  PersonRowState() : nameController = TextEditingController();

  final TextEditingController nameController;

  void dispose() {
    nameController.dispose();
  }

  PersonEntry toEntry() => PersonEntry(
        name: nameController.text,
      );
}
