import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moapp/presentation/widget/dropdown.dart';
import 'package:molib/molib.dart';

class ConditionsTab extends StatefulWidget {
  const ConditionsTab({super.key});

  @override
  State<ConditionsTab> createState() => _ConditionsTabState();
}

class _ConditionsTabState extends State<ConditionsTab> {
  final List<int> funcCoef = [0, 0, 0, 0, 0];
  int varCount = 4;
  int restrictionCount = 3;
  late final StepMatrix initMatrix = List.generate(restrictionCount,
      (_) => List.generate(varCount + 1, (_) => Fraction(0, 1)));
  final MatrixMode matrixMode = MatrixMode.fraction;
  final Set<int> errorFuncIndexes = {};

  void updateRestricionValue(int row, int col, String? value) {
    if (value == null) {
      return;
    }
    
  }

  void updateFuncCoef(int index, String value) {
    if (value.isEmpty) {
      setState(() {
        errorFuncIndexes.remove(index);
      });
      return;
    }

    final parsed = int.tryParse(value);
    if (parsed == null) {
      setState(() {
        errorFuncIndexes.add(index);
      });
      return;
    }

    errorFuncIndexes.remove(index);

    setState(() {
      funcCoef[index] = parsed;
    });
    debugPrint(funcCoef.toString());
  }

  String? emptyFieldValidator(String? value) {
    if (value != null && value.isEmpty) {
      return "Поле не может быть пустым";
    }
    return null;
  }

  void updateRestrictionCount(String value) {
    if (value == "") {
      return;
    }
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return;
    }
    for (var i = 0; i < (parsed - restrictionCount).abs(); i++) {
      if (parsed > restrictionCount) {
        initMatrix.add(List.generate(
            varCount + 1,
            (index) =>
                (matrixMode == MatrixMode.fraction) ? Fraction(0, 1) : 0.0));
      } else if (parsed < varCount) {
        initMatrix.remove(initMatrix.last);
      }
    }
    setState(() {
      restrictionCount = parsed;
    });
  }

  void updateVarCount(String value) {
    if (value == "") {
      return;
    }
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return;
    }
    for (var i = 0; i < (varCount - parsed).abs(); i++) {
      if (parsed > varCount) {
        funcCoef.add(0);
      } else if (parsed < varCount) {
        funcCoef.remove(funcCoef.last);
      }
      for (var row in initMatrix) {
        if (parsed > varCount) {
          row.add((matrixMode == MatrixMode.fraction) ? Fraction(0, 1) : 0.0);
        } else if (parsed < varCount) {
          row.remove(funcCoef.last);
        }
      }
    }
    setState(() {
      varCount = parsed;
    });
  }

  List<DataColumn> generateTableHeader() {
    return List.generate(varCount + 1, (index) {
      if (index == varCount) {
        return const DataColumn(
            headingRowAlignment: MainAxisAlignment.center,
            label: Text(
              "c",
              textAlign: TextAlign.center,
            ));
      }
      return DataColumn(
          headingRowAlignment: MainAxisAlignment.center,
          label: Text(
            "x${index + 1}",
            textAlign: TextAlign.center,
          ));
    });
  }

  List<DataRow> generateDataRows() {
    return List.generate(initMatrix.length, (index) {
      final row = initMatrix[index];
      return DataRow(
          cells: List.generate(row.length, (rowIndex) {
        return DataCell(Container(
          color: (errorFuncIndexes.contains(index))
              ? Colors.red
              : Colors.transparent,
          child: TextFormField(
            onChanged: (value) {},
            decoration: const InputDecoration(
                hintText: "0",
                border: OutlineInputBorder(borderSide: BorderSide.none)),
          ),
        ));
      }));
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
            flex: 2,
            child: Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Кол-во переменных"),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    initialValue: varCount.toString(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: updateVarCount,
                    validator: emptyFieldValidator,
                  ),
                  const Text("Кол-во ограничений"),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    initialValue: restrictionCount.toString(),
                    onChanged: updateRestrictionCount,
                    validator: emptyFieldValidator,
                  ),
                  const Text("Режим решения"),
                  const Dropdown(items: [
                    "Автоматический",
                    "Пошаговый",
                  ]),
                  const Text("Вид дробей"),
                  const Dropdown(items: ["Обыкновенные", "Десятичные"]),
                  const Text("Вид базиса"),
                  const Dropdown(items: ["Исскуственный", "Выбранный"]),
                ],
              ),
            )),
        Flexible(
            flex: 6,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Целевая функция"),
                  DataTable(columns: generateTableHeader(), rows: [
                    DataRow(
                        cells: List.generate(varCount + 1, (index) {
                      return DataCell(Container(
                        color: (errorFuncIndexes.contains(index))
                            ? Colors.red
                            : Colors.transparent,
                        child: TextFormField(
                          onChanged: (value) {
                            updateFuncCoef(index, value);
                          },
                          decoration: const InputDecoration(
                              hintText: "0",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none)),
                        ),
                      ));
                    }))
                  ]),
                  const Text("Ограничения"),
                  DataTable(
                      columns: generateTableHeader(), rows: generateDataRows()),
                ],
              ),
            ))
      ],
    );
  }
}
