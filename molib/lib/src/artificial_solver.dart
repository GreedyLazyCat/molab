// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';

import 'package:molib/molib.dart';
import 'package:molib/src/solver_exception.dart';
import 'package:molib/src/step_info.dart';

enum MatrixMode { fraction, floating }

///Режим решения
enum BasisMode {
  ///Режим выбора базисных переменных
  selected,

  ///Режим метода искуственного базиса
  artificial
}

typedef IntMatrix = List<List<int>>;
typedef StepMatrix = List<List<dynamic>>;

class ArtificialSolver {
  final MatrixMode mode;

  final BasisMode basisMode;

  final int varCount;

  final int restrictionCount;

  final IntMatrix initRestrictMatrix;

  final List<int> funcCoef;

  final List<StepInfo> history = [];

  ArtificialSolver({
    required this.mode,
    required this.basisMode,
    required this.varCount,
    required this.restrictionCount,
    required this.initRestrictMatrix,
    required this.funcCoef,
  }) : assert(restrictionCount == initRestrictMatrix.length);

  StepMatrix get lastStepMatrix => history.last.stepMatrix;
  StepInfo get lastStep => history.last;

  void clearHistory() {
    history.clear();
  }

  ///Метод делает следующий шаг в решении метода исскуственного базиса.
  ///[selectedSupElem] - индексы опорного элемента, если передан null
  ///элемент будет выбран автоматически
  void nextStep(StepIndices? selectedSupElem) {
    StepIndices? supElem = selectedSupElem ?? findFirstSupElement();

    if (supElem == null) {
      throw SolverException("Система уже решена");
    }

    final validation = supElementValidity(supElem);
    if (validation != null) {
      throw SolverException(validation);
    }

    StepMatrix newStepMatrix = generateZeroMatrix();
    final List<int> rowIndices = List.from(lastStep.rowIndices);
    final List<int> colIndices = List.from(lastStep.colIndices);

    dynamic supElemNewValue = (mode == MatrixMode.floating)
        ? 1 / lastStepMatrix[supElem.row][supElem.col]
        : Fraction(1, 1) / lastStepMatrix[supElem.row][supElem.col];
    newStepMatrix[supElem.row][supElem.col] = supElemNewValue;

    for (var col = 0; col < varCount + 1; col++) {
      if (supElem.col == col) {
        continue;
      }
      final currElemValue = lastStepMatrix[supElem.row][col];
      newStepMatrix[supElem.row][col] = currElemValue * supElemNewValue;
    }

    for (var row = 0; row < restrictionCount + 1; row++) {
      if (supElem.row == row) {
        continue;
      }
      final currElemValue = lastStepMatrix[row][supElem.col];
      dynamic minusOne = (mode == MatrixMode.floating) ? -1 : Fraction(-1, 1);
      newStepMatrix[row][supElem.col] =
          currElemValue * (minusOne * supElemNewValue);
    }
    /*
    for (var i = 0; i < varCount; i++) {
      for (var j = 0; j < restrictionCount; j++) {
        final currElemValue = lastStepMatrix[i][j];
        if (i == supElem.row && j == supElem.col) {
          continue;
        }
        if (i == supElem.row) {
          lastStepMatrix[i][j] = currElemValue * supElemNewValue;
          continue;
        }
        if (j == supElem.row) {
          lastStepMatrix[i][j] = currElemValue * (-1 * supElemNewValue);
          continue;
        }
      }
    }*/

    history.add(StepInfo(
        stepMatrix: newStepMatrix,
        rowIndices: rowIndices,
        colIndices: colIndices));
  }

  StepMatrix generateZeroMatrix() {
    return List.generate(
        restrictionCount + 1,
        (index) => List.generate(varCount + 1, (index) {
              if (mode == MatrixMode.fraction) {
                return Fraction(0, 1);
              }
              if (mode == MatrixMode.floating) {
                return 0.0;
              }
            }));
  }

