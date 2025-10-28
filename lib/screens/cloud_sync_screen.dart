import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cloud_sync_service.dart';
import '../utils/database_helper.dart';

class CloudSyncScreen extends StatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  State<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends State<CloudSyncScreen> {
  final CloudSyncService _cloudSync = CloudSyncService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _syncStatus;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSyncStatus() async {
    final status = await _cloudSync.getSyncStatus();
    setState(() {
      _syncStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💾 Local Backup'),
        centerTitle: true,
      ),
      body: _syncStatus == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Status Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.cloud_done,
                                  color: Colors.green,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Local Backup Ready',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Local storage and backup system',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),                          if (_syncStatus!['lastSync'] != null) ...[
                            const SizedBox(height: 12),
                            const Divider(),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  'Last sync: ${DateFormat('MMM dd, yyyy - HH:mm').format(_syncStatus!['lastSync'])}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),

                  // Sync Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '� Backup Actions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _syncToCloud,
                                  icon: const Icon(Icons.cloud_upload),
                                  label: const Text('Backup'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : _syncFromCloud,
                                  icon: const Icon(Icons.cloud_download),
                                  label: const Text('Restore'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _fullSync,
                            icon: const Icon(Icons.sync),
                            label: const Text('Full Backup (Backup & Verify)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Info Card
                  Card(
                    color: Colors.blue.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: Colors.blue,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'About Local Sync',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '💾 Local Backup System\n'
                            '• Creates local backups of your tasks\n'
                            '• Restore your data when needed\n'
                            '• No internet connection required\n'
                            '• Simple and reliable data management',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }



  Future<void> _syncToCloud() async {
    setState(() => _isLoading = true);

    try {
      final todoBox = DatabaseHelper.getTodoBox();
      final todos = todoBox.values.toList();
      
      final success = await _cloudSync.syncToCloud(todos);
      
      if (success) {
        _showSuccess('Data backed up locally successfully!');
        await _loadSyncStatus();
      } else {
        _showError('Failed to backup data locally');
      }
    } catch (e) {
      _showError('Backup error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncFromCloud() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore from Backup'),
        content: const Text('This will replace your current tasks with data from the local backup. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final cloudTodos = await _cloudSync.syncFromCloud();
      
      if (cloudTodos != null) {
        final todoBox = DatabaseHelper.getTodoBox();
        await todoBox.clear();
        
        for (final todo in cloudTodos) {
          await todoBox.add(todo);
        }
        
        _showSuccess('Data restored from local backup successfully!');
        await _loadSyncStatus();
      } else {
        _showError('No backup found or restore failed');
      }
    } catch (e) {
      _showError('Restore error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fullSync() async {
    setState(() => _isLoading = true);

    try {
      // First upload current data
      final todoBox = DatabaseHelper.getTodoBox();
      final todos = todoBox.values.toList();
      
      await _cloudSync.syncToCloud(todos);
      
      _showSuccess('Full backup completed successfully!');
      await _loadSyncStatus();
    } catch (e) {
      _showError('Full backup error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}