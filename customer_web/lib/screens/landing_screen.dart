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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid state modification during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkToken();
    });
  }

  Future<void> _checkToken() async {
    final token = widget.token?.trim();
    if (token == null || token.isEmpty) {
      return;
    }

    try {
      // Validate token up-front to avoid navigating to menu with invalid QR.
      await ref.read(apiServiceProvider.notifier).getMenu(token);
      ref.read(tableTokenProvider.notifier).setToken(token);

      ref.read(activeOrderIdProvider.notifier).setId(null);
      final activeOrder = await ref
          .read(apiServiceProvider.notifier)
          .getActiveOrder(token);
      if (activeOrder != null) {
        ref.read(activeOrderIdProvider.notifier).setId(activeOrder['id']);
      }

      if (mounted) {
        context.go('/menu');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Invalid table QR code. Please scan again.';
      });
      debugPrint('Error validating token: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasToken = widget.token?.trim().isNotEmpty ?? false;

    return Scaffold(
      body: Center(
        child: !hasToken
            ? const Text('Scan QR Code to order')
            : _errorMessage != null
                ? Text(_errorMessage!)
                : const CircularProgressIndicator(),
      ),
    );
  }
}
