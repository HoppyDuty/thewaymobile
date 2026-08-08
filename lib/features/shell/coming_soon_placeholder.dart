import 'package:flutter/material.dart';

import '../../core/widgets/app_empty_state.dart';

/// Stand-in for tabs whose real feature hasn't been built yet (CBT, Videos,
/// Books, Profile land in later phases).
class ComingSoonPlaceholder extends StatelessWidget {
  const ComingSoonPlaceholder({super.key, required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AppEmptyState(
        title: '$title coming soon',
        message: 'This section is being built in an upcoming phase.',
        icon: icon,
      ),
    );
  }
}
