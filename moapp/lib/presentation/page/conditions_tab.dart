import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moapp/presentation/widget/dropdown.dart';
import 'package:molib/molib.dart';

typedef StringMatrix = List<List<String>>;
typedef ControllerMatrix = List<List<TextEditingController>>;

enum SolvingMode { step, auto }

class ConditionsTab extends StatefulWidget {
  const ConditionsTab({super.key, required this.startSolving});
  final Function(ArtificialSolver, SolvingMode) startSolving;

  @override
  State<ConditionsTab> createState() => _ConditionsTabState();
}

class _ConditionsTabState extends State<ConditionsTab> {
  final List<int> funcCoef = [0, 0, 0, 0, 0];
  final List<TextEditingController> funcCoefControllers =
      List.generate(5, (index) => TextEditingController());
  final Set<int> errorFuncIndices = {};
  final Set<(int, int)> errorMatrixIndices = {};
  int varCount = 4;
  int restrictionCount = 3;
  late final StringMatrix initMatrix = List.generate(
      restrictionCount, (_) => List.generate(varCount + 1, (_) => "0"));
  late final ControllerMatrix controllerMatrix = List.generate(restrictionCount,
      (_) => List.generate(varCount + 1, (_) => TextEditingController()));
  MatrixMode matrixMode = MatrixMode.fraction;
  BasisMode basisMode = BasisMode.artificial;
  SolvingMode solvingMode = SolvingMode.auto;

  TextEditingController restrictionCountController = TextEditingController();
  TextEditingController varCountController = TextEditingController();

