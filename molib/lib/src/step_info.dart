// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:molib/src/artificial_solver.dart';

///Класс для хранения информации о шаге
///[stepMatrix] - матрица решения на текущем шаге
class StepInfo {
  ///Индексы выбранного опорного элемента на этом шаге,
  final StepIndices? elemCoord;

  ///Матрица ограничений на этом шаге
  final StepMatrix stepMatrix;

  ///Индексы свободных переменных
  final List<int> rowIndices;

  ///Индексы базисных переменных
  final List<int> colIndices;

  StepInfo({
    this.elemCoord,
    required this.stepMatrix,
    required this.rowIndices,
    required this.colIndices,
  });

  String stepMatrixToString() {
    String result = "";
    for (var row in stepMatrix) {
      result += "$row\n";
    }
    return result;
  }

  @override
  String toString() {
    return 'StepInfo(elemCoord: $elemCoord, stepMatrix: $stepMatrix, rowIndicies: $rowIndices, colIndicies: $colIndices)';
  }
}

class StepIndices {
  final int row;
  final int col;
  StepIndices({
    required this.row,
    required this.col,
  });

  @override
  String toString() => 'StepCoord(row: $row, col: $col)';
}
