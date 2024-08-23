import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/providers/tenant_slug_provider.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenantSlugAsync = ref.watch(tenantSlugProvider);
    final tenantSlug = tenantSlugAsync.valueOrNull;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Image.asset("assets/images/logo.webp"),
          ),
        ),
        if (tenantSlug != null)
          SizedBox(
            height: 0,
            child: OverflowBox(
              maxHeight: 200,
              alignment: Alignment.bottomCenter,
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Material(
                  color: Colors.transparent,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: SafeArea(
                      minimum: const EdgeInsets.all(16),
                      child: Text(
                        tenantSlug,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
