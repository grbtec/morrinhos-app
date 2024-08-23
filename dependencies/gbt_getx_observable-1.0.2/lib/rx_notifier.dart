part of 'gbt_getx_observable.dart';

class RxNotifier extends ChangeNotifier {
  static RxNotifier? proxy;
  final _subscriptions = <Rx<Object?>, VoidCallback>{};

  bool get canUpdate => _subscriptions.isNotEmpty;

  void addRx<T>(Rx<T> rx) {
    if (!_subscriptions.containsKey(rx)) {
      void rxListener() {
        notifyListeners();
      }

      rx.addListener(rxListener);
      _subscriptions.addAll({rx: rxListener});
    }
  }

  static Widget notifyChildren<T>(
      RxNotifier observer, ValueGetter<Widget> builder) {
    final oldObserver = RxNotifier.proxy;
    RxNotifier.proxy = observer;
    final result = builder();

    RxNotifier.proxy = oldObserver;
    assert(observer.canUpdate, """
      (!!GBT MODIFICATION!!)
      [Get] the improper use of a GetX has been detected. 
      You should only use GetX or Obx for the specific widget that will be updated.
      If you are seeing this error, you probably did not insert any observable variables into GetX/Obx 
      or insert them outside the scope that GetX considers suitable for an update 
      (example: GetX => HeavyWidget => variableObservable).
      If you need to update a parent widget and a child widget, wrap each one in an Obx/GetX.
      """);
    return result;
  }

  @override
  void dispose() {
    _subscriptions.forEach((key, value) {
      key.removeListener(value);
    });
    super.dispose();
  }
}
