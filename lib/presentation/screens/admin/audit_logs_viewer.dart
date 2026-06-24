import 'package:flutter/material.dart';
import 'package:agrolinkbd/core/models/audit_log_model.dart';
import 'package:agrolinkbd/core/services/audit_service.dart';

class AuditLogsViewer extends StatefulWidget {
  const AuditLogsViewer({super.key});

  @override
  State<AuditLogsViewer> createState() => _AuditLogsViewerState();
}

class _AuditLogsViewerState extends State<AuditLogsViewer> {
  final AuditService _auditService = AuditService();
  final _searchController = TextEditingController();

  String? _filterActionType;
  String? _filterEntityType;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  String _searchQuery = '';

  List<AuditLogModel> _auditLogs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);

    try {
      final logsData = await _auditService.getAuditLogs(
        actionType: _filterActionType,
        entityType: _filterEntityType,
        startDate: _filterStartDate,
        endDate: _filterEndDate,
        limit: 100,
      );

      setState(() {
        _auditLogs = logsData
            .map((data) =>
                AuditLogModel.fromMap(data, data['id'] as String? ?? ''))
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading logs: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    var filteredLogs = _auditLogs;

    if (_searchQuery.isNotEmpty) {
      filteredLogs = filteredLogs
          .where((log) =>
              log.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              log.adminName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Logs'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export as CSV',
            onPressed: _exportLogs,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
            onPressed: _showFiltersPanel,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search by admin name or action...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Active filters display
          if (_filterActionType != null ||
              _filterEntityType != null ||
              _filterStartDate != null ||
              _filterEndDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_filterActionType != null)
                      Chip(
                        label: Text('Action: $_filterActionType'),
                        onDeleted: () =>
                            setState(() => _filterActionType = null),
                      ),
                    const SizedBox(width: 8),
                    if (_filterEntityType != null)
                      Chip(
                        label: Text('Entity: $_filterEntityType'),
                        onDeleted: () =>
                            setState(() => _filterEntityType = null),
                      ),
                    const SizedBox(width: 8),
                    if (_filterStartDate != null)
                      Chip(
                        label: Text('From: ${_formatDate(_filterStartDate!)}'),
                        onDeleted: () =>
                            setState(() => _filterStartDate = null),
                      ),
                    const SizedBox(width: 8),
                    if (_filterEndDate != null)
                      Chip(
                        label: Text('To: ${_formatDate(_filterEndDate!)}'),
                        onDeleted: () => setState(() => _filterEndDate = null),
                      ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Clear all'),
                      onPressed: _clearFilters,
                    ),
                  ],
                ),
              ),
            ),

          // Log count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Showing ${filteredLogs.length} logs',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),

          // Logs list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredLogs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.history,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No audit logs found',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          return _buildLogCard(context, log);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogCard(BuildContext context, AuditLogModel log) {
    final Color actionColor = Color(AuditLogUtils.getActionColor(log.actionType));

    // Determine icon based on success and action type
    IconData iconData = Icons.info_outline;
    if (log.success) {
      if (log.actionType.contains('CREATE') || log.actionType.contains('ADD')) {
        iconData = Icons.check_circle_outline;
      } else if (log.actionType.contains('DELETE') || log.actionType.contains('REMOVE')) {
        iconData = Icons.delete_outline;
      } else {
        iconData = Icons.task_alt;
      }
    } else {
      iconData = Icons.cancel_outlined;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline line and dot
          SizedBox(
            width: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: actionColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: actionColor.withOpacity(0.5), width: 2),
                  ),
                  child: Icon(iconData, size: 16, color: actionColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Log Card
          Expanded(
            child: Card(
              margin: const EdgeInsets.only(bottom: 24),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: actionColor.withOpacity(0.1)),
              ),
              color: Theme.of(context).colorScheme.surface,
              child: InkWell(
                onTap: () => _showLogDetails(context, log),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  log.getEntityIcon(),
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    log.getActionLabel(),
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: actionColor,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: log.success ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _formatDateTime(log.timestamp),
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: log.success ? Colors.green[700] : Colors.red[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        log.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              log.adminName,
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              log.entityType,
                              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogDetails(BuildContext context, AuditLogModel log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color:
                          Color(AuditLogUtils.getActionColor(log.actionType)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        log.getActionLabel(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    if (log.success)
                      const Chip(
                        label: Text('Success'),
                        backgroundColor: Colors.green,
                      )
                    else
                      const Chip(
                        label: Text('Failed'),
                        backgroundColor: Colors.red,
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // Admin Information
                _buildDetailSection('Admin Information', [
                  _buildDetailRow('Name', log.adminName),
                  _buildDetailRow('Role', log.adminRole.toUpperCase()),
                  _buildDetailRow('ID', log.adminId),
                ]),

                const SizedBox(height: 16),

                // Action Information
                _buildDetailSection('Action Information', [
                  _buildDetailRow('Action Type', log.actionType),
                  _buildDetailRow('Entity Type', log.entityType),
                  _buildDetailRow('Entity ID', log.entityId),
                  _buildDetailRow('Description', log.description),
                ]),

                const SizedBox(height: 16),

                // Timestamp
                _buildDetailSection('Timestamp', [
                  _buildDetailRow(
                      'Date & Time', _formatDateTime(log.timestamp)),
                  _buildDetailRow(
                    'Relative Time',
                    _getRelativeTime(log.timestamp),
                  ),
                ]),

                if (log.oldValues.isNotEmpty || log.newValues.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection('Changes', [
                    if (log.oldValues.isNotEmpty)
                      _buildChangeRow('Before', log.oldValues),
                    if (log.newValues.isNotEmpty)
                      _buildChangeRow('After', log.newValues),
                  ]),
                ],

                if (log.errorMessage != null &&
                    log.errorMessage!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildDetailSection('Error Information', [
                    _buildDetailRow('Error', log.errorMessage ?? 'N/A'),
                  ]),
                ],

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SelectableText(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeRow(String label, Map<String, dynamic> changes) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SelectableText(
              changes.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFiltersPanel() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Date range
            Text('Date Range', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _filterStartDate != null
                          ? _formatDate(_filterStartDate!)
                          : 'Start Date',
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _filterStartDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _filterStartDate = date);
                        _loadLogs();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _filterEndDate != null
                          ? _formatDate(_filterEndDate!)
                          : 'End Date',
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _filterEndDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _filterEndDate = date);
                        _loadLogs();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLogs,
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportLogs() async {
    try {
      await _auditService.exportAuditLogsAsCSV(
        startDate: _filterStartDate,
        endDate: _filterEndDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logs exported to clipboard'),
          action: SnackBarAction(
            label: 'Copy',
            onPressed: () {
              // Copy to clipboard implementation would go here
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting: $e')),
      );
    }
  }

  void _clearFilters() {
    setState(() {
      _filterActionType = null;
      _filterEntityType = null;
      _filterStartDate = null;
      _filterEndDate = null;
      _searchQuery = '';
      _searchController.clear();
    });
    _loadLogs();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${(diff.inDays / 7).floor()}w ago';
    }
  }
}
