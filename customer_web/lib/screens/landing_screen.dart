import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';

class LandingScreen extends ConsumerStatefulWidget {
  final String? token;
  const LandingScreen({super.key, this.token});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid state modification during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkToken();
    });
  }

  Future<void> _checkToken() async {
    if (widget.token != null && widget.token!.isNotEmpty) {
      ref.read(tableTokenProvider.notifier).setToken(widget.token!);

      // Reset active order ID first
      ref.read(activeOrderIdProvider.notifier).setId(null);

      // Check for active order
      try {
        final activeOrder = await ref
            .read(apiServiceProvider.notifier)
            .getActiveOrder(widget.token!);
        if (activeOrder != null) {
          ref.read(activeOrderIdProvider.notifier).setId(activeOrder['id']);
        }
      } catch (e) {
        // Ignore error, just proceed to menu
        debugPrint('Error fetching active order: $e');
      }

      if (mounted) {
        context.go('/menu');
      }
    } else {
      // Show error or manual entry
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: widget.token == null
            ? const Text('Scan QR Code to order')
            : const CircularProgressIndicator(),
      ),
    );
  }
}
