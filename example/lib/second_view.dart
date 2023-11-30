import 'package:flutter/material.dart';
import 'package:s_state/s_state.dart';


class SecondView extends StatelessWidget {
  const SecondView({super.key});

  @override
  Widget build(BuildContext context) {
    var globalNameState = SGlobalState.get<SState>(
      "name",
      orNull: () => SState("Global state Second"),
    );
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                globalNameState!.builder((loading, data, error, context) {
                  return Text("Global $data");
                }),
                ElevatedButton(
                  onPressed: () {
                    globalNameState.setState("Changed from second view");
                  },
                  child: const Text("Change"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
