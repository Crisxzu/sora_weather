class Condition {
  final int code;
  final String text;

  Condition({
    required this.code,
    required this.text,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      code: json['code'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'text': text,
    };
  }
}