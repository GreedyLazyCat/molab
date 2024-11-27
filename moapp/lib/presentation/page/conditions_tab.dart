import 'package:flutter/material.dart';

class ConditionsTab extends StatefulWidget {
  const ConditionsTab({super.key});

  @override
  State<ConditionsTab> createState() => _ConditionsTabState();
}

class _ConditionsTabState extends State<ConditionsTab> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Conditions"),
    );
  }
}
