import 'package:flutter/material.dart';

class AnalyticsDetailsPage extends StatelessWidget {
  const AnalyticsDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Details')),
      body: const Center(
        child: Text('Analytics Details Page'),
      ),
    );
  }
}