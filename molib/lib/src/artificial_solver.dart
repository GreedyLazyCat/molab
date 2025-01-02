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
      return;
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
      stepType =
          getStepType(newStepMatrix, rowIndices, colIndices, lastStep.type);
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
      dynamic colSum = (mode == MatrixMode.fraction) ? Fraction(0, 1) : 0;
      final prevMatrixColIndex = (col == newRowIndices.length)
          ? step.rowIndices.length
          : step.rowIndices.indexOf(newRowIndices[col]);
      // print("---------------------------------");
      // print("indices: $newRowIndices");
      // print("prevMatrixColIndex: $prevMatrixColIndex");
      for (var row = 0; row < (step.colIndices.length + 1); row++) {
        if (row == step.colIndices.length) {
          // print("funcCoef: ${funcCoef[prevMatrixColIndex]}");
          newMatrix[row][col] = colSum + funcCoef[prevMatrixColIndex];
          // print("colSum: ${newMatrix[row][col]}");
          continue;
        }
        final funcCoefIndex = step.colIndices[row] - 1;
        final rowCoef = funcCoef[funcCoefIndex] * -1;
        final prevMatrixValue = step.stepMatrix[row][prevMatrixColIndex];

        // print("funcCoefIndex: $funcCoefIndex");
        // print("prevMatrixValue: $prevMatrixValue");
        // print("rowCoef: $rowCoef");
        newMatrix[row][col] = prevMatrixValue;
        colSum += prevMatrixValue * rowCoef;
      }
    }
    // newMatrix[restrictionCount][newRowIndices.length] *= -1;

    final stepType = getStepType(
        newMatrix, newRowIndices, step.colIndices, StepType.artificialFinal);

    return StepInfo(
        stepMatrix: newMatrix,
        rowIndices: newRowIndices,
        colIndices: step.colIndices,
        type: stepType);
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

  ///Проверяет есть ли в матрице, где должны быть коэффициенты функции
  ///отрицательные элементы, кроме значения самой функции.
  bool isStepHasNegativeFuncCoef(StepMatrix stepMatrix, int stepVarCount) {
    final lastRow = stepMatrix.last;
    final negativeCheck = lastRow.indexWhere((elem) => elem < 0);
    if (negativeCheck != -1 && negativeCheck != stepVarCount) {
      return true;
    }
    return false;
  }

  ///Проверяет тип шага по его матрице.
  ///В случае, если в матрице есть ошибка - выбрасывается эксепшн с детализацией ошибки.
  StepType getStepType(StepMatrix stepMatrix, List<int> rowIndices,
      List<int> colIndices, StepType? lastStepType) {
    if (lastStepType == null) {
      for (var col = 0; col < rowIndices.length; col++) {
        final nonZeroElement = _findFirstNonZeroPositiveElemInCol(
            col, stepMatrix, colIndices.length);
        final lastElem = stepMatrix.last[col];
        if (nonZeroElement == null && lastElem < 0) {
          throw SolverException("Функция неограничена снизу");
        }
      }
      return StepType.initial;
    }
    if (lastStepType == StepType.artificial ||
        (lastStepType == StepType.initial &&
            basisMode == BasisMode.artificial)) {
      final lastRow = stepMatrix.last;
      if (isStepHasNegativeFuncCoef(stepMatrix, rowIndices.length)) {
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
      final notContainArtificialVars = !colIndices.any(colSet.contains);

      if (notContainArtificialVars) {
        return StepType.artificialFinal;
      }
    }
    if (lastStepType == StepType.artificialFinal ||
        lastStepType == StepType.main ||
        (lastStepType == StepType.initial && basisMode == BasisMode.selected)) {
      if (isStepHasNegativeFuncCoef(stepMatrix, rowIndices.length)) {
        return StepType.main;
      }
      return StepType.solved;
    }
    return StepType.error;
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

  StepIndices? _findFirstNonZeroPositiveElemInCol(
      int col, StepMatrix stepMatrix, int rowCount) {
    for (var row = 0; row < (rowCount); row++) {
      if (stepMatrix[row][col] > 0) {
        return StepIndices(row: row, col: col);
      }
    }
    return null;
  }

  StepMatrix gaussBasis(StepMatrix matrix, {List<int>? basisColumns}) {
    // Создаем копию матрицы для работы
    StepMatrix A = matrix.map((row) => List<dynamic>.from(row)).toList();
    int rows = A.length;
    int cols = rows > 0 ? A[0].length : 0;

    basisColumns ??= List.generate(cols, (index) => index);

    int rowIdx = 0;
    for (int col in basisColumns) {
      if (col >= cols) {
        throw ArgumentError("Индекс столбца $col выходит за пределы матрицы.");
      }

      // Найти строку с максимальным элементом в текущем столбце
      int maxRow = rowIdx;
      double maxValue = A[rowIdx][col].abs();
      for (int i = rowIdx + 1; i < rows; i++) {
        if (A[i][col].abs() > maxValue) {
          maxRow = i;
          maxValue = A[i][col].abs();
        }
      }

      if (maxValue == 0) {
        // Столбец состоит из нулей, пропускаем
        continue;
      }

      // Поменять строки местами
      List<dynamic> temp = A[rowIdx];
      A[rowIdx] = A[maxRow];
      A[maxRow] = temp;

      // Нормализуем ведущий элемент до 1
      final leadingVal = A[rowIdx][col];
      A[rowIdx] = A[rowIdx].map((x) => x / leadingVal).toList();

      // Обнуляем элементы ниже ведущего
      for (int i = rowIdx + 1; i < rows; i++) {
        final factor = A[i][col];
        A[i] = List.generate(cols, (j) => A[i][j] - factor * A[rowIdx][j]);
      }

      rowIdx++;
      if (rowIdx >= rows) break;
    }

    // Обратный ход для приведения к канонической ступенчатой форме
    for (int col in basisColumns) {
      for (int i = rowIdx - 1; i >= 0; i--) {
        // Найти ведущий столбец в строке
        // int? leadingCol = A[i].indexWhere((val) => val.abs() > 0);
        // if (leadingCol == -1)
        //   continue; // Если ведущего элемента нет, пропускаем строку

        // Обнуляем элементы выше ведущего
        for (int j = 0; j < i; j++) {
          final factor = A[j][col];
          A[j] = List.generate(cols, (k) => A[j][k] - factor * A[i][k]);
        }
      }
    }

    // Извлекаем строки, содержащие ненулевые элементы
    return A.where((row) => row.any((x) => x.abs() > 0)).toList();
  }

  ///Возвращает опорный элемент в столбце.
  ///В случае, если не найден - [null]
  StepIndices? findSupElementInColumn(int col) {
    final stepMatrix = history.last.stepMatrix;
    var elem = _findFirstNonZeroPositiveElemInCol(
        col, lastStepMatrix, restrictionCount);
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

    StepType stepType;
    String? error;
    try {
      stepType = getStepType(stepMatrix, rowIndices, colIndices, null);
    } on SolverException catch (e) {
      stepType = StepType.error;
      error = e.message;
    }

    final step = StepInfo(
        stepMatrix: stepMatrix,
        rowIndices: rowIndices,
        colIndices: colIndices,
        type: stepType,
        error: error);
    history.add(step);
  }

  void initialSelectedStep([List<int>? basis]) {
    if (basis == null) {
      return;
    }
    final calculatedMatrix =
        gaussBasis(convertInitialMatrix(), basisColumns: basis);

    // for (var row in calculatedMatrix) {
    //   for (var elem in row) {
    //     stdout.write("${elem.reduced().toString()}, ");
    //   }
    //   print("");
    // }
    StepMatrix newStepMatrix = [];
    final rowIndices = <int>[];
    final colIndices = List.generate(basis.length, (index) => basis[index] + 1);
    for (var row in calculatedMatrix) {
      newStepMatrix.add([]);
      for (var i = 0; i < row.length; i++) {
        if (basis.contains(i)) {
          continue;
        }
        newStepMatrix.last.add(row[i]);
        if (rowIndices.length != (initialVarCount - basis.length)) {
          rowIndices.add(i + 1);
        }
      }
    }

    final lastRow = [];

    for (var col = 0; col < (rowIndices.length + 1); col++) {
      dynamic colSum = (mode == MatrixMode.fraction) ? Fraction(0, 1) : 0;
      for (var row = 0; row < colIndices.length; row++) {
        final coefIndex = colIndices[row] - 1;
        colSum += newStepMatrix[row][col] * funcCoef[coefIndex] * -1;
      }
      final addition = (col != rowIndices.length)
          ? funcCoef[rowIndices[col] - 1]
          : funcCoef[funcCoef.length - 1];
      lastRow.add(colSum + addition);
    }
    newStepMatrix.add(lastRow);

    final stepType = getStepType(newStepMatrix, rowIndices, colIndices, null);

    history.add(StepInfo(
        stepMatrix: newStepMatrix,
        rowIndices: rowIndices,
        colIndices: colIndices,
        type: stepType));
  }

  void initialStep([List<int>? basis]) {
    switch (basisMode) {
      case BasisMode.artificial:
        initialArtificialStep();
        break;
      case BasisMode.selected:
        //Если базисные переменные выбираются - нужно сначала
        //посчитать этот самый базис
        if (basis != null) {
          initialSelectedStep(basis);
        } else {
          throw SolverException(
              "Если режим решения выбранный базис, то нужно передать индексы выбранного базиса");
        }
        break;
    }
  }
}
