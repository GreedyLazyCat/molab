// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:molib/molib.dart';
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
typedef FractionMatrix = List<List<Fraction>>;
typedef DoubleMatrix = List<List<double>>;
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
  });

  void clearHistory() {
    history.clear();
  }

  ///Метод делает следующий шаг в решении метода исскуственного базиса.
  ///[i] и [j] "координаты" базисного элемента
  void nextStep(int i, int j) {
    throw UnimplementedError();
  }

  void initialArtificialStep() {
    final List<int> rowIndicies = List.generate(varCount, (index) => index + 1);
    final List<int> colIndicies =
        List.generate(restrictionCount, (index) => varCount + index + 1);

    final stepMatrix = initRestrictMatrix
        .map((e) => e.map((to) {
              if (mode == MatrixMode.fraction) {
                return Fraction(to, 1);
              } else if (mode == MatrixMode.floating) {
                return to.toDouble();
              }
            }).toList())
        .toList();

    // stepMatrix.add(lastRow);

    final step = StepInfo(
        i: -1,
        j: -1,
        stepMatrix: stepMatrix,
        rowIndicies: rowIndicies,
        colIndicies: colIndicies);
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

    for (var index in last.rowIndicies) {
      result += "$index ";
    }

    result += "\nИндексы базисных переменных\n";

    for (var index in last.colIndicies) {
      result += "$index ";
    }
    return result;
  }
}
