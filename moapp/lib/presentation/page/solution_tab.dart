import 'package:flutter/material.dart';
import 'package:moapp/core/solution_controller.dart';
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
    final solvedText = (lastStep.type == StepType.solved)
        ? "Ответ: f*=${(lastStep.stepMatrix.last.last * -1).toString()}"
        : "Решение в процессе";

    return Container(
      color: const Color(0xfff9faef),
      child: Column(
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
                    onPressed: (controller.solver!.history.length > 1)
                        ? () {
                            controller.prevStep();
                          }
                        : null,
                    child: const Text("Предыдущий шаг")),
                ElevatedButton(
                    onPressed: (lastStep.type != StepType.solved &&
                            lastStep.type != StepType.error)
                        ? () {
                            try {
                              controller.nextStep();
                            } on SolverException catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(e.message ?? "")));
                            }
                          }
                        : null,
                    child: const Text("Следующий шаг")),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    solvedText,
                    style: const TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),
          ))
        ],
      ),
    );
  }
}
