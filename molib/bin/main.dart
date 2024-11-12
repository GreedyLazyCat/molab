import 'dart:math';

import 'package:molib/molib.dart';
import 'package:molib/src/artificial_solver.dart';
import 'package:molib/src/step_info.dart';

void main() {
  final initRestrictMatrix = [
    [1, 3, 3, 1, 3],
    [2, 0, 3, -1, 4]
  ];

  final funcCoef = [-1, 5, 1, -1, 0];

  final solver = ArtificialSolver(
      mode: MatrixMode.fraction,
      basisMode: BasisMode.artificial,
      varCount: 4,
      restrictionCount: 2,
      initRestrictMatrix: initRestrictMatrix,
      funcCoef: funcCoef);

  solver.initialStep();
  solver.nextStep(StepIndices(row: 0, col: 1));

  for (var step in solver.history) {
    print(step);
  }
  for (var step in solver.history) {
    print(step.stepMatrixToString());
  }
  // print(solver.supElementValidity(StepIndices(row: 1, col: 0)));
  // print(solver.findFirstSupElement());
}
