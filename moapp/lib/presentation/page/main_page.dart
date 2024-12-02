import 'package:flutter/material.dart';
import 'package:moapp/core/solution_controller.dart';
import 'package:moapp/presentation/page/conditions_tab.dart';
import 'package:moapp/presentation/page/solution_tab.dart';
import 'package:molib/molib.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPage = 0;
  SolvingMode? solvingMode;
  ArtificialSolver? solver;
  SolutionController? solutionController;

  void startSolving(newSolver, newSolvingMode) {
    setState(() {
      solver = newSolver;
      solvingMode = newSolvingMode;
      currentPage = 1;

      solutionController =
          SolutionController(solver: solver, solvingMode: newSolvingMode);
      solutionController?.initialStep();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                  icon: Icon(Icons.data_array), label: Text("Условия задачи")),
              NavigationRailDestination(
                  icon: Icon(Icons.calculate), label: Text("Решение")),
            ],
            selectedIndex: currentPage,
            onDestinationSelected: (value) {
              setState(() {
                currentPage = value;
              });
            },
          ),
          const VerticalDivider(),
          Expanded(
              child: IndexedStack(
            index: currentPage,
            children: [
              ConditionsTab(
                startSolving: startSolving,
              ),
              ChangeNotifierProvider.value(
                value: solutionController,
                child: const SolutionTab(),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
