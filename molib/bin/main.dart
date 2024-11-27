import 'dart:math';

import 'package:molib/src/artificial_solver.dart';
import 'package:molib/src/exception/solver_exception.dart';
import 'package:molib/src/step_info.dart';

void main() {
  final initRestrictMatrix = [
    [2, -1, 1, -2, 1, 1, 1],
    [-3, 1, 0, 1, -1, 1, 2],
    [-5, 1, -2, 1, 0, -1, 3],
  ];

  final funcCoef = [-5, 2, -2, 4, -1, -2, 0];

  final solver = ArtificialSolver(
      mode: MatrixMode.fraction,
      basisMode: BasisMode.artificial,
      initialVarCount: 6,
      initialRestrictionCount: 3,
      initRestrictMatrix: initRestrictMatrix,
      funcCoef: funcCoef);

  try {
    solver.initialStep();
    solver.nextStep();
    solver.nextStep();
    solver.nextStep();
    solver.nextStep();
    solver.nextStep();
  } on SolverException catch (e) {
    print(e.message);
  }
  // solver.nextStep();

  for (var step in solver.history) {
    print("-------------------------");
    print("Type: ${step.type.name}");
    print("Coords: ${step.elemCoord.toString()}");
    print(step.error ?? "No errors");
    print("-------------------------");
    print(step.fullMatrixToString());
  }

  // final step = solver.lastStep;
  // final newStep = solver.makeStepAfterArtificialFinal(step);
  // print(newStep.fullMatrixToString());
}
