// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:molib/molib.dart';

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

      return DataColumn(label: Text("x$index"));
    });
  }

  List<DataRow> generateDataRows() {
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

        return DataCell(Text("${widget.stepInfo.stepMatrix[row][col - 1]}"));
      }));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DataTable(columns: generateTableColumns(), rows: generateDataRows());
  }
}

class SelctableCell extends StatefulWidget {
  const SelctableCell({
    Key? key,
    required this.text,
    required this.selectable,
    this.supElem,
    required this.indices,
    required this.onSelected,
  }) : super(key: key);

  final String text;
  final bool selectable;
  final StepIndices? supElem;
  final StepIndices? indices;
  final Function(StepIndices) onSelected;

  @override
  State<SelctableCell> createState() => _SelctableCellState();
}

class _SelctableCellState extends State<SelctableCell> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: (widget.indices == widget.supElem)
          ? Colors.transparent
          : Colors.greenAccent,
      child: Text(widget.text),
    );
  }
}
