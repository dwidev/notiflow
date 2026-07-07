import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'inspector_page.dart';

class NotiflowInspectorButton extends StatelessWidget {
  const NotiflowInspectorButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return FloatingActionButton.small(
      heroTag: 'notiflow_inspector_fab',
      backgroundColor: const Color(0xFF313244),
      onPressed: () => _openInspector(context),
      child: const Icon(
        Icons.bug_report_rounded,
        color: Color(0xFFCBA6F7),
        size: 20,
      ),
    );
  }

  static void _openInspector(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const NotiflowInspectorPage(),
      ),
    );
  }
}
