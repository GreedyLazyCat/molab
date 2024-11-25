class SolverException implements Exception {
  String? message;
  SolverException([this.message]);
  @override
  String toString() {
    return message ?? "";
  }
}
