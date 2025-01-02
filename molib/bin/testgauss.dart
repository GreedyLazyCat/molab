import 'package:molib/molib.dart';
import 'package:molib/src/exception/solver_exception.dart';

void main() {
  // final initRestrictMatrix = [
  //   [2, -1, 1, -2, 1, 1, 1],
  //   [-3, 1, 0, 1, -1, 1, 2],
  //   [-5, 1, -2, 1, 0, -1, 3],
  // ];

  final initRestrictMatrix = [
    [1, -1, 1, 3],
    [2, -5, -1, 0],
  ];

  final funcCoef = [-1, -4, -1, 0];
  // final funcCoef = [-5, 2, -2, 4, -1, -2, 0];

  final solver = ArtificialSolver(
      mode: MatrixMode.fraction,
      basisMode: BasisMode.artificial,
      initialVarCount: 3,
      initialRestrictionCount: 2,
      initRestrictMatrix: initRestrictMatrix,
      funcCoef: funcCoef);

  try {
    // solver.initialStep();
    // solver.nextStep();
    // solver.nextStep(StepIndices(row: 1, col: 1));
    // solver.nextStep(StepIndices(row: 1, col: 2));
  } on SolverException catch (e) {
    print(e.message);
  }
  // solver.nextStep();

  // for (var step in solver.history) {
  //   print("-------------------------");
  //   print("Type: ${step.type.name}");
  //   print("Coords: ${step.elemCoord.toString()}");
  //   print(step.error ?? "No errors");
  //   print("-------------------------");
  //   print(step.fullMatrixToString());
  // }
  final result =
      solver.gaussBasis(solver.convertInitialMatrix(), basisColumns: [1, 2, 3]);
}
