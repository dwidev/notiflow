import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../inspector_record.dart';

class InspectorDetailPage extends StatelessWidget {
  const InspectorDetailPage({super.key, required this.record});

  final InspectorRecord record;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _inspectorTheme(),
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: const Color(0xFF1E1E2E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E1E2E),
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: const Color(0xFFCDD6F4),
            ),
            title: Text(
              record.event.payload['type'] as String? ?? 'Event Detail',
              style: const TextStyle(
                color: Color(0xFFCDD6F4),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              PopupMenuButton<_ShareAction>(
                icon: const Icon(
                  Icons.ios_share_rounded,
                  color: Color(0xFFCDD6F4),
                  size: 22,
                ),
                color: const Color(0xFF313244),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (action) => _handleShareAction(context, action),
                itemBuilder: (_) => [
                  _shareMenuItem(
                    _ShareAction.copyAll,
                    Icons.copy_all_rounded,
                    'Copy All Data',
                    'Full event dump as text',
                  ),
                  _shareMenuItem(
                    _ShareAction.copyPayload,
                    Icons.data_object_rounded,
                    'Copy Payload (JSON)',
                    'Formatted JSON payload',
                  ),
                  _shareMenuItem(
                    _ShareAction.copyMetadata,
                    Icons.label_outline_rounded,
                    'Copy Metadata (JSON)',
                    'Formatted JSON metadata',
                  ),
                  _shareMenuItem(
                    _ShareAction.copyTimeline,
                    Icons.timeline_rounded,
                    'Copy Timeline',
                    'Pipeline steps with timings',
                  ),
                  _shareMenuItem(
                    _ShareAction.copyCurl,
                    Icons.terminal_rounded,
                    'Copy as Dart Map',
                    'Reproducible Dart map literal',
                  ),
                ],
              ),
            ],
            bottom: const TabBar(
              isScrollable: false,
              labelColor: Color(0xFFCBA6F7),
              unselectedLabelColor: Color(0xFF6C7086),
              indicatorColor: Color(0xFFCBA6F7),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyle(fontSize: 13),
              dividerColor: Color(0xFF313244),
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Payload'),
                Tab(text: 'Timeline'),
                Tab(text: 'Raw'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _OverviewTab(record: record),
              _PayloadTab(record: record),
              _TimelineTab(record: record),
              _RawTab(record: record),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<_ShareAction> _shareMenuItem(
    _ShareAction action,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return PopupMenuItem(
      value: action,
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFCBA6F7)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFCDD6F4),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF585B70),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleShareAction(BuildContext context, _ShareAction action) {
    final text = switch (action) {
      _ShareAction.copyAll => _buildFullDump(),
      _ShareAction.copyPayload => _buildJsonPayload(),
      _ShareAction.copyMetadata => _buildJsonMetadata(),
      _ShareAction.copyTimeline => _buildTimelineDump(),
      _ShareAction.copyCurl => _buildDartMap(),
    };

    Clipboard.setData(ClipboardData(text: text));

    final label = switch (action) {
      _ShareAction.copyAll => 'All data',
      _ShareAction.copyPayload => 'Payload JSON',
      _ShareAction.copyMetadata => 'Metadata JSON',
      _ShareAction.copyTimeline => 'Timeline',
      _ShareAction.copyCurl => 'Dart map',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFFA6E3A1),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              '$label copied to clipboard',
              style: const TextStyle(color: Color(0xFFCDD6F4)),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF313244),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _buildFullDump() {
    final event = record.event;
    final encoder = const JsonEncoder.withIndent('  ');
    final buf = StringBuffer()
      ..writeln('╔══════════════════════════════════════════════════╗')
      ..writeln('║         NOTIFLOW INSPECTOR — EVENT DUMP         ║')
      ..writeln('╚══════════════════════════════════════════════════╝')
      ..writeln()
      ..writeln('── General ─────────────────────────────────────────')
      ..writeln('Record ID     : ${record.id}')
      ..writeln('Event ID      : ${event.id}')
      ..writeln('Source        : ${event.source.name}')
      ..writeln('State         : ${event.state.name}')
      ..writeln('Received At   : ${_formatDateTime(event.receivedAt)}')
      ..writeln('Started At    : ${_formatDateTime(record.startedAt)}')
      ..writeln(
        'Finished At   : ${record.finishedAt != null ? _formatDateTime(record.finishedAt!) : "—"}',
      )
      ..writeln('Duration      : ${_formatDuration(record.duration)}')
      ..writeln('Total Steps   : ${record.steps.length}')
      ..writeln()
      ..writeln('── Payload ─────────────────────────────────────────')
      ..writeln(encoder.convert(event.payload))
      ..writeln()
      ..writeln('── Metadata ────────────────────────────────────────')
      ..writeln(
        event.metadata.isNotEmpty ? encoder.convert(event.metadata) : '(empty)',
      )
      ..writeln()
      ..writeln('── Pipeline Timeline ───────────────────────────────');

    for (var i = 0; i < record.steps.length; i++) {
      final step = record.steps[i];
      final statusTag = _stepStatusTag(step.status);
      buf
        ..writeln('  Step ${i + 1}: ${step.name}')
        ..writeln('    Status   : $statusTag')
        ..writeln('    Duration : ${_formatDuration(step.duration)}')
        ..writeln('    Started  : ${_formatDateTime(step.startedAt)}')
        ..writeln(
          '    Finished : ${step.finishedAt != null ? _formatDateTime(step.finishedAt!) : "—"}',
        );
      if (step.status != null) {
        buf.writeln('    Message  : ${step.status!.message}');
      }
      if (step.status is InspectorError) {
        final err = step.status as InspectorError;
        if (err.stackTrace != null) {
          buf
            ..writeln('    Exception: ${err.exception}')
            ..writeln('    Stack    :')
            ..writeln(_indent(err.stackTrace.toString(), '               '));
        }
      }
      buf.writeln();
    }

    buf
      ..writeln('── Raw Event toString ──────────────────────────────')
      ..writeln(event.toString())
      ..writeln()
      ..writeln(
        'Generated by NotiFlow Inspector at ${_formatDateTime(DateTime.now())}',
      );

    return buf.toString();
  }

  String _buildJsonPayload() {
    return const JsonEncoder.withIndent('  ').convert(record.event.payload);
  }

  String _buildJsonMetadata() {
    if (record.event.metadata.isEmpty) return '{}';
    return const JsonEncoder.withIndent('  ').convert(record.event.metadata);
  }

  String _buildTimelineDump() {
    final buf = StringBuffer()
      ..writeln('NotiFlow Pipeline Timeline')
      ..writeln('Event: ${record.event.payload['type'] ?? record.id}')
      ..writeln('Total Duration: ${_formatDuration(record.duration)}')
      ..writeln('─'.padRight(50, '─'));

    for (var i = 0; i < record.steps.length; i++) {
      final step = record.steps[i];
      final statusTag = _stepStatusTag(step.status);
      final connector = i < record.steps.length - 1 ? '├─' : '└─';
      buf.writeln(
        '$connector [$statusTag] ${step.name} (${_formatDuration(step.duration)})',
      );
      if (step.status != null && step.status!.message.isNotEmpty) {
        final prefix = i < record.steps.length - 1 ? '│  ' : '   ';
        buf.writeln('$prefix → ${step.status!.message}');
      }
    }

    return buf.toString();
  }

  String _buildDartMap() {
    final event = record.event;
    final buf = StringBuffer()
      ..writeln("NotificationEvent(")
      ..writeln("  id: '${event.id}',")
      ..writeln("  source: NotificationSource('${event.source.name}'),")
      ..writeln("  state: NotificationState.${event.state.name},")
      ..writeln("  payload: ${_dartMapLiteral(event.payload)},")
      ..writeln("  metadata: ${_dartMapLiteral(event.metadata)},")
      ..writeln(
        "  receivedAt: DateTime.parse('${event.receivedAt.toIso8601String()}'),",
      )
      ..writeln(")");
    return buf.toString();
  }

  String _dartMapLiteral(Map<String, Object?> map) {
    if (map.isEmpty) return 'const {}';
    final entries = map.entries
        .map((e) {
          final value = e.value is String ? "'${e.value}'" : '${e.value}';
          return "'${e.key}': $value";
        })
        .join(', ');
    return '{$entries}';
  }

  static String _stepStatusTag(InspectorStepStatus? status) {
    return switch (status) {
      InspectorSuccess() => '✅ SUCCESS',
      InspectorWarning() => '⚠️ WARNING',
      InspectorError() => '❌ ERROR',
      null => '⏳ RUNNING',
    };
  }

  static String _formatDateTime(DateTime dt) {
    return '${dt.year}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}.'
        '${dt.millisecond.toString().padLeft(3, '0')}';
  }

  static String _formatDuration(Duration d) {
    if (d.inSeconds > 0) return '${d.inMilliseconds}ms';
    return '${d.inMicroseconds}μs';
  }

  static String _indent(String text, String prefix) {
    return text.split('\n').map((l) => '$prefix$l').join('\n');
  }

  ThemeData _inspectorTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF1E1E2E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E2E),
        elevation: 0,
      ),
    );
  }
}

