import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gbt_fluent2_ui/fluent_icons.dart';
import 'package:gbt_fluent2_ui/gbt_fluent2_ui.dart';
import 'package:mobile/infrastructure/auth/user_credential_provider.dart';
import 'package:mobile/components/staggered_view_grid.dart';
import 'package:mobile/screen/home/show_login_bottom_sheet.dart';
import 'package:mobile/screen/home/show_me_control.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  void _onLoginButtonPressed() {
    showLoginBottomSheet(this);
  }

  void _onOpenUserControlPressed() {
    showMeControl(this);
  }

  @override
  Widget build(BuildContext context) {
    return FluentScaffold(
      appBar: FluentNavBar(
        title: NavCenterSubtitle(
          title: "City Guide",
          subtitle: "Explore as diferentes sessões",
        ),
        actions: [
          Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final userAsync = ref.watch(userCredentialProvider);

              return IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: userAsync.isLoading
                    ? null
                    : userAsync.valueOrNull != null
                        ? _onOpenUserControlPressed
                        : _onLoginButtonPressed,
                color: userAsync.valueOrNull != null
                    ? FluentColors.statusSuccessForeground1Rest
                    : null,
                icon: const Icon(FluentIcons.person_24_regular),
              );
            },
          ),
        ],
      ),
      body: const StaggeredViewGrid(),
    );
  }
}
