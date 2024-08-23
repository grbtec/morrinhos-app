import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/foundation.dart';

class ExceptionHandler{

  /// noConnection
  static Future<Result<T>> convertToNoConnectionResult<T>(FutureOr<Result<T>> Function() callback) async {
    try {
      return await callback();
    } catch (error, stackTrace) {
      // Do not send exception for connection error (it's more common than expected)
      // Just log it in crashlytics just in case it cause more problems later
      if(_isConnectionError(error)){
        if(kDebugMode){
          print("\x1B[31m$error\x1B[0m");
        }
      }else{
        unawaited(
            Future.microtask(() => Error.throwWithStackTrace(error, stackTrace)));
      }
      return Result.error("Sem conexão");
    }
  }

  static bool _isConnectionError(Object error){
    // TODO: do not send exception for connection error (it's more common than expected)
    return false;
  }
}