enum _ShareAction { copyAll, copyPayload, copyMetadata, copyTimeline, copyCurl }

// ─── Overview Tab ──────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.record});
  final InspectorRecord record;

  @override
  Widget build(BuildContext context) {
    final event = record.event;
    final overallStatus = _resolveOverallStatus();
    final statusColor = _statusColor(overallStatus);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatusBanner(
          status: overallStatus,
          color: statusColor,
          record: record,
        ),
        const SizedBox(height: 16),
        _Section(
          title: 'General',
          icon: Icons.info_outline_rounded,
          children: [
            _InfoRow(label: 'Record ID', value: record.id, mono: true),
            _InfoRow(label: 'Event ID', value: event.id, mono: true),
            _InfoRow(label: 'Source', value: event.source.name),
            _InfoRow(label: 'State', value: event.state.name),
            _InfoRow(
              label: 'Received',
              value: InspectorDetailPage._formatDateTime(event.receivedAt),
              mono: true,
            ),
            _InfoRow(
              label: 'Duration',
              value: InspectorDetailPage._formatDuration(record.duration),
              mono: true,
            ),
            _InfoRow(label: 'Steps', value: '${record.steps.length}'),
          ],
        ),
        const SizedBox(height: 12),
        if (event.payload.isNotEmpty) ...[
          _Section(
            title: 'Payload Preview',
            icon: Icons.data_object_rounded,
            footer: event.payload.length > 5
                ? '+ ${event.payload.length - 5} more fields'
                : null,
            children: event.payload.entries
                .take(5)
                .map(
                  (e) =>
                      _InfoRow(label: e.key, value: '${e.value}', mono: true),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (event.metadata.isNotEmpty) ...[
          _Section(
            title: 'Metadata Preview',
            icon: Icons.label_outline_rounded,
            footer: event.metadata.length > 5
                ? '+ ${event.metadata.length - 5} more fields'
                : null,
            children: event.metadata.entries
                .take(5)
                .map(
                  (e) =>
                      _InfoRow(label: e.key, value: '${e.value}', mono: true),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  String _resolveOverallStatus() {
    if (record.steps.isEmpty) return 'pending';
    for (final step in record.steps) {
      if (step.status is InspectorError) return 'error';
    }
    for (final step in record.steps) {
      if (step.status is InspectorWarning) return 'warning';
    }
    return 'success';
  }

  Color _statusColor(String status) {
    return switch (status) {
      'success' => const Color(0xFFA6E3A1),
      'warning' => const Color(0xFFF9E2AF),
      'error' => const Color(0xFFF38BA8),
      _ => const Color(0xFF6C7086),
    };
  }
}

// ─── Payload Tab ───────────────────────────────────────────────

class _PayloadTab extends StatelessWidget {
  const _PayloadTab({required this.record});
  final InspectorRecord record;

  @override
  Widget build(BuildContext context) {
    final event = record.event;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Section(
          title: 'Payload',
          icon: Icons.data_object_rounded,
          trailing: _CopyButton(
            data: const JsonEncoder.withIndent('  ').convert(event.payload),
            context: context,
            label: 'Payload',
          ),
          children: event.payload.entries.map((e) {
            return _InfoRow(
              label: e.key,
              value: '${e.value}',
              mono: true,
              valueColor: _valueColor(e.value),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _CodeBlock(
          title: 'Payload (JSON)',
          code: const JsonEncoder.withIndent('  ').convert(event.payload),
          context: context,
        ),
        if (event.metadata.isNotEmpty) ...[
          const SizedBox(height: 16),
          _Section(
            title: 'Metadata',
            icon: Icons.label_outline_rounded,
            trailing: _CopyButton(
              data: const JsonEncoder.withIndent('  ').convert(event.metadata),
              context: context,
              label: 'Metadata',
            ),
            children: event.metadata.entries.map((e) {
              return _InfoRow(
                label: e.key,
                value: '${e.value}',
                mono: true,
                valueColor: _valueColor(e.value),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          _CodeBlock(
            title: 'Metadata (JSON)',
            code: const JsonEncoder.withIndent('  ').convert(event.metadata),
            context: context,
          ),
        ],
      ],
    );
  }

  Color _valueColor(Object? value) {
    if (value is String) return const Color(0xFFA6E3A1);
    if (value is num) return const Color(0xFFFAB387);
    if (value is bool) return const Color(0xFFCBA6F7);
    if (value == null) return const Color(0xFF6C7086);
    return const Color(0xFFCDD6F4);
  }
}

// ─── Timeline Tab ──────────────────────────────────────────────

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.record});
  final InspectorRecord record;

  @override
  Widget build(BuildContext context) {
    if (record.steps.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timeline_rounded, size: 48, color: Color(0xFF45475A)),
            SizedBox(height: 12),
            Text(
              'No pipeline steps recorded',
              style: TextStyle(color: Color(0xFF6C7086), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DurationBar(record: record),
        const SizedBox(height: 16),
        ...record.steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isLast = index == record.steps.length - 1;
          return _TimelineStepTile(
            step: step,
            index: index,
            isLast: isLast,
            totalDuration: record.duration,
          );
        }),
      ],
    );
  }
}

// ─── Raw Tab ───────────────────────────────────────────────────

class _RawTab extends StatelessWidget {
  const _RawTab({required this.record});
  final InspectorRecord record;

  @override
  Widget build(BuildContext context) {
    final rawEvent = record.event.toString();
    final rawRecord = record.toString();
    final encoder = const JsonEncoder.withIndent('  ');

    final fullMap = <String, Object?>{
      'record_id': record.id,
      'event_id': record.event.id,
      'source': record.event.source.name,
      'state': record.event.state.name,
      'received_at': record.event.receivedAt.toIso8601String(),
      'started_at': record.startedAt.toIso8601String(),
      'finished_at': record.finishedAt?.toIso8601String(),
      'duration_us': record.duration.inMicroseconds,
      'payload': record.event.payload,
      'metadata': record.event.metadata,
      'steps': record.steps
          .map(
            (s) => {
              'name': s.name,
              'status': switch (s.status) {
                InspectorSuccess() => 'success',
                InspectorWarning() => 'warning',
                InspectorError() => 'error',
                null => 'running',
              },
              'message': s.status?.message,
              'duration_us': s.duration.inMicroseconds,
              'started_at': s.startedAt.toIso8601String(),
              'finished_at': s.finishedAt?.toIso8601String(),
            },
          )
          .toList(),
    };

    final fullJson = encoder.convert(fullMap);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _CodeBlock(title: 'Full JSON', code: fullJson, context: context),
        const SizedBox(height: 16),
        _CodeBlock(title: 'Event.toString()', code: rawEvent, context: context),
        const SizedBox(height: 16),
        _CodeBlock(
          title: 'Record.toString()',
          code: rawRecord,
          context: context,
        ),
      ],
    );
  }
}

// ─── Shared Widgets ────────────────────────────────────────────

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.status,
    required this.color,
    required this.record,
  });

  final String status;
  final Color color;
  final InspectorRecord record;

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      'success' => Icons.check_circle_rounded,
      'warning' => Icons.warning_rounded,
      'error' => Icons.error_rounded,
      _ => Icons.hourglass_empty_rounded,
    };

    final label = switch (status) {
      'success' => 'Completed Successfully',
      'warning' => 'Completed with Warnings',
      'error' => 'Completed with Errors',
      _ => 'Pending',
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.steps.length} steps · ${InspectorDetailPage._formatDuration(record.duration)}',
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
    this.footer,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF313244),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFFCBA6F7)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFCDD6F4),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
          const Divider(color: Color(0xFF45475A), height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
            child: Column(children: children),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Text(
                footer!,
                style: const TextStyle(
                  color: Color(0xFF585B70),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.mono = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool mono;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF6C7086), fontSize: 12),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                color: valueColor ?? const Color(0xFFCDD6F4),
                fontSize: 12,
                fontFamily: mono ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({
    required this.title,
    required this.code,
    required this.context,
  });

  final String title;
  final String code;
  final BuildContext context;

  @override
  Widget build(BuildContext innerContext) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF313244),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 8, 8),
            child: Row(
              children: [
                const Icon(
                  Icons.code_rounded,
                  size: 14,
                  color: Color(0xFFCBA6F7),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFCDD6F4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _CopyButton(data: code, context: context, label: title),
              ],
            ),
          ),
          const Divider(color: Color(0xFF45475A), height: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: SelectableText(
              code,
              style: const TextStyle(
                color: Color(0xFFA6ADC8),
                fontSize: 11,
                fontFamily: 'monospace',
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({
    required this.data,
    required this.context,
    required this.label,
  });

  final String data;
  final BuildContext context;
  final String label;

  @override
  Widget build(BuildContext innerContext) {
    return IconButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: data));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFFA6E3A1),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  '$label copied',
                  style: const TextStyle(
                    color: Color(0xFFCDD6F4),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 1),
            backgroundColor: const Color(0xFF313244),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
      icon: const Icon(Icons.copy_rounded, size: 16),
      color: const Color(0xFF6C7086),
      visualDensity: VisualDensity.compact,
      tooltip: 'Copy $label',
    );
  }
}

