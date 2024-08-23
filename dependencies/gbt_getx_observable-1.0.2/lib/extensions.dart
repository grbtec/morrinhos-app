import 'gbt_getx_observable.dart';

extension ObservableExtensions<T> on T{
  Rx<T> get obs{
    return Rx(this);
  }
}