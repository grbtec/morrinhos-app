// ignore:public_member_api_docs
typedef Constructor<T> = T Function();
// ignore:public_member_api_docs
typedef FromJsonConstructor<T> = T Function(Object? json);
// ignore:public_member_api_docs
typedef FromJsonObjectConstructor<T> = T Function(
  Map<String, Object?> jsonObject,
);
// ignore:public_member_api_docs
typedef FromJsonListConstructor<T> = T Function(List<Object?> jsonList);
