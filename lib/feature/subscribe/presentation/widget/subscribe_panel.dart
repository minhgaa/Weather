// lib/feature/subscription/presentation/subscription_panel.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class SubscriptionPanel extends StatefulWidget {
  final String? defaultCity;     // truyền city đang xem nếu có
  final String? defaultCoords;   // ví dụ "21.03,105.85"
  const SubscriptionPanel({super.key, this.defaultCity, this.defaultCoords});

  @override
  State<SubscriptionPanel> createState() => _SubscriptionPanelState();
}

class _SubscriptionPanelState extends State<SubscriptionPanel> {
  final _email = TextEditingController();
  final _city = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.defaultCity != null) _city.text = widget.defaultCity!;
  }

  Future<void> _subscribe() async {
    final email = _email.text.trim();
    final city = _city.text.trim();
    if (email.isEmpty || city.isEmpty) return;

    final uuid = const Uuid();
    final token = uuid.v4();
    final now = FieldValue.serverTimestamp();
    try {
      await FirebaseFirestore.instance.collection('subscribers').add({
        'email': email,
        'city': city,
        'confirmed': false,
        'unsubscribed': false,
        'token': token,
        'createdAt': now,
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Subscription Requested'),
            content: const Text('Please check your email to confirm your subscription.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to subscribe: $e')),
        );
      }
    }
  }

  Future<void> _unsubscribe() async {
    final email = _email.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email to unsubscribe.')),
      );
      return;
    }
    try {
      final query = await FirebaseFirestore.instance
          .collection('subscribers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No subscription found for this email.')),
          );
        }
        return;
      }
      final token = query.docs.first.data()['token'];
      final unsubUrl = '/unsubscribe.html?token=$token';
      // Use the absolute URL for Firebase Hosting
      final fullUrl = 'https://${Uri.base.host}$unsubUrl';
      await launchUrlString(fullUrl, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unsubscribe: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily Forecast Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
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
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: _subscribe,
                style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Subscribe'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _unsubscribe,
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Unsubscribe'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'You will receive a confirmation email (double opt‑in). You can unsubscribe anytime.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}