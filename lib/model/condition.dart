class Condition {
  final int code;
  final String text;
  final int iconCode;

  Condition({
    required this.code,
    required this.text,
    required this.iconCode
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      code: json['code'],
      text: json['text'],
      iconCode: json['icon']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'text': text,
      'icon': iconCode
    };
  }
}