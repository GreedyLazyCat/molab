// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:molib/molib.dart';
import 'package:molib/src/artificial_solver.dart';

enum StepType {
  initial,

  ///Возможно рудиментарный тип
  error,

  ///На этом шаге еще вычисляется базис
  artificial,

  ///На этом шаге уже посчитан базис, но нужно выполнить холостые
  ///ходы, чтобы заменить переменные
  artificialIdle,

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
  StepIndices? elemCoord;

  ///Матрица ограничений на этом шаге
  final StepMatrix stepMatrix;

  ///Индексы свободных переменных
  final List<int> rowIndices;

  ///Индексы базисных переменных
  final List<int> colIndices;

  final StepType type;

  String? error;

  StepInfo(
      {this.elemCoord,
      required this.stepMatrix,
      required this.rowIndices,
      required this.colIndices,
      required this.type,
      this.error});

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

  ///Сделано на скорую руку, ужасно
  String fullMatrixToString() {
    String result = "";
    String space = "";
    final colMax = colIndices
        .reduce((acc, elem) => (acc.abs() > elem.abs()) ? acc : elem)
        .toString()
        .length;

    for (var i = 0; i < colMax + 1; i++) {
      space += " ";
    }
    result += space;
    for (var elem in rowIndices) {
      result += "$elem ";
    }

    result += "\n";

    for (var i = 0; i < stepMatrix.length; i++) {
      final row = stepMatrix[i];
      if (i < colIndices.length) {
        result += "${colIndices[i]} ";
      }
      if (i == stepMatrix.length - 1) {
        result += space;
      }
      for (var j = 0; j < row.length; j++) {
        if (row[j] is Fraction) {
          result += "${row[j].reduced()} ";
        } else {
          result += "${row[j]}";
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
