import 'package:mobile/model/layout.dart';
import 'package:mobile/model/layout_view_widget.dart';

class LayoutModel {
  static LayoutModel instance = LayoutModel().._initialize();
  final Map<String, Layout> layouts = {};

  void _initialize() {
    print("Initializing LayoutModel");
    layouts["DEFAULT"] = Layout(tiles: [
      // LayoutTile(
      //   width: 2,
      //   height: 2,
      //   widget: LayoutViewWidget(
      //     title: "Lazer e Hospedagem",
      //     route: "home_view",
      //     iconName: "calendar_assistant_20_regular",
      //     backgroundImageUrl:
      //         "https://images.pexels.com/photos/1361814/pexels-photo-1361814.jpeg?auto=compress&cs=tinysrgb&w=600",
      //     backgroundColor: 0xfffeb549,
      //   ),
      // ),
      // LayoutTile(
      //   width: 1,
      //   height: 1,
      //   widget: LayoutViewWidget(
      //     title: "2 Widget View",
      //     route: "home_view",
      //     iconName: "calendar_assistant_20_regular",
      //     backgroundImageUrl: null,
      //     backgroundColor: 0xfffe85a9,
      //   ),
      // ),
      // LayoutTile(
      //   width: 1,
      //   height: 1,
      //   widget: LayoutViewWidget(
      //     title: "3 Widget View",
      //     route: "home_view",
      //     iconName: "calendar_assistant_20_regular",
      //     backgroundImageUrl: null,
      //     backgroundColor: 0xffae8549,
      //   ),
      // ),
      // LayoutTile(
      //   width: 1,
      //   height: 1,
      //   widget: LayoutViewWidget(
      //     title: "4 Widget View",
      //     route: "home_view",
      //     iconName: "calendar_assistant_20_regular",
      //     backgroundImageUrl: null,
      //     backgroundColor: 0xffd0f049,
      //   ),
      // ),
      // LayoutTile(
      //   width: 1,
      //   height: 1,
      //   widget: LayoutViewWidget(
      //     title: "5  Widget View",
      //     route: "home_view",
      //     iconName: "calendar_assistant_20_regular",
      //     backgroundImageUrl: null,
      //     backgroundColor: 0xfffe8549,
      //   ),
      // ),
      // LayoutTile(
      //   width: 4,
      //   height: 2,
      //   widget: LayoutViewWidget(
      //     title: "6 Widget View",
      //     route: "home_view",
      //     iconName: "calendar_assistant_20_regular",
      //     backgroundImageUrl:
      //         "https://images.pexels.com/photos/70497/pexels-photo-70497.jpeg?auto=compress&cs=tinysrgb&w=600",
      //     backgroundColor: 0xff26b79a,
      //   ),
      // ),
      // LayoutTile(
      //   width: 2,
      //   height: 2,
      //   widget: LayoutViewWidget(
      //     title: "Eventos na cidade",
      //     route: "home_view",
      //     iconName: "calendar_assistant_20_regular",
      //     backgroundImageUrl:
      //         "https://images.pexels.com/photos/196652/pexels-photo-196652.jpeg?auto=compress&cs=tinysrgb&w=600",
      //     backgroundColor: 0xff26b79a,
      //   ),
      // ),
      // LayoutTile(
      //   width: 2,
      //   height: 2,
      //   widget: LayoutViewWidget(
      //     title: "4 Widget View",
      //     route: "home_view",
      //     iconName: "calendar_assistant_20_regular",
      //     backgroundImageUrl: null,
      //     backgroundColor: 0xffd0f049,
      //   ),
      // ),
    ]);
  }
}
