import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_shell/ui_shell.dart';
import '../src/subscription_service.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  final String featureName;
  final VoidCallback? onSuccess;

  const PaywallScreen({
    super.key,
    required this.featureName,
    this.onSuccess,
  });

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  bool _isLoading = false;

  Future<void> _purchase() async {
    setState(() => _isLoading = true);
    final success = await ref.read(subscriptionServiceProvider).purchasePro();
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          Navigator.pop(context);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase cancelled or failed')),
        );
      }
    }
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    await ref.read(subscriptionServiceProvider).restorePurchases();
    if (mounted) {
      setState(() => _isLoading = false);
      // Check if successful
      if (ref.read(subscriptionServiceProvider).isPro) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No active subscriptions found')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: 'Upgrade to Pro',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Icon(Icons.diamond, size: 80, color: FactoryColors.primary),
            SizedBox(height: 24),
            Text(
              "Unlock ${widget.featureName}",
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              "Get unlimited access to all premium features with Factory Pro.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 40),

            // Pricing Card
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: FactoryColors.primary, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: FactoryColors.primary.withValues(alpha: 0.05),
              ),
              child: Column(
                children: [
                  Text("YEARLY ACCESS",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: FactoryColors.primary)),
                  SizedBox(height: 8),
                  Text("\$39.99 / year",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Best Value (Save 30%)",
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            SizedBox(height: 48),

            FactoryButton(
              label: _isLoading ? "Processing..." : "Subscribe Now",
              isLoading: _isLoading,
              onPressed: _purchase,
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: _isLoading ? null : _restore,
              child: Text("Restore Purchases"),
            ),
            SizedBox(height: 8),
            Text(
              "Terms of Service • Privacy Policy",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
