import 'package:example/second_view.dart';
import 'package:flutter/material.dart';
import 'package:s_state/s_state.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final counter = SState<int>();
    final counterTwo = SState<int>();
    final counterThree = SState<int>();
    final combined = counter.combine(counterTwo, (one, two) => one * two);
    final combinedMultiple = counter.combines([counterTwo, counterThree], (others) {
      return others.fold(0, (previousValue, element) => previousValue + ((element ?? 0) as int));
    });
    final transformed = counter.transform((val) => val * 2);
    final a = transformed.combine(combined, (current, other) => current + other);
    var globalNameState = SGlobalState.get("name", orNull: () => SState("Hello word"));
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              counterView(counter),
              counterView(counterTwo),
              counterView(counterThree),
              const Text("Combined"),
              combined.builder((loading, data, error, context) => Text(loading
                  ? "no data"
                  : error != null
                      ? "$error"
                      : "$data")),
              const Text("Transformed"),
              transformed.builder((loading, data, error, context) => Text(loading
                  ? "no data"
                  : error != null
                      ? "$error"
                      : "$data")),
              const Text("Combined multiple"),
              combinedMultiple.builder((loading, data, error, context) => Text(loading
                  ? "no data"
                  : error != null
                      ? "$error"
                      : "$data")),
              SBuilder(
                state: combinedMultiple,
                builder: (loading, data, error, context) {
                  return Text("Widget builder $data");
                },
              ),
              SBuilder(
                state: a,
                builder: (loading, data, error, context) {
                  return Text("Combined to combined builder $data");
                },
              ),
              const SizedBox(height: 50),
              globalNameState!.builder((loading, data, error, context) => Text("Global $data")),
              ElevatedButton(
                onPressed: () {
                  globalNameState.setState("Changed from from home view");
                },
                child: const Text("Change"),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SecondView()));
                },
                child: const Text("Second page"),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget counterView(SState<int> counter) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 20,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              counter.builder((loading, data, error, context) {
                return Text("$data");
              }),
              ElevatedButton(
                onPressed: () {
                  counter.setState((counter.valueOrNull ?? 0) + 1);
                },
                child: const Text(
                  "Increment",
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
