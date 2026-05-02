class WirdItem {
  final String title;
  final String text;
  final int repetitions;
  final String? instruction;
  final bool hasBasmala;
  final bool hasIstiada;
  final bool eveningOnly;

  /// Texte de l'آية qui précède le ذكر (affiché en haut de la carte)
  final String? ayaText;

  /// Référence / instruction de l'آية (ex. "الآية ١٠ من سورة نوح")
  final String? ayaInstruction;

  /// Vrai si [text] est un verset / sourate du Coran (affichage en police Warsh)
  final bool isQuranVerse;

  /// Numéro du premier verset dans [text] (pour affichage automatique des numéros)
  final int? startVerseNumber;

  const WirdItem({
    required this.title,
    required this.text,
    this.repetitions = 1,
    this.instruction,
    this.hasBasmala = false,
    this.hasIstiada = false,
    this.eveningOnly = false,
    this.ayaText,
    this.ayaInstruction,
    this.isQuranVerse = false,
    this.startVerseNumber,
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
