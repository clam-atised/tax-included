class ItemEntry {
  ItemEntry({
    required this.name,
    required this.amount,
    this.splitCount = 0,
  });

  final String name;
  final String amount;
  final int splitCount;
}

class PersonEntry {
  PersonEntry({
    required this.name,
    required this.emoji,
  });

  final String name;
  final String emoji;
}

class InsertBatch {
  InsertBatch({
    required this.items,
    required this.persons,
  });

  final List<ItemEntry> items;
  final List<PersonEntry> persons;
}
