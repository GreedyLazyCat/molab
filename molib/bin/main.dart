import 'dart:math';

import 'package:molib/molib.dart';
import 'package:molib/src/artificial_solver.dart';
import 'package:molib/src/step_info.dart';

void main() {
  Fraction f1 = Fraction(-1, 1);
  Fraction f2 = Fraction(-1, 2);
  Fraction f3 = Fraction(-5, 2);

  final initRestrictMatrix = [
    [1, -1, 1, 3],
    [2, -5, -1, 0],
  ];

  final funcCoef = [-1, -4, -1];

  final solver = ArtificialSolver(
      mode: MatrixMode.fraction,
      basisMode: BasisMode.artificial,
      varCount: 3,
      restrictionCount: 2,
      initRestrictMatrix: initRestrictMatrix,
      funcCoef: funcCoef);

  solver.initialStep();
  
  solver.nextStep(StepIndices(row: 1, col: 0));
  solver.nextStep(StepIndices(row: 0, col: 1));

  for (var step in solver.history) {
    print(step.type.name);
    print(step.stepMatrixToString());
  }
}
