import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  const Dropdown({super.key, required this.items});

  final List<String> items;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  late String value;

  @override
  void initState() {
    super.initState();
    value = widget.items.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        value: value,
        items: widget.items
            .map((elem) => DropdownMenuItem(value: elem, child: Text(elem)))
            .toList(),
        onChanged: (newValue) {
          setState(() {
            value = newValue ?? "";
          });
        });
  }
}
