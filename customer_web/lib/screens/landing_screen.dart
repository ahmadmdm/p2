import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class LandingScreen extends ConsumerStatefulWidget {
  final String? token;
  const LandingScreen({super.key, this.token});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  String? _errorMessage;
  final TextEditingController _tokenController = TextEditingController();
  bool _isChecking = false;

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

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
    _tokenController.text = token;

    await _validateAndNavigate(token);
  }

  Future<void> _validateAndNavigate(String rawToken) async {
    final token = rawToken.trim();
    if (token.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a table token';
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });
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
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasToken = widget.token?.trim().isNotEmpty ?? false;

    return Container(
      decoration: AppTheme.gradientBackground(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.restaurant_menu_rounded,
                          size: 42,
                          color: AppTheme.primary,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'QR Dining Experience',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2B1D15),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hasToken
                              ? 'Validating your table...'
                              : 'Enter table token to open your menu instantly.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.brown.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _tokenController,
                          decoration: const InputDecoration(
                            labelText: 'Table token',
                            prefixIcon: Icon(Icons.qr_code_rounded),
                          ),
                          onSubmitted: _isChecking
                              ? null
                              : (value) => _validateAndNavigate(value),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: _isChecking
                              ? null
                              : () => _validateAndNavigate(
                                    _tokenController.text,
                                  ),
                          icon: _isChecking
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward_rounded),
                          label: Text(
                            _isChecking ? 'Checking...' : 'Start Ordering',
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