  ///Находит первый попавшийся опорный элемент
  StepIndices? findFirstSupElement() {
    StepIndices? result;
    for (var col = 0; col < varCount; col++) {
      if (lastStepMatrix[restrictionCount][col] >= 0) {
        continue;
      }
      result = findSupElementInColumn(col);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  StepIndices? _findFirstNonZeroPositiveElemInCol(int col) {
    for (var row = 0; row < (restrictionCount); row++) {
      if (lastStepMatrix[row][col] > 0) {
        return StepIndices(row: row, col: col);
      }
    }
    return null;
  }

  ///Возвращает опорный элемент в столбце.
  ///В случае, если не найден - [null]
  StepIndices? findSupElementInColumn(int col) {
    final stepMatrix = history.last.stepMatrix;
    var elem = _findFirstNonZeroPositiveElemInCol(col);
    if (elem == null) {
      return null;
    }
    var elemValue = stepMatrix[elem.row][elem.col];
    var minSupElemDivided = stepMatrix[elem.row][varCount] / elemValue;
    StepIndices? result = StepIndices(row: elem.row, col: elem.col);

    for (var row = 0; row < (restrictionCount); row++) {
      final currentSupElemValue = stepMatrix[row][col];
      if (currentSupElemValue == 0) {
        continue;
      }
      final currentSupElemDivided =
          stepMatrix[row][varCount] / currentSupElemValue;
      if (currentSupElemDivided < minSupElemDivided) {
        minSupElemDivided = currentSupElemDivided;
        result = StepIndices(row: row, col: col);
      }
    }

    return result;
  }

  ///В случае, если элемент нельзя выбрать в качестве
  String? supElementValidity(StepIndices elemIndices) {
    final stepMatrix = history.last.stepMatrix;
    final elemValue = stepMatrix[elemIndices.row][elemIndices.col];
    final funcColCoef = stepMatrix[restrictionCount][elemIndices.col];

    if (funcColCoef > 0) {
      return "Опорный элемент можно выбирать только в столбце, где коэффициент функции отрицателен.";
    }

    if (elemValue <= 0) {
      return "Значение опрного элемента должно быть положительно.";
    }

    final supElemIndices = findSupElementInColumn(elemIndices.col);

    if (stepMatrix[supElemIndices!.row][supElemIndices.col] != elemValue) {
      return "Отношение опорного элемента к свободному члену должно быть минимально";
    }
  }

  ///Конвертирует изначальную матрицу в матрицу состояющую
  ///из [double] или [Fraction], взависимости от [MatrixMode]
  StepMatrix convertInitialMatrix() {
    return initRestrictMatrix
        .map((e) => e.map((to) {
              if (mode == MatrixMode.fraction) {
                print('asdf');
                return Fraction(to, 1);
              } else if (mode == MatrixMode.floating) {
                return to.toDouble();
              }
            }).toList())
        .toList();
  }

  ///Изначальный шаг решения для метода исскуственного базиса
  ///Т.к. не требуется решения системы методом гаусса
  void initialArtificialStep() {
    final List<int> rowIndices = List.generate(varCount, (index) => index + 1);
    final List<int> colIndices =
        List.generate(restrictionCount, (index) => varCount + index + 1);
    //TODO: добавить проверку соответствия varCount, restrictionCount
    //с размерами матрицы
    final StepMatrix stepMatrix = convertInitialMatrix();
    final List<dynamic> lastRow = [];

    for (var i = 0; i < varCount + 1; i++) {
      dynamic sum = stepMatrix[0][i];
      for (var j = 1; j < restrictionCount; j++) {
        print(sum.runtimeType.toString());
        sum += stepMatrix[j][i];
      }
      sum *= -1;
      lastRow.add(sum);
    }

    stepMatrix.add(lastRow);

    final step = StepInfo(
        stepMatrix: stepMatrix, rowIndices: rowIndices, colIndices: colIndices);
    history.add(step);
  }

  void initialStep() {
    switch (basisMode) {
      case BasisMode.artificial:
        initialArtificialStep();
        break;
      case BasisMode.selected:
        //Если базисные переменные выбираются - нужно сначала
        //посчитать этот самый базис
        break;
    }
  }

  String tempToString() {
    final last = history.last;
    var result = "";
    for (var row in last.stepMatrix) {
      String rowString = "";
      for (var elem in row) {
        rowString += "${elem.toString()} ";
      }
      rowString += "\n";
      result += rowString;
    }

    result += "\nИндексы переменных\n";

    for (var index in last.rowIndices) {
      result += "$index ";
    }

    result += "\nИндексы базисных переменных\n";

    for (var index in last.colIndices) {
      result += "$index ";
    }
    return result;
  }
}
