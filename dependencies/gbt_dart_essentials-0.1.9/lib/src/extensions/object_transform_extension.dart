// ignore:public_member_api_docs
extension ObjectTransformExtension<T> on T{
  // ignore:public_member_api_docs
  U transform<U>(U Function(T) func){
    return func(this);
  }
}
