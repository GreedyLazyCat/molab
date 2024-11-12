class FractionException implements Exception {
  String? message;
  FractionException([this.message]);
  @override
  String toString() {
    return message ?? "";
  }
}