class _DurationBar extends StatelessWidget {
  const _DurationBar({required this.record});
  final InspectorRecord record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF313244),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF89B4FA)),
          const SizedBox(width: 8),
          Text(
            'Total: ${InspectorDetailPage._formatDuration(record.duration)}',
            style: const TextStyle(
              color: Color(0xFFCDD6F4),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '${record.steps.length} step${record.steps.length != 1 ? 's' : ''}',
            style: const TextStyle(color: Color(0xFF6C7086), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TimelineStepTile extends StatelessWidget {
  const _TimelineStepTile({
    required this.step,
    required this.index,
    required this.isLast,
    required this.totalDuration,
  });

  final InspectorStep step;
  final int index;
  final bool isLast;
  final Duration totalDuration;

  @override
  Widget build(BuildContext context) {
    final statusColor = _resolveColor();
    final statusLabel = _resolveLabel();
    final statusIcon = _resolveIcon();
    final message = step.status?.message;

    final percentage = totalDuration.inMicroseconds > 0
        ? (step.duration.inMicroseconds / totalDuration.inMicroseconds * 100)
        : 0.0;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    statusIcon,
                    size: 8,
                    color: const Color(0xFF1E1E2E),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      color: const Color(0xFF45475A),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF313244),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: statusColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildStepContent(
                  statusColor,
                  statusLabel,
                  percentage,
                  message,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStepContent(
    Color statusColor,
    String statusLabel,
    double percentage,
    String? message,
  ) {
    final widgets = <Widget>[
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Step ${index + 1}',
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Color(0xFF585B70),
              fontSize: 10,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        step.name,
        style: const TextStyle(
          color: Color(0xFFCDD6F4),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          const Icon(Icons.timer_outlined, size: 12, color: Color(0xFF585B70)),
          const SizedBox(width: 4),
          Text(
            InspectorDetailPage._formatDuration(step.duration),
            style: const TextStyle(
              color: Color(0xFF585B70),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 12),
          const Icon(
            Icons.schedule_rounded,
            size: 12,
            color: Color(0xFF585B70),
          ),
          const SizedBox(width: 4),
          Text(
            _formatTime(step.startedAt),
            style: const TextStyle(
              color: Color(0xFF585B70),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    ];

    if (message != null && message.isNotEmpty) {
      widgets.addAll([
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: statusColor.withValues(alpha: 0.15)),
          ),
          child: SelectableText(
            message,
            style: TextStyle(
              color: statusColor.withValues(alpha: 0.8),
              fontSize: 11,
              fontFamily: 'monospace',
              height: 1.4,
            ),
          ),
        ),
      ]);
    }

    if (step.status is InspectorError) {
      final err = step.status! as InspectorError;
      if (err.stackTrace != null) {
        widgets.addAll([
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF38BA8).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFFF38BA8).withValues(alpha: 0.15),
              ),
            ),
            child: SelectableText(
              err.stackTrace.toString(),
              style: const TextStyle(
                color: Color(0xFFF38BA8),
                fontSize: 10,
                fontFamily: 'monospace',
                height: 1.4,
              ),
              maxLines: 10,
            ),
          ),
        ]);
      }
    }

    return widgets;
  }

  Color _resolveColor() {
    return switch (step.status) {
      InspectorSuccess() => const Color(0xFFA6E3A1),
      InspectorWarning() => const Color(0xFFF9E2AF),
      InspectorError() => const Color(0xFFF38BA8),
      null => const Color(0xFF6C7086),
    };
  }

  String _resolveLabel() {
    return switch (step.status) {
      InspectorSuccess() => 'Success',
      InspectorWarning() => 'Warning',
      InspectorError() => 'Error',
      null => 'Running',
    };
  }

  IconData _resolveIcon() {
    return switch (step.status) {
      InspectorSuccess() => Icons.check,
      InspectorWarning() => Icons.warning,
      InspectorError() => Icons.close,
      null => Icons.hourglass_empty,
    };
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}.'
        '${dt.millisecond.toString().padLeft(3, '0')}';
  }
}
