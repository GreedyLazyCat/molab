import 'package:flutter/material.dart';
import 'package:moapp/presentation/page/conditions_tab.dart';
import 'package:moapp/presentation/page/solution_tab.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPage = 0;
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
            children: const [ConditionsTab(), SolutionTab()],
          ))
        ],
      ),
    );
  }
}
