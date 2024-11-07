import 'dart:math';

import 'package:molib/molib.dart';
import 'package:molib/src/artificial_solver.dart';

void main() {
  final varCount = 4;
  final restrictionCount = 3;
  final solver = ArtificialSolver(
      mode: MatrixMode.fraction,
      basisMode: BasisMode.artificial,
      varCount: varCount,
      restrictionCount: restrictionCount,
      initRestrictMatrix: List.filled(restrictionCount,
          List.generate(varCount, (index) => Random.secure().nextInt(50))),
      funcCoef: List.filled(varCount + 1, 0));
  solver.initialStep();
  print(solver.tempToString());
}
