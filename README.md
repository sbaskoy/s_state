# SState Management



### Usage

#### Create basic variable

```dart

@override
Widget build(BuildContext context) {
    final counter = SState<int>();
    return Column(
        children:[
            Container(
                child:counter.builder((loading, data, error, context) {
                        return Text("$data");
                    }),
            ),
            // OR
            Container(
                child:SBuilder(
                    state:counter,
                    builder:(loading, data, error, context) {
                        return Text("$data");
                    }
                )
            ),
           ElevatedButton(
                onPressed: () {
                  counter.setState((counter.valueOrNull ?? 0) + 1);
                },
                child: const Text(
                  "Increment",
                ),
              )
        ]
    );
}
```

#### Transform variable

```dart

@override
Widget build(BuildContext context) {
    final counter = SState<int>(5);
    final transformed = counter.transform((val) => val * 2);
    return Column(
        children:[
            Container(
                // this will be update auto if counter change
                child:transformed.builder((loading, data, error, context) {
                        return Text("$data");
                }),
            ),
           ElevatedButton(
                onPressed: () {
                    // update UI
                    counter.setState((counter.valueOrNull ?? 0) + 1);
                },
                child: const Text(
                  "Increment",
                ),
              )
        ]
    );
}
```

#### Combine two variable

```dart

@override
Widget build(BuildContext context) {
    final counter = SState<int>(5);
    final counterSecond=SState<int>(5);
    final combined = counter.combine(counterSecond, (one, two) => one * two);
    return Column(
        children:[
            Container(
                // this will be update auto if counter or counterSecond change
                child:combined.builder((loading, data, error, context) {
                        return Text("$data");
                }),
            ),
            Row(
                children:[
                    ElevatedButton(
                    onPressed: () {
                            counter.setState((counter.valueOrNull ?? 0) + 1);
                        },
                        child: const Text(
                        "Increment One",
                        ),
                    ),
                    ElevatedButton(
                    onPressed: () {
                            counterSecond.setState((counterSecond.valueOrNull ?? 0) + 1);
                        },
                        child: const Text(
                        "Increment Two",
                        ),
                    ),
                ]
            )
        ]
    );
}
```

#### Combine multiple variable

```dart

@override
Widget build(BuildContext context) {
    final counter = SState<int>(5);
    final counterSecond=SState<int>(5);
    final counterThree=SState<int>(5);
    final combinedMultiple = counter.combines([counterSecond, counterThree], (others) {
      return others.fold(0, (previousValue, element) => previousValue + ((element ?? 0) as int));
    });
    return Column(
        children:[
            Container(
                child:combinedMultiple.builder((loading, data, error, context) {
                        return Text("$data");
                }),
            ),
            Row(
                children:[
                    ElevatedButton(
                        onPressed: () {
                            counter.setState((counter.valueOrNull ?? 0) + 1);
                        },
                        child: const Text(
                        "Increment One",
                        ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                            counterSecond.setState((counterSecond.valueOrNull ?? 0) + 1);
                        },
                        child: const Text(
                        "Increment Two",
                        ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                            counterSecond.setState((counterSecond.valueOrNull ?? 0) + 1);
                        },
                        child: const Text(
                        "Increment Three",
                        ),
                    ),
                ]
            )
        ]
    );
}
```

#### Use global variable

```dart
// returns old instance if it has same name ( if used before )
var globalVariable = SGlobalState.get("name", orNull: () => SState("Hello word"));

// ....
Container(
    child:globalVariable.builder((loading, data, error, context) {
            return Text("$data");
    }),
),
// .....

globalVariable.setState("update everywhere")
```
