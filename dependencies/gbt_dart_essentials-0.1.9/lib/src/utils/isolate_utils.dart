import 'dart:async';
import 'dart:isolate';

// ignore:public_member_api_docs
extension IsolateUtils<T> on T {
  // ignore:public_member_api_docs
  Future<Return> isolate<Return>(FutureOr<Return> Function(T) callback) {
    // This anonymous function is required in order to separate the scope
    // Avoiding errors when sending messages across Isolates
    return Isolate.run(() => callback(this));
  }
}
