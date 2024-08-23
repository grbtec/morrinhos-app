part of 'gbt_getx_observable.dart';


class Rx<T> extends ValueNotifier<T>{
  Rx(super.value);

  T get value {
    RxNotifier.proxy?.addRx(this);
    return super.value;
  }


  T call([T? v]) {
    if (v != null) {
      value = v;
    }
    return value;
  }

  /// Same as dispose but keeping compatibility with GetX
  void close(){
    super.dispose();
  }

  @Deprecated("Prefer to use close() in order to keep compatibility with GetX")
  @override
  void dispose(){
    super.dispose();
  }
}