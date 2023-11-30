import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:s_state/extensions.dart';

typedef SBuilderFunction<R> = Widget Function(
  bool loading,
  R? data,
  dynamic error,
  BuildContext context,
);

typedef SCombinerSingleFunction<R, T> = R Function(T current, dynamic other);
typedef SCombinerMultipleFunction<R, T> = R Function(List<T> others);

abstract class SBaseState<T> {
  final StreamController<T> _controller = StreamController<T>.broadcast();
  final _Wrapper<T> _wrapper = _Wrapper<T>();
  T? _initialData;
  T? get valueOrNull => _wrapper.value;
  Widget builder(SBuilderFunction<T> builder);
  SReadOnlyState<R> combine<R>(SBaseState other, SCombinerSingleFunction<R, T> transformer);
  SReadOnlyState<R> combines<R>(List<SBaseState> others, SCombinerMultipleFunction<R, dynamic> combiner);
  SReadOnlyState<R> transform<R>(R Function(T value) transformer);
}

class _SBaseState<T> extends SBaseState {
  @override
  Widget builder(SBuilderFunction<T> builder) {
    return StreamBuilder(
      stream: _controller.stream,
      // initialData: _initialData,
      builder: (context, snapshot) {
        var loading = ((snapshot.data ?? valueOrNull ?? _initialData) == null) && (!snapshot.hasError);
        return builder(loading, snapshot.data ?? valueOrNull ?? _initialData, snapshot.error, context);
      },
    );
  }

  @override
  SReadOnlyState<R> combine<R>(SBaseState other, SCombinerSingleFunction<R, T> transformer) {
    var t = _CombinerStream.combineTwo(this, other, (current, other) {
      return transformer(current, other);
    });
    var initial =
        (valueOrNull != null && other.valueOrNull != null) ? transformer(valueOrNull as T, other.valueOrNull) : null;
    return SReadOnlyState._fromStream(t.stream, initial);
  }

  @override
  SReadOnlyState<R> combines<R>(List<SBaseState> others, SCombinerMultipleFunction<R, dynamic> combiner) {
    var defaultValues = [_initialData, ...others.map((e) => e._initialData)];
    var streams = [_controller.stream, ...others.map((e) => e._controller.stream)];
    var t = _CombinerStream._combine(
      streams: streams,
      combiner: (values) {
        return combiner(values);
      },
      defaultValues: defaultValues,
    );
    var initial = (defaultValues.length == streams.length) ? combiner(defaultValues) : null;
    return SReadOnlyState._fromStream(t.stream, initial);
  }

  @override
  SReadOnlyState<R> transform<R>(R Function(T value) transformer) {
    var t = _controller.stream.map((event) => transformer(event));
    var initial = _initialData != null ? transformer(_initialData as T) : null;
    return SReadOnlyState._fromStream(t, initial);
  }
}

class SState<T> extends _SBaseState<T> {
  SState([T? initialVal]) {
    _initialData = initialVal;
    if (initialVal != null) {
      setState(initialVal);
    }
  }

  T setState(T item) {
    _controller.add(item);
    _wrapper.setValue(item);
    return item;
  }

  void setError(dynamic error) {
    _controller.addError(error);
    _wrapper.setError(error);
  }
}

class SReadOnlyState<T> extends _SBaseState<T> {
  SReadOnlyState._fromStream(Stream<T> stream, [T? initialData]) {
    _initialData = initialData;
    stream.listen(_setState);
    if (initialData != null) {
      _setState(initialData);
    }
  }
  T _setState(T item) {
    _controller.add(item);
    _wrapper.setValue(item);
    return item;
  }
}

class _Wrapper<T> {
  bool isValue;
  T? value;
  _Wrapper() : isValue = false;

  void setValue(T event) {
    value = event;
    isValue = true;
  }

  void setError(Object error) {
    isValue = false;
  }
}

class _CombinerStream<T> {
  _CombinerStream._();
  static StreamController<R> combineTwo<R, A, B>(
      SBaseState<A> one, SBaseState<B> two, SCombinerSingleFunction<R, A> combiner) {
    var streams = [
      one._controller.stream,
      two._controller.stream,
    ];
    return _CombinerStream._combine(
      streams: streams,
      combiner: (values) {
        var oneVal = values[0];
        var twoVal = values[1];
        if (oneVal != null && twoVal != null) {
          return combiner(oneVal as A, twoVal);
        }
        return null;
      },
      defaultValues: [one._initialData, two._initialData],
    );
  }

  static StreamController<R> _combine<T, R>({
    required Iterable<Stream<T>> streams,
    required R? Function(List<T> values) combiner,
    List<T?>? defaultValues,
  }) {
    final controller = StreamController<R>(sync: true);
    late List<StreamSubscription<T>> subscriptions;
    List<T?>? values = streams.length == defaultValues?.length ? defaultValues : null;

    controller.onListen = () {
      var completed = 0;

      void onDone() {
        if (++completed == subscriptions.length) {
          controller.close();
        }
      }

      subscriptions = streams.mapIndexed((index, stream) {
        return stream.listen(
          (T value) {
            if (values == null) {
              return;
            }

            values![index] = value;

            final R? combined;
            try {
              combined = combiner(List<T>.unmodifiable(values!));
            } catch (e, s) {
              controller.addError(e, s);
              return;
            }
            if (combined != null) {
              controller.add(combined);
            }
          },
          onError: controller.addError,
          onDone: onDone,
        );
      }).toList(growable: false);
      if (subscriptions.isEmpty) {
        controller.close();
      } else {
        values =
            (streams.length == defaultValues?.length ? defaultValues : List<T?>.filled(subscriptions.length, null));
      }
    };
    controller.onPause = () => subscriptions.pauseAll();
    controller.onResume = () => subscriptions.resumeAll();
    controller.onCancel = () {
      values = defaultValues;
      return subscriptions.cancelAll();
    };

    return controller;
  }
}
