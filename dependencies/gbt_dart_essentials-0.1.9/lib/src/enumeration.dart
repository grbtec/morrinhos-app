// ignore:public_member_api_docs
abstract class Enumeration{
  // ignore:public_member_api_docs
  final int id;
  // ignore:public_member_api_docs
  final String name;

  // ignore:public_member_api_docs
  const Enumeration(this.id, this.name);

  @override
  bool operator ==(Object other) =>
      other is Enumeration &&
          other.id == id;

  @override
  int get hashCode => id;
}
