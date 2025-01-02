// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:molib/molib.dart';

import 'package:moapp/presentation/page/conditions_tab.dart';

class SolutionController extends ChangeNotifier {
  final ArtificialSolver? solver;
  final SolvingMode solvingMode;
  StepIndices? currentElem;

  SolutionController({
    this.solver,
    required this.solvingMode,
  });

  void nextStep() {
    if (solver != null) {
      solver?.nextStep(currentElem);
      currentElem = null;
      notifyListeners();
    }
  }

  void prevStep() {
    if (solver != null) {
      solver?.prevStep();
      notifyListeners();
    }
  }

  void setCurrentElem(StepIndices elem) {
    currentElem = elem;
    notifyListeners();
  }

  void initialStep([List<int>? basis]) {
    if (solver != null) {
      if (solver?.basisMode == BasisMode.selected) {
        solver?.initialStep(basis);
      } else {
        solver?.initialStep();
      }
      if (solvingMode == SolvingMode.auto) {
        while (solver!.lastStep.type != StepType.error &&
            solver!.lastStep.type != StepType.solved) {
          solver!.nextStep();
        }
      }
      notifyListeners();
    }
  }
}
