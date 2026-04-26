class WirdItem {
  final String title;
  final String text;
  final int repetitions;
  final String? instruction;
  final bool hasBasmala;
  final bool hasIstiada;

  final bool eveningOnly;

  const WirdItem({
    required this.title,
    required this.text,
    this.repetitions = 1,
    this.instruction,
    this.hasBasmala = false,
    this.hasIstiada = false,
    this.eveningOnly = false,
  });
}

class WirdSection {
  final String title;
  final String? subtitle;
  final List<WirdItem> items;

  const WirdSection({
    required this.title,
    this.subtitle,
    required this.items,
  });
}

enum WirdTimeOfDay { morning, evening }

enum WirdType { dalail, wirdAam, tahsin, quran }
