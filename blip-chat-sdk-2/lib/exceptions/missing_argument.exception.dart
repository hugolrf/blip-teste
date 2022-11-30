class MissingArgumentException implements Exception {
  MissingArgumentException(
    this.message,
    this.field,
  );

  String message;
  String field;

  Map<String, dynamic> toJson() => {
        'message': message,
        'field': field,
      };
}
