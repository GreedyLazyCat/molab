import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:moapp/core/solution_controller.dart';
import 'package:moapp/presentation/page/conditions_tab.dart';
import 'package:moapp/presentation/page/main_page.dart';
import 'package:moapp/presentation/widget/step_widget.dart';
import 'package:molib/molib.dart';
import 'package:provider/provider.dart';

class SolutionTab extends StatefulWidget {
  const SolutionTab({
    super.key,
  });

  @override
  State<SolutionTab> createState() => _SolutionTabState();
}

class _SolutionTabState extends State<SolutionTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SolutionTab oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SolutionController?>();
    if (controller == null) {
      return const Text("Нет задачи");
    }
    if (controller.solver == null) {
      return const Text("Нет задачи");
    }
    final lastStep = controller.solver!.lastStep;

    return Column(
      children: [
        Expanded(
            flex: 8,
            child: ListView.builder(
                itemCount: controller.solver!.history.length,
                itemBuilder: (context, index) {
                  return StepWidget(
                      stepInfo: controller.solver!.history[index]);
                })),
        Expanded(
            child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              ElevatedButton(
                  onPressed: () {
                    controller.nextStep();
                  },
                  child: const Text("Следующий шаг"))
            ],
          ),
        ))
      ],
    );
  }
}
