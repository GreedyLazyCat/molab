import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:moapp/presentation/page/conditions_tab.dart';
import 'package:moapp/presentation/widget/step_widget.dart';
import 'package:molib/molib.dart';

class SolutionTab extends StatefulWidget {
  const SolutionTab({super.key, this.solver, this.solvingMode});

  final ArtificialSolver? solver;
  final SolvingMode? solvingMode;

  @override
  State<SolutionTab> createState() => _SolutionTabState();
}

class _SolutionTabState extends State<SolutionTab> {
  @override
  void initState() {
    super.initState();
    if (widget.solver != null) {
      widget.solver!.initialStep();
    }
  }

  @override
  void didUpdateWidget(covariant SolutionTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.solver != null) {
      widget.solver!.initialStep();
      widget.solver!.nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget test = Text("No solver");
    if (widget.solver != null) {
      if (widget.solver!.history.isNotEmpty) {
        test = StepWidget(stepInfo: widget.solver!.lastStep,);
      }
    }
    return Center(
      child: test,
    );
  }
}
