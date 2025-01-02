import 'dart:io';
import 'dart:math';

import 'package:molib/src/artificial_solver.dart';
import 'package:molib/src/exception/solver_exception.dart';
import 'package:molib/src/step_info.dart';

void main() {
  // final initRestrictMatrix = [
  //   [2, -1, 1, -2, 1, 1, 1],
  //   [-3, 1, 0, 1, -1, 1, 2],
  //   [-5, 1, -2, 1, 0, -1, 3],
  // ];

  final initRestrictMatrix = [
    [1, 2, 3, 4],
    [5, 6, 7, 8],
  ];

  final funcCoef = [1, 2, 0, 9];
  // final funcCoef = [-5, 2, -2, 4, -1, -2, 0];

  final solver = ArtificialSolver(
      mode: MatrixMode.fraction,
      basisMode: BasisMode.selected,
      initialVarCount: 3,
      initialRestrictionCount: 2,
      initRestrictMatrix: initRestrictMatrix,
      funcCoef: funcCoef);

  try {
    solver.initialStep([0, 1]);
    solver.nextStep();
    // solver.nextStep(StepIndices(row: 1, col: 1));
    // solver.nextStep(StepIndices(row: 1, col: 2));
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
  // final result =
  //     solver.gaussBasis(solver.convertInitialMatrix(), basisColumns: [1, 2, 4]);
  // for (var row in result) {
  //   for (var elem in row) {
  //     stdout.write("${elem.reduced().toString()}, ");
  //   }
  //   print("");
  // }
}
