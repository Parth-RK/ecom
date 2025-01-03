class Country {
  final String name;
  final String code;
  final String? dialCode;

  const Country({
    required this.name,
    required this.code,
    this.dialCode,
  });
}
