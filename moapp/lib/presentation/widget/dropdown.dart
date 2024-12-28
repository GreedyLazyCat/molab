import 'package:flutter/material.dart';

class Dropdown extends StatefulWidget {
  const Dropdown(
      {super.key, required this.items, this.onChanged, required this.current});

  final List<String> items;
  final Function(String)? onChanged;
  final String current;

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
  void didUpdateWidget(covariant Dropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current &&
        mounted &&
        widget.items.contains(widget.current)) {
      setState(() {
        value = widget.current!;
        if (widget.onChanged != null) {
          // widget.onChanged!(value);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
        value: widget.current,
        items: widget.items
            .map((elem) => DropdownMenuItem(value: elem, child: Text(elem)))
            .toList(),
        onChanged: (newValue) {
          if (newValue == null) {
            return;
          }
          if (widget.onChanged != null) {
            widget.onChanged!(newValue);
          }
          
        });
  }
}
