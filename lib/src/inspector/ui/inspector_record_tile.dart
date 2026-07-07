import 'package:flutter/material.dart';

import '../inspector_record.dart';

class InspectorRecordTile extends StatelessWidget {
  const InspectorRecordTile({
    super.key,
    required this.record,
    required this.onTap,
  });

  final InspectorRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final status = _resolveOverallStatus();
    final statusColor = _statusColor(status);
    final source = record.event.source.name;
    final state = record.event.state.name;
    final type = record.event.payload['type'] as String? ?? '—';
    final duration = record.duration;
    final stepCount = record.steps.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF313244),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _StatusDot(color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    type,
                    style: const TextStyle(
                      color: Color(0xFFCDD6F4),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(
                    color: Color(0xFF6C7086),
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF45475A),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _Tag(label: source, color: const Color(0xFF89B4FA)),
                const SizedBox(width: 6),
                _Tag(label: state, color: const Color(0xFFA6E3A1)),
                const Spacer(),
                Text(
                  '$stepCount step${stepCount != 1 ? 's' : ''}',
                  style: const TextStyle(
                    color: Color(0xFF585B70),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              record.id,
              style: const TextStyle(
                color: Color(0xFF45475A),
                fontSize: 10,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  _OverallStatus _resolveOverallStatus() {
    if (record.steps.isEmpty) return _OverallStatus.pending;
    for (final step in record.steps) {
      if (step.status is InspectorError) return _OverallStatus.error;
    }
    for (final step in record.steps) {
      if (step.status is InspectorWarning) return _OverallStatus.warning;
    }
    return _OverallStatus.success;
  }

  Color _statusColor(_OverallStatus status) {
    return switch (status) {
      _OverallStatus.success => const Color(0xFFA6E3A1),
      _OverallStatus.warning => const Color(0xFFF9E2AF),
      _OverallStatus.error => const Color(0xFFF38BA8),
      _OverallStatus.pending => const Color(0xFF6C7086),
    };
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds > 0) {
      return '${d.inMilliseconds}ms';
    }
    return '${d.inMicroseconds}μs';
  }
}

enum _OverallStatus { success, warning, error, pending }

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
