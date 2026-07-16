class ItemEntry {
  ItemEntry({
    required this.name,
    required this.amount,
    this.quantity = 0,
  });

  final String name;
  final String amount;
  final int quantity;
}

class PersonEntry {
  PersonEntry({
    required this.name,
  });

  final String name;
}

class InsertBatch {
  InsertBatch({
    required this.items,
    required this.persons,
  });

  final List<ItemEntry> items;
  final List<PersonEntry> persons;
}
