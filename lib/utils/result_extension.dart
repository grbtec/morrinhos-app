import 'package:async/async.dart';
import 'package:gbt_essentials/gbt_essentials.dart';

extension FutureResultExtension<T> on Future<Result<T>>{
  Future<T> unwrapOrThrowResult() async{
    final result  = await this;
    if(result.isError){
      debug(result.asError?.error);
      throw result;
    }
    return result.unwrap();
  }
}

extension ResultExtension<T> on Result<T>{
  T unwrap() {
    if(isError){
      throw asError!.error;
    }
    return asValue!.value;
  }
}