import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moapp/presentation/widget/dropdown.dart';
import 'package:molib/molib.dart';

typedef StringMatrix = List<List<String>>;

enum SolvingMode { step, auto }

class ConditionsTab extends StatefulWidget {
  const ConditionsTab({super.key, required this.startSolving});
  final Function(ArtificialSolver, SolvingMode) startSolving;

  @override
  State<ConditionsTab> createState() => _ConditionsTabState();
}

class _ConditionsTabState extends State<ConditionsTab> {
  final List<int> funcCoef = [0, 0, 0, 0, 0];
  final Set<int> errorFuncIndices = {};
  final Set<(int, int)> errorMatrixIndices = {};
  int varCount = 4;
  int restrictionCount = 3;
  late final StringMatrix initMatrix = List.generate(
      restrictionCount, (_) => List.generate(varCount + 1, (_) => "0"));
  MatrixMode matrixMode = MatrixMode.fraction;
  BasisMode basisMode = BasisMode.artificial;
  SolvingMode solvingMode = SolvingMode.auto;

  dynamic tryParseValue(String value) {
    if (matrixMode == MatrixMode.fraction) {
      return Fraction.tryParse(value);
    } else {
      return double.tryParse(value);
    }
  }

  void updateRestricionValue(int row, int col, String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        errorMatrixIndices.remove((row, col));
      });
      return;
    }
    int? parsed = int.tryParse(value);

    if (parsed == null) {
      setState(() {
        errorMatrixIndices.add((row, col));
      });
      return;
    }
    errorMatrixIndices.remove((row, col));
    setState(() {
      initMatrix[row][col] = value;
    });
  }

  void updateFuncCoef(int index, String value) {
    if (value.isEmpty) {
      setState(() {
        errorFuncIndices.remove(index);
      });
      return;
    }

    final parsed = int.tryParse(value);
    if (parsed == null) {
      setState(() {
        errorFuncIndices.add(index);
      });
      return;
    }

    errorFuncIndices.remove(index);

    setState(() {
      funcCoef[index] = parsed;
    });
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
        initMatrix.add(List.generate(varCount + 1, (index) => "0"));
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
          row.add("0");
        } else if (parsed < varCount) {
          row.remove(row.last);
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
          color: (errorMatrixIndices.contains((index, rowIndex)))
              ? Colors.red
              : Colors.transparent,
          child: TextFormField(
            onChanged: (value) {
              updateRestricionValue(index, rowIndex, value);
            },
            decoration: const InputDecoration(
                hintText: "0",
                border: OutlineInputBorder(borderSide: BorderSide.none)),
          ),
        ));
      }));
    });
  }

  void matrixModeChanged(String value) {
    if (value == "Обыкновенные") {
      matrixMode = MatrixMode.fraction;
    } else {
      matrixMode = MatrixMode.double;
    }
    setState(() {});
  }

  void basisModeChanged(String value) {
    if (value == "Исскуственный") {
      basisMode = BasisMode.artificial;
    } else {
      basisMode = BasisMode.artificial;
    }
    setState(() {});
  }

  void solvingModeChanged(String value) {
    if (value == "Автоматический") {
      solvingMode = SolvingMode.auto;
    } else {
      solvingMode = SolvingMode.step;
    }
    setState(() {});
  }

  void startSolvingClicked() {
    List<List<int>> matrix = List.generate(
        initMatrix.length,
        (row) => List.generate(
            initMatrix[row].length, (col) => int.parse(initMatrix[row][col])));
    final solver = ArtificialSolver(
        mode: matrixMode,
        basisMode: basisMode,
        initialVarCount: varCount,
        initialRestrictionCount: restrictionCount,
        initRestrictMatrix: matrix,
        funcCoef: List.from(funcCoef));
    widget.startSolving(solver, solvingMode);
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
                  Dropdown(
                    items: const [
                      "Автоматический",
                      "Пошаговый",
                    ],
                    onChanged: solvingModeChanged,
                  ),
                  const Text("Вид дробей"),
                  Dropdown(
                    items: const ["Обыкновенные", "Десятичные"],
                    onChanged: matrixModeChanged,
                  ),
                  const Text("Вид базиса"),
                  Dropdown(
                    items: const ["Исскуственный", "Выбранный"],
                    onChanged: basisModeChanged,
                  ),
                  ElevatedButton(
                      style: const ButtonStyle(
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))))),
                      onPressed: startSolvingClicked,
                      child: const Text("Перейти к решению"))
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
                        color: (errorFuncIndices.contains(index))
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
