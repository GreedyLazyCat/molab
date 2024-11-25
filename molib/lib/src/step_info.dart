// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:molib/molib.dart';
import 'package:molib/src/artificial_solver.dart';

enum StepType {
  ///На этом шаге еще вычисляется базис
  artificial,

  ///Вычисление базиса завершено, нужно переходить к решению задачи
  artificialFinal,

  ///На этом шаге уже вычисляется сама задача
  main,

  ///Система решена
  solved
}

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

  final StepType type;

  StepInfo(
      {this.elemCoord,
      required this.stepMatrix,
      required this.rowIndices,
      required this.colIndices,
      required this.type});

  String stepMatrixToString() {
    String result = "";
    for (var row in stepMatrix) {
      for (var elem in row) {
        if (elem is Fraction) {
          result += "${elem.reduced()} ";
        } else {
          result += "$elem ";
        }
      }

      result += "\n";
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
