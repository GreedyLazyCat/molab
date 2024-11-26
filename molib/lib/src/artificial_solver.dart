// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:math';

import 'package:molib/molib.dart';
import 'package:molib/src/exception/solver_exception.dart';
import 'package:molib/src/step_info.dart';

enum MatrixMode { fraction, double }

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

  final int initialVarCount;

  final int initialRestrictionCount;

  final IntMatrix initRestrictMatrix;

  final List<int> funcCoef;

  final List<StepInfo> history = [];

  ArtificialSolver({
    required this.mode,
    required this.basisMode,
    required this.initialVarCount,
    required this.initialRestrictionCount,
    required this.initRestrictMatrix,
    required this.funcCoef,
  }) : assert(initialRestrictionCount == initRestrictMatrix.length);

  StepMatrix get lastStepMatrix => history.last.stepMatrix;
  StepInfo get lastStep => history.last;
  StepInfo get firstStep => history.first;
  int get varCount => history.last.rowIndices.length;
  int get restrictionCount => history.last.colIndices.length;

  void clearHistory() {
    history.clear();
  }

  ///Метод делает следующий шаг в решении метода исскуственного базиса.
  ///[selectedSupElem] - индексы опорного элемента, если передан null
  ///элемент будет выбран автоматически
  void nextStep([StepIndices? selectedSupElem]) {
    if (lastStep.type == StepType.solved) {
      throw SolverException("Система уже решена");
    }
    if (lastStep.type == StepType.artificialFinal) {
      final newStep = makeStepAfterArtificialFinal(lastStep);
      history.add(newStep);
    }

    StepIndices? supElem = selectedSupElem ?? findFirstSupElement();

    if (supElem == null) {
      throw SolverException("Система уже решена");
    }

    final validation = supElementValidity(supElem);
    if (validation != null) {
      throw SolverException(validation);
    }

    final List<int> rowIndices = List.from(lastStep.rowIndices);
    final List<int> colIndices = List.from(lastStep.colIndices);

    //Смена индексов переменных
    final swap = rowIndices[supElem.col];
    rowIndices[supElem.col] = colIndices[supElem.row];
    colIndices[supElem.row] = swap;

    final newStepMatrix = calculateStepMatrix(supElem, lastStepMatrix);

    StepType stepType;
    String? error;

    try {
      stepType = getStepType(newStepMatrix, rowIndices, colIndices);
    } on SolverException catch (e) {
      stepType = StepType.error;
      error = e.message;
    }
    lastStep.elemCoord = supElem;
    final newStep = StepInfo(
        stepMatrix: newStepMatrix,
        rowIndices: rowIndices,
        colIndices: colIndices,
        type: stepType,
        error: error);

    //Проверка, что все хорошо в решении системы

    history.add(newStep);
  }

  StepInfo makeStepAfterArtificialFinal(StepInfo step) {
    if (step.type != StepType.artificialFinal) {
      throw SolverException("Шаг не финальный после нахождения базиса ");
    }
    final rowSet = step.rowIndices.toSet();
    final initialColSet = firstStep.colIndices.toSet();

    final newRowIndices = rowSet.difference(initialColSet).toList();
    final newMatrix = generateZeroMatrix(
        step.colIndices.length + 1, newRowIndices.length + 1);

    for (var col = 0; col < (newRowIndices.length + 1); col++) {
      var colSum = (mode == MatrixMode.fraction) ? Fraction(0, 1) : 0;
      for (var row = 0; row < (step.colIndices.length + 1); row++) {
        final rowColCoef = funcCoef[step.colIndices[row] - 1] * -1;
      }
    }
    return StepInfo(
        stepMatrix: newMatrix,
        rowIndices: newRowIndices,
        colIndices: step.colIndices,
        type: StepType.main);
  }

  ///Считает основную матрицу на основе переданного элемента и матрицы
  StepMatrix calculateStepMatrix(
      StepIndices supElem, StepMatrix prevStepMatrix) {
    StepMatrix newStepMatrix =
        generateZeroMatrix(restrictionCount + 1, varCount + 1);
//Вычисление значения опорного элемента
    dynamic supElemNewValue = (mode == MatrixMode.double)
        ? 1 / prevStepMatrix[supElem.row][supElem.col]
        : Fraction(1, 1) / prevStepMatrix[supElem.row][supElem.col];

    newStepMatrix[supElem.row][supElem.col] = supElemNewValue;

    //Умножение строки опорного элемента (стоит выделить в функцию?)
    for (var col = 0; col < varCount + 1; col++) {
      if (supElem.col == col) {
        continue;
      }
      final currElemValue = prevStepMatrix[supElem.row][col];
      newStepMatrix[supElem.row][col] = currElemValue * supElemNewValue;
    }

    //Умножение столбца опорного элемента (стоит выделить в функцию?)
    for (var row = 0; row < restrictionCount + 1; row++) {
      if (supElem.row == row) {
        continue;
      }
      final currElemValue = prevStepMatrix[row][supElem.col];
      dynamic minusOne = (mode == MatrixMode.double) ? -1 : Fraction(-1, 1);
      newStepMatrix[row][supElem.col] =
          currElemValue * (minusOne * supElemNewValue);
    }

    //Вычисления оставшихся строк
    for (var i = 0; i < restrictionCount + 1; i++) {
      if (i == supElem.row) {
        continue;
      }
      for (var j = 0; j < varCount + 1; j++) {
        if (j == supElem.col) {
          continue;
        }
        final prevElemValue = prevStepMatrix[i][j];
        final prevElemColValue = prevStepMatrix[i][supElem.col];
        final newElemRowValue = newStepMatrix[supElem.row][j];
        newStepMatrix[i][j] =
            prevElemValue - (newElemRowValue * prevElemColValue);
      }
    }
    return newStepMatrix;
  }

  String? validateStep(
      StepMatrix stepMatrix, List<int> rowIndicies, List<int> colIndicies) {
    if (lastStep.type == StepType.artificial) {
      final lastRow = stepMatrix.last;

      if (lastRow.last > 0) {
        return "СЛАУ не совместна";
      }
      if (lastRow.last < 0) {
        return "";
      }
    }

    return null;
  }

  ///Проверяет тип шага по его матрице
  StepType getStepType(
      StepMatrix stepMatrix, List<int> rowIndicies, List<int> colIndicies) {
    if (lastStep.type == StepType.artificial) {
      final lastRow = stepMatrix.last;
      final negativeCheck = lastRow.indexWhere((elem) => elem < 0);
      if (negativeCheck != -1 && negativeCheck != varCount) {
        return StepType.artificial;
      }
      if (lastRow.last > 0) {
        throw SolverException("СЛАУ не совместна");
      }
      if (lastRow.last < 0) {
        throw SolverException(
            "Что-то пошло не так. Отрицательных коэфициентов нет, но значение функции отрицательно.");
      }

      ///Проверка ушли ли все исскуственные переменные или нужно делать холостой шаг
      final colSet = history.first.colIndices.toSet();
      final notContainArtificialVars = !colIndicies.any(colSet.contains);

      if (notContainArtificialVars) {
        return StepType.artificialFinal;
      }
    }

    return StepType.main;
  }

  ///Генерирует пустую матрицу с дополнительной строкой для функции
  ///и доп стобцом для свободных членов
  StepMatrix generateZeroMatrix(int rowCount, int colCount) {
    return List.generate(
        rowCount,
        (index) => List.generate(colCount, (index) {
              if (mode == MatrixMode.fraction) {
                return Fraction(0, 1);
              }
              if (mode == MatrixMode.double) {
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
      if (result == null) {
        continue;
      }
      if (lastStep.type == StepType.artificial &&
          (!firstStep.colIndices.contains(lastStep.colIndices[result.row]) ||
              firstStep.colIndices.contains(lastStep.rowIndices[result.col]))) {
        continue;
      }
      return result;
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
      if (currentSupElemValue <= 0) {
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
    final elemDividedValue = stepMatrix[elemIndices.row][varCount] / elemValue;
    final funcColCoef = stepMatrix[restrictionCount][elemIndices.col];

    if (funcColCoef > 0) {
      return "Опорный элемент можно выбирать только в столбце, где коэффициент функции отрицателен.";
    }

    if (elemValue <= 0) {
      return "Значение опрного элемента должно быть положительно.";
    }

    final supElemIndices = findSupElementInColumn(elemIndices.col);
    final supElem = stepMatrix[supElemIndices!.row][supElemIndices.col];
    final supElemDivided = stepMatrix[supElemIndices!.row][varCount] / supElem;

    if (supElemDivided != elemDividedValue) {
      return "Отношение опорного элемента к свободному члену должно быть минимально";
    }
  }

  ///Конвертирует изначальную матрицу в матрицу состояющую
  ///из [double] или [Fraction], взависимости от [MatrixMode]
  StepMatrix convertInitialMatrix() {
    return initRestrictMatrix
        .map((e) => e.map((to) {
              if (mode == MatrixMode.fraction) {
                return Fraction(to, 1);
              } else if (mode == MatrixMode.double) {
                return to.toDouble();
              }
            }).toList())
        .toList();
  }

  ///Изначальный шаг решения для метода исскуственного базиса
  ///Т.к. не требуется решения системы методом гаусса
  void initialArtificialStep() {
    final List<int> rowIndices =
        List.generate(initialVarCount, (index) => index + 1);
    final List<int> colIndices = List.generate(
        initialRestrictionCount, (index) => initialVarCount + index + 1);
    //TODO: добавить проверку соответствия varCount, restrictionCount
    //с размерами матрицы
    final StepMatrix stepMatrix = convertInitialMatrix();
    final List<dynamic> lastRow = [];

    for (var i = 0; i < initialVarCount + 1; i++) {
      dynamic sum = stepMatrix[0][i];
      for (var j = 1; j < initialRestrictionCount; j++) {
        sum += stepMatrix[j][i];
      }
      sum *= -1;
      lastRow.add(sum);
    }

    stepMatrix.add(lastRow);

    final step = StepInfo(
        stepMatrix: stepMatrix,
        rowIndices: rowIndices,
        colIndices: colIndices,
        type: StepType.artificial);
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
}
