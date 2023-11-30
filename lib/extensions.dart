import 'dart:async';

import 'package:s_state/utils.dart';

/// @internal
/// Provides [mapNotNull] extension method on [Iterable].
extension MapNotNullIterableExtension<T> on Iterable<T> {
  /// @internal
  /// The non-`null` results of calling [transform] on the elements of [this].
  ///
  /// Returns a lazy iterable which calls [transform]
  /// on the elements of this iterable in iteration order,
  /// then emits only the non-`null` values.
  ///
  /// If [transform] throws, the iteration is terminated.
  Iterable<R> mapNotNull<R>(R? Function(T) transform) sync* {
    for (final e in this) {
      final v = transform(e);
      if (v != null) {
        yield v;
      }
    }
  }

  /// @internal
  /// Maps each element and its index to a new value.
  Iterable<R> mapIndexed<R>(R Function(int index, T element) transform) sync* {
    var index = 0;
    for (final e in this) {
      yield transform(index++, e);
    }
  }
}

/// @internal
/// Extensions for [Iterable] of [StreamSubscription]s.
extension StreamSubscriptionsIterableExtensions on Iterable<StreamSubscription<void>> {
  /// @internal
  /// Pause all subscriptions.
  void pauseAll([Future<void>? resumeSignal]) {
    for (final s in this) {
      s.pause(resumeSignal);
    }
  }

  /// @internal
  /// Resume all subscriptions.
  void resumeAll() {
    for (final s in this) {
      s.resume();
    }
  }
}

/// @internal
/// Extensions for [Iterable] of [StreamSubscription]s.
extension StreamSubscriptionsIterableExtension on Iterable<StreamSubscription<void>> {
  /// @internal
  /// Cancel all subscriptions.
  Future<void>? cancelAll() => waitFuturesList([for (final s in this) s.cancel()]);
}

