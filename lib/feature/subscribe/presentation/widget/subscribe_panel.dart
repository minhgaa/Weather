// lib/feature/subscription/presentation/subscription_panel.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:weather_app/core/theme/theme.dart';

class SubscriptionPanel extends StatefulWidget {
  final String? defaultCity;
  final String? defaultCoords;
  const SubscriptionPanel({super.key, this.defaultCity, this.defaultCoords});

  @override
  State<SubscriptionPanel> createState() => _SubscriptionPanelState();
}

class _SubscriptionPanelState extends State<SubscriptionPanel> {
  final _email = TextEditingController();
  final _city = TextEditingController();

  static const String _hostingBase = 'https://weatherapp-0101.web.app';

  @override
  void initState() {
    super.initState();
    if (widget.defaultCity != null) _city.text = widget.defaultCity!;
  }

  Future<void> _subscribe() async {
    final email = _email.text.trim().toLowerCase();
    final city = _city.text.trim();
    if (email.isEmpty || city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and city.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 16, left: 16, right: 16),
        ),
      );
      return;
    }
    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!emailOk) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(
        content: Text('Invalid email format.'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 16, left: 16, right: 16),
      ));
      return;
    }

    final uuid = const Uuid();
    final token = uuid.v4();
    final now = FieldValue.serverTimestamp();
    try {
      await FirebaseFirestore.instance
          .collection('subscribers')
          .doc(token)
          .set({
            'email': email,
            'city': city,
            'confirmed': false,
            'unsubscribed': false,
            'token': token,
            'createdAt': now,
          });
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Subscription request recorded. Check your inbox and click Confirm to start receiving daily forecasts.',
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 16, left: 16, right: 16),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(
        content: Text('Failed to subscribe: $e'),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
      ));
    }
  }

  Future<void> _unsubscribe() async {
    final email = _email.text.trim().toLowerCase();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email to unsubscribe.'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 16, left: 16, right: 16),
        ),
      );
      return;
    }
    final emailOk = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!emailOk) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(
        content: Text('Invalid email format.'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(top: 16, left: 16, right: 16),
      ));
      return;
    }

    final fullUrl =
        '$_hostingBase/unsubscribe.html?email=${Uri.encodeComponent(email)}';
    try {
      await launchUrlString(fullUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to open unsubscribe page: $e'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _email,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'you@example.com',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _city,
          decoration: const InputDecoration(
            labelText: 'City',
            hintText: 'Hanoi',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'You will receive a confirmation email (double opt‑in). You can unsubscribe anytime.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Spacer(),
            TextButton(
              onPressed: _subscribe,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                backgroundColor: AppTheme.primarySeed,
              ),
              child: const Text(
                'Subscribe',
                style: TextStyle(color: AppTheme.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
