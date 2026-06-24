import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:agrolinkbd/core/models/user_audit_log_model.dart';
import 'package:agrolinkbd/core/services/audit_service.dart';

class UserAuditLogsView extends StatefulWidget {
  const UserAuditLogsView({super.key});

  @override
  State<UserAuditLogsView> createState() => _UserAuditLogsViewState();
}

class _UserAuditLogsViewState extends State<UserAuditLogsView> {
  final AuditService _auditService = AuditService();
  final _searchController = TextEditingController();

  List<UserAuditLogModel> _logs = [];
  bool _isLoading = false;
  String _searchQuery = '';

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
      final logsData = await _auditService.getUserAuditLogs(limit: 500);
      setState(() {
        _logs = logsData
            .map((data) => UserAuditLogModel.fromMap(data, data['id'] as String? ?? ''))
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading user logs: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportCSV() async {
    try {
      List<List<dynamic>> rows = [];
      rows.add([
        'Timestamp',
        'User ID',
        'Email/Phone',
        'Action',
        'Device Info',
        'Session Duration (s)',
        'Status'
      ]);

      var logsToExport = _logs;
      if (_searchQuery.isNotEmpty) {
        logsToExport = logsToExport
            .where((log) =>
                log.userId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                log.userName.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }

      for (var log in logsToExport) {
        rows.add([
          log.timestamp.toIso8601String(),
          log.userId,
          log.userName,
          log.action,
          log.deviceInfo,
          log.sessionDuration ?? '',
          log.status,
        ]);
      }

      String csvString = csv.encode(rows);

      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/user_audit_logs_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csvString);

      await Share.shareXFiles([XFile(path)], text: 'User Audit Logs');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting CSV: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var filteredLogs = _logs;
    if (_searchQuery.isNotEmpty) {
      filteredLogs = filteredLogs
          .where((log) =>
              log.userId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              log.userName.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search by User ID or Email...',
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
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _exportCSV,
                icon: const Icon(Icons.download),
                label: const Text('CSV'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Showing ${filteredLogs.length} logs',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : filteredLogs.isEmpty
                  ? const Center(child: Text('No user logs found'))
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
    );
  }

  Widget _buildLogCard(BuildContext context, UserAuditLogModel log) {
    Color statusColor;
    IconData icon;
    if (log.status == 'suspicious') {
      statusColor = Colors.red;
      icon = Icons.warning_amber_rounded;
    } else if (log.status == 'failed') {
      statusColor = Colors.orange;
      icon = Icons.error_outline;
    } else if (log.action == 'logout') {
      statusColor = Colors.grey;
      icon = Icons.logout;
    } else {
      statusColor = Colors.green;
      icon = Icons.login;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  log.getActionLabel(),
                  style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                ),
                const Spacer(),
                Text(
                  _formatDateTime(log.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('User ID:', log.userId),
            _buildInfoRow('User:', log.userName),
            _buildInfoRow('Device:', log.deviceInfo),
            if (log.action == 'logout' && log.sessionDuration != null)
              _buildInfoRow('Duration:', log.getFormattedDuration()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
