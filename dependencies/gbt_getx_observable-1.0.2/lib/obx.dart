part of 'gbt_getx_observable.dart';

class Obx extends StatefulWidget {
  final ValueGetter<Widget> builder;

  const Obx(this.builder, {super.key});

  @override
  State<Obx> createState() => _ObxState();
}

class _ObxState extends State<Obx> {
  final _observer = RxNotifier();

  @override
  void initState() {
    super.initState();
    _observer.addListener(_updateTree);
  }

  void _updateTree() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _observer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RxNotifier.notifyChildren(_observer, widget.builder);
  }
}
