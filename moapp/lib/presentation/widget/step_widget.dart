// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:moapp/core/solution_controller.dart';
import 'package:moapp/presentation/page/conditions_tab.dart';
import 'package:moapp/presentation/page/main_page.dart';
import 'package:molib/molib.dart';
import 'package:provider/provider.dart';

class StepWidget extends StatefulWidget {
  const StepWidget({super.key, required this.stepInfo});

  final StepInfo stepInfo;

  @override
  State<StepWidget> createState() => _StepWidgetState();
}

class _StepWidgetState extends State<StepWidget> {
  List<DataColumn> generateTableColumns() {
    final varCount = widget.stepInfo.rowIndices.length;
    return List.generate(varCount + 2, (index) {
      if (index == 0) {
        return const DataColumn(label: Text("*"));
      }
      if (index == (varCount + 1)) {
        return const DataColumn(label: Text("b"));
      }

      return DataColumn(
          label: Text("x${widget.stepInfo.rowIndices[index - 1]}"));
    });
  }

  List<DataRow> generateDataRows(SolutionController? controller) {
    if (controller == null) {
      return [];
    }
    final rowCount = widget.stepInfo.stepMatrix.length;
    final varCount = widget.stepInfo.rowIndices.length;
    return List.generate(rowCount, (row) {
      return DataRow(
          cells: List.generate(varCount + 2, (col) {
        if (col == 0) {
          if (row != (rowCount - 1)) {
            return DataCell(Text(
              "x${widget.stepInfo.colIndices[row]}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ));
          } else {
            return const DataCell(Text(""));
          }
        }
        final stepInfo = widget.stepInfo;
        final isCurrentStep = controller.solver?.lastStep == stepInfo;
        final stepMode = controller.solvingMode == SolvingMode.step;
        final isNotVarCoef = row != (rowCount - 1) && col != (varCount + 1);
        final isNotFinalStep = stepInfo.type != StepType.artificialFinal &&
            stepInfo.type != StepType.solved;
        final isNotNullOrNegative = (stepInfo.stepMatrix[row][col - 1] > 0);
        final stepText = (stepInfo.stepMatrix[row][col - 1] is Fraction)
            ? stepInfo.stepMatrix[row][col - 1].reduced().toString()
            : stepInfo.stepMatrix[row][col - 1].toString();
        return DataCell(SelctableCell(
          text: stepText,
          clickable: isCurrentStep &&
              stepMode &&
              isNotVarCoef &&
              isNotFinalStep &&
              isNotNullOrNegative,
          supElem:
              (isCurrentStep) ? controller.currentElem : stepInfo.elemCoord,
          cellIndices: StepIndices(row: row, col: col - 1),
        ));
      }));
    });
  }

  String getStepDescription() {
    switch (widget.stepInfo.type) {
      case StepType.artificial:
        return "Решение в процессе";
      case StepType.artificialFinal:
        return "Нахождение базиса окончено - следующий шаг вычисление основной задачи";
      case StepType.artificialIdle:
        return "Начальный шаг решения";
      case StepType.initial:
        return "Начальный шаг решения";
      case StepType.error:
        return widget.stepInfo.error ?? "Ошибка";
      case StepType.solved:
        return "Система решена";
      default:
        return "Нет описания для тип ${widget.stepInfo.type.name}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SolutionController>();
    return Column(children: [
      Text("Описание шага: ${getStepDescription()}"),
      DataTable(
          columns: generateTableColumns(), rows: generateDataRows(controller))
    ]);
  }
}

class SelctableCell extends StatefulWidget {
  const SelctableCell({
    Key? key,
    required this.text,
    required this.cellIndices,
    required this.clickable,
    this.supElem,
  }) : super(key: key);

  final String text;
  final StepIndices? supElem;
  final StepIndices cellIndices;
  final bool clickable;

  @override
  State<SelctableCell> createState() => _SelctableCellState();
}

class _SelctableCellState extends State<SelctableCell> {
  void onTap(SolutionController? controller) {
    if (controller == null) {
      return;
    }
    controller.setCurrentElem(widget.cellIndices);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<SolutionController?>();
    // debugPrint("${widget.cellIndices}  ${widget.supElem}");
    return InkWell(
      onTap: (widget.clickable)
          ? () {
              onTap(controller);
            }
          : null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 25),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: (widget.cellIndices == widget.supElem)
              ? Colors.greenAccent
              : Colors.transparent,
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
