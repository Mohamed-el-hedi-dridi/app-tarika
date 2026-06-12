import 'dart:convert';

class CustomDhikr {
  final String id;
  final String title;
  final String text;
  final int repetitions;

  const CustomDhikr({
    required this.id,
    required this.title,
    required this.text,
    this.repetitions = 1,
  });

  CustomDhikr copyWith({
    String? id,
    String? title,
    String? text,
    int? repetitions,
  }) {
    return CustomDhikr(
      id: id ?? this.id,
      title: title ?? this.title,
      text: text ?? this.text,
      repetitions: repetitions ?? this.repetitions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'text': text,
        'repetitions': repetitions,
      };

  factory CustomDhikr.fromJson(Map<String, dynamic> json) => CustomDhikr(
        id: json['id'] as String,
        title: json['title'] as String,
        text: json['text'] as String,
        repetitions: json['repetitions'] as int? ?? 1,
      );

  static List<CustomDhikr> listFromJson(String jsonStr) {
    final list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => CustomDhikr.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String listToJson(List<CustomDhikr> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
}
