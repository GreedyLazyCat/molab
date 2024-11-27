import 'package:flutter/material.dart';

class SolutionTab extends StatefulWidget {
  const SolutionTab({super.key});

  @override
  State<SolutionTab> createState() => _SolutionTabState();
}

class _SolutionTabState extends State<SolutionTab> {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("Solution"),
    );
  }
}
