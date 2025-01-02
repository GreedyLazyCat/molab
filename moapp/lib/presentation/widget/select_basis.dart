import 'package:flutter/material.dart';
import 'package:moapp/presentation/widget/dropdown.dart';

class SelectBasis extends StatefulWidget {
  const SelectBasis(
      {super.key,
      required this.basisVarCount,
      required this.varCount,
      required this.onChange});

  final int basisVarCount;
  final int varCount;
  final Function(List<int>) onChange;

  @override
  State<SelectBasis> createState() => _SelectBasisState();
}

class _SelectBasisState extends State<SelectBasis> {
  late var currentValues = List.generate(widget.basisVarCount, (i) => i + 1);
  late var vars = List.generate(widget.varCount, (i) => i + 1).toSet();

  List<Widget> generateSelectors() {
    return List.generate(widget.basisVarCount, (index) {
      final sub = vars.difference(currentValues.toSet());
      final items = sub.map((elem) => elem.toString()).toList();
      items.add(currentValues[index].toString());
      return Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Dropdown(
            onChanged: (value) {
              setState(() {
                currentValues[index] = int.parse(value);
              });
              widget.onChange(currentValues);
            },
            items: items,
            current: currentValues[index].toString()),
      );
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant SelectBasis oldWidget) {
    super.didUpdateWidget(oldWidget);

    currentValues = List.generate(widget.basisVarCount, (i) => i + 1);
    vars = List.generate(widget.varCount, (i) => i + 1).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text("Выбор базисных переменных"),
        Row(
          // crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: generateSelectors(),
        )
      ],
    );
  }
}