  String matrixModeCurrent = "Обыкновенные";
  String basisModeCurrent = "Исскуственный";
  String solvingModeCurrent = "Автоматический";

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
      controllerMatrix[row][col].text = value;
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
      funcCoefControllers[index].text = value;
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
        controllerMatrix.add(
            List.generate(varCount + 1, (index) => TextEditingController()));
      } else if (parsed < varCount) {
        initMatrix.remove(initMatrix.last);
        controllerMatrix.remove(controllerMatrix.last);
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
        funcCoefControllers.add(TextEditingController());
      } else if (parsed < varCount) {
        funcCoef.remove(funcCoef.last);
        funcCoefControllers.remove(funcCoefControllers.last);
      }
      for (var row in initMatrix) {
        if (parsed > varCount) {
          row.add("0");
        } else if (parsed < varCount) {
          row.remove(row.last);
        }
      }
      for (var row in controllerMatrix) {
        if (parsed > varCount) {
          row.add(TextEditingController());
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
      final controllerRow = controllerMatrix[index];
      return DataRow(
          cells: List.generate(row.length, (rowIndex) {
        return DataCell(Container(
          color: (errorMatrixIndices.contains((index, rowIndex)))
              ? Colors.red
              : Colors.transparent,
          child: TextFormField(
            controller: controllerRow[rowIndex],
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
    setState(() {
      matrixModeCurrent = value;
    });
  }

  void basisModeChanged(String value) {
    if (value == "Исскуственный") {
      basisMode = BasisMode.artificial;
    } else {
      basisMode = BasisMode.artificial;
    }
    setState(() {
      basisModeCurrent = value;
    });
  }

  void solvingModeChanged(String value) {
    if (value == "Автоматический") {
      solvingMode = SolvingMode.auto;
    } else {
      solvingMode = SolvingMode.step;
    }
    setState(() {
      solvingModeCurrent = value;
    });
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

  void openFileSelectorClicked() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      final fileString = await file.readAsString();
      try {
        final conditions = await jsonDecode(fileString) as Map<String, dynamic>;
        final newRestrictionCount = conditions["restriction_count"] as int;
        final newVarCount = conditions["var_count"] as int;
        final newSolvingMode = conditions["solving_mode"] as String;
        final newMatrixMode = conditions["matrix_mode"] as String;
        final newBasisMode = conditions["basis_mode"] as String;
        final newInitMatrix = (conditions["init_matrix"] as List<dynamic>);
        final newFuncCoef = (conditions["func_coef"] as List<dynamic>);
        if (!["auto", "step"].contains(newSolvingMode)) {
          showSnackBar("Неправильное значение solving_mode");
          return;
        }
        if (!["fraction", "double"].contains(newMatrixMode)) {
          showSnackBar("Неправильное значение matrix_mode");
          return;
        }
        if (!["artificial", "selected"].contains(newBasisMode)) {
          showSnackBar("Неправильное значений полей");
          return;
        }

        if (newFuncCoef.length != (newVarCount + 1)) {
          showSnackBar(
              "Кол-во коэффициентов функции не соответствует кол-ву переменных");
          return;
        }
        if (newInitMatrix.length != newRestrictionCount) {
          showSnackBar("Не правильный формат матрицы ограничений");
          return;
        }

        for (var row in newInitMatrix) {
          var matrixRow =
              (row as List<dynamic>).map((elem) => elem as int).toList();
          if (matrixRow.length != (newVarCount + 1)) {
            showSnackBar("Кол-во столбцов не соответствует кол-ву переменных");
            return;
          }
        }

        updateVarCount(newVarCount.toString());
        varCountController.text = newVarCount.toString();
        updateRestrictionCount(newRestrictionCount.toString());
        restrictionCountController.text = newRestrictionCount.toString();
        setState(() {
          matrixModeChanged(
              (newMatrixMode == "fraction") ? "Обыкновенные" : "Десятичные");
          basisModeChanged(
              (newBasisMode == "artificial") ? "Исскуственный" : "Выбранный");
          solvingModeChanged(
              (newSolvingMode == "step") ? "Пошаговый" : "Автоматический");
        });
        for (var i = 0; i < newFuncCoef.length; i++) {
          updateFuncCoef(i, newFuncCoef[i].toString());
        }
        for (var i = 0; i < newInitMatrix.length; i++) {
          var matrixRow = (newInitMatrix[i] as List<dynamic>)
              .map((elem) => elem as int)
              .toList();
          for (var j = 0; j < matrixRow.length; j++) {
            updateRestricionValue(i, j, matrixRow[j].toString());
          }
        }
      } on FormatException {
        showSnackBar("Неправильный формат файла");
      }
      // on TypeError {
      //   showSnackBar("Неправильный формат числовых значений");
      // }
    }
  }

  void saveFileSelectorClicked() async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Выберете файл для сохранения',
      fileName: 'task-conditions.txt',
    );

    if (outputFile != null) {
      File file = File(outputFile);
      final toWrite = {};
      toWrite["init_matrix"] = List.generate(
          initMatrix.length,
          (index) =>
              initMatrix[index].map((elem) => int.tryParse(elem)).toList());
      toWrite["func_coef"] = List.from(funcCoef);
      toWrite["restriction_count"] = restrictionCount;
      toWrite["var_count"] = varCount;
      toWrite["solving_mode"] = solvingMode.name;
      toWrite["matrix_mode"] = matrixMode.name;
      toWrite["basis_mode"] = basisMode.name;

      file.writeAsString(jsonEncode(toWrite));
      /*
  	  "solving_mode": "step",
  	  "matrix_mode": "double",
  	  "basis_mode": "selected",
      */
    }
  }

  void showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void initState() {
    super.initState();
    restrictionCountController.text = restrictionCount.toString();
    varCountController.text = varCount.toString();
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: updateVarCount,
                    validator: emptyFieldValidator,
                    controller: varCountController,
                  ),
                  const Text("Кол-во ограничений"),
                  TextFormField(
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: updateRestrictionCount,
                    validator: emptyFieldValidator,
                    controller: restrictionCountController,
                  ),
                  const Text("Режим решения"),
                  Dropdown(
                    items: const [
                      "Автоматический",
                      "Пошаговый",
                    ],
                    current: solvingModeCurrent,
                    onChanged: solvingModeChanged,
                  ),
                  const Text("Вид дробей"),
                  Dropdown(
                    items: const ["Обыкновенные", "Десятичные"],
                    current: matrixModeCurrent,
                    onChanged: matrixModeChanged,
                  ),
                  const Text("Вид базиса"),
                  Dropdown(
                    items: const ["Исскуственный", "Выбранный"],
                    current: basisModeCurrent,
                    onChanged: basisModeChanged,
                  ),
                  ElevatedButton(
                      style: const ButtonStyle(
                          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))))),
                      onPressed: startSolvingClicked,
                      child: const Text("Перейти к решению")),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                        style: const ButtonStyle(
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10))))),
                        onPressed: openFileSelectorClicked,
                        child: const Text("Открыть задачу из файла")),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                        style: const ButtonStyle(
                            shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10))))),
                        onPressed: saveFileSelectorClicked,
                        child: const Text("Сохранить задачу в файл")),
                  ),
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
                          controller: funcCoefControllers[index],
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
