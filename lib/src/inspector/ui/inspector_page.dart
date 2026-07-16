import 'dart:async';

import 'package:flutter/material.dart';

import '../inspector_record.dart';
import '../inspector_runtime.dart';
import 'inspector_detail_page.dart';
import 'inspector_record_tile.dart';

class NotiflowInspectorPage extends StatefulWidget {
  const NotiflowInspectorPage({super.key});

  @override
  State<NotiflowInspectorPage> createState() => _NotiflowInspectorPageState();
}

class _NotiflowInspectorPageState extends State<NotiflowInspectorPage> {
  Timer? _refreshTimer;
  List<InspectorRecord> _allRecords = [];
  List<InspectorRecord> _filteredRecords = [];
  String _searchQuery = '';
  _FilterStatus _filterStatus = _FilterStatus.all;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refresh();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _refresh(),
    );
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _allRecords = InspectorRuntime.instance.storage.traces;
      _applyFilters();
    });
  }

  void _applyFilters() {
    var records = _allRecords;

    if (_filterStatus != _FilterStatus.all) {
      records = records.where((r) {
        final status = _resolveOverallStatus(r);
        return status == _filterStatus;
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      records = records.where((r) {
        final type = (r.event.payload['type'] as String?)?.toLowerCase() ?? '';
        final source = r.event.source.name.toLowerCase();
        final id = r.id.toLowerCase();
        return type.contains(query) ||
            source.contains(query) ||
            id.contains(query);
      }).toList();
    }

    _filteredRecords = records;
  }

  _FilterStatus _resolveOverallStatus(InspectorRecord record) {
    if (record.steps.isEmpty) return _FilterStatus.pending;
    for (final step in record.steps) {
      if (step.status is InspectorError) return _FilterStatus.error;
    }
    for (final step in record.steps) {
      if (step.status is InspectorWarning) return _FilterStatus.warning;
    }
    return _FilterStatus.success;
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _clearAll() {
    InspectorRuntime.instance.clear();
    _refresh();
  }

  void _openDetail(InspectorRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InspectorDetailPage(record: record),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _inspectorTheme(),
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
          title: const Text(
            'NotiFlow Inspector',
            style: TextStyle(
              color: Color(0xFFCDD6F4),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            if (_allRecords.isNotEmpty)
              IconButton(
                onPressed: _clearAll,
                icon: const Icon(Icons.delete_sweep_rounded, size: 22),
                color: const Color(0xFFF38BA8),
                tooltip: 'Clear all',
              ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildFilterChips(),
            _buildSummaryBar(),
            const Divider(color: Color(0xFF313244), height: 1),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Color(0xFFCDD6F4), fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search by type, source, or ID...',
          hintStyle: const TextStyle(color: Color(0xFF585B70), fontSize: 14),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF585B70),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: const Color(0xFF6C7086),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF313244),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _applyFilters();
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: _FilterStatus.values.map((filter) {
          final isSelected = _filterStatus == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter.label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF1E1E2E)
                      : const Color(0xFFCDD6F4),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _filterStatus = filter;
                  _applyFilters();
                });
              },
              backgroundColor: const Color(0xFF313244),
              selectedColor: filter.color,
              checkmarkColor: const Color(0xFF1E1E2E),
              side: BorderSide(
                color: isSelected ? filter.color : const Color(0xFF45475A),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryBar() {
    final total = _allRecords.length;
    final errors = _allRecords
        .where((r) => _resolveOverallStatus(r) == _FilterStatus.error)
        .length;
    final warnings = _allRecords
        .where((r) => _resolveOverallStatus(r) == _FilterStatus.warning)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          _SummaryChip(
            icon: Icons.notifications_rounded,
            label: '$total total',
            color: const Color(0xFF89B4FA),
          ),
          const SizedBox(width: 12),
          _SummaryChip(
            icon: Icons.error_outline_rounded,
            label: '$errors errors',
            color: const Color(0xFFF38BA8),
          ),
          const SizedBox(width: 12),
          _SummaryChip(
            icon: Icons.warning_amber_rounded,
            label: '$warnings warns',
            color: const Color(0xFFF9E2AF),
          ),
          const Spacer(),
          Text(
            '${_filteredRecords.length} shown',
            style: const TextStyle(
              color: Color(0xFF585B70),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_allRecords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 56, color: Color(0xFF45475A)),
            SizedBox(height: 16),
            Text(
              'No events recorded yet',
              style: TextStyle(
                color: Color(0xFF6C7086),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Dispatch a notification to see traces here',
              style: TextStyle(color: Color(0xFF45475A), fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_filteredRecords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_off_rounded, size: 48, color: Color(0xFF45475A)),
            SizedBox(height: 12),
            Text(
              'No matching events',
              style: TextStyle(color: Color(0xFF6C7086), fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _filteredRecords.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final record = _filteredRecords[index];
        return InspectorRecordTile(
          record: record,
          onTap: () => _openDetail(record),
        );
      },
    );
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

enum _FilterStatus {
  all('All', Color(0xFFCBA6F7)),
  success('Success', Color(0xFFA6E3A1)),
  warning('Warning', Color(0xFFF9E2AF)),
  error('Error', Color(0xFFF38BA8)),
  pending('Pending', Color(0xFF6C7086));

  const _FilterStatus(this.label, this.color);
  final String label;
  final Color color;
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
