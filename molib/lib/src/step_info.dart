// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:molib/src/artificial_solver.dart';

///Класс для хранения информации о шаге
///[stepMatrix] - матрица решения на текущем шаге
class StepInfo {
  final int i;
  final int j;
  final StepMatrix stepMatrix;
  final List<int> rowIndicies;
  final List<int> colIndicies;

  StepInfo({
    required this.i,
    required this.j,
    required this.stepMatrix,
    required this.rowIndicies,
    required this.colIndicies,
  });
}
