class FractionParseException implements Exception{
  String? message;
  FractionParseException([this.message]); 
  @override
  String toString() {
    return message ?? "";
  }
}