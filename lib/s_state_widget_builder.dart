import 'package:flutter/widgets.dart';
import 'package:s_state/s_state_basic.dart';

class SBuilder<T> extends StatelessWidget {
  final SState<T> state;
  final SBuilderFunction<T> builder;
  const SBuilder({super.key, required this.state, required this.builder});

  @override
  Widget build(BuildContext context) {
    return state.builder(builder);
  }
}
