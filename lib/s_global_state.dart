class SGlobalState {
  static SGlobalState? _instance;
  static SGlobalState get _i {
    _instance ??= SGlobalState._init();
    return _instance!;
  }

  SGlobalState._init();
  Map<String, dynamic> items = {};

  static void _set(String name, dynamic state) {
    _i.items[name] = state;
  }

  static T? get<T>(String name, {T Function()? orNull}) {
    var item = _i.items[name];

    var res = item ?? (orNull != null ? orNull() : null);
    if (item == null && res != null) {
      _set(name, res);
    }
    if (res != null) {
      return res as T;
    }
    return null;
  }
}
