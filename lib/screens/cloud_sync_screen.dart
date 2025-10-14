import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cloud_sync_service.dart';
import '../utils/database_helper.dart';
import 'authentication_screen.dart';

class CloudSyncScreen extends StatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  State<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends State<CloudSyncScreen> {
  final CloudSyncService _cloudSync = CloudSyncService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  Map<String, dynamic>? _syncStatus;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        title: const Text('☁️ Cloud Sync'),
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
                              Icon(
                                _syncStatus!['isSignedIn'] 
                                    ? Icons.cloud_done 
                                    : Icons.cloud_off,
                                color: _syncStatus!['isSignedIn'] 
                                    ? Colors.green 
                                    : Colors.grey,
                                size: 32,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _syncStatus!['isSignedIn'] 
                                          ? 'Signed In' 
                                          : 'Not Signed In',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (_syncStatus!['userId'] != null)
                                      Text(
                                        'User: ${_syncStatus!['userId']}',
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          if (_syncStatus!['lastSync'] != null) ...[
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

                  // Sign In/Out Section
                  if (!_syncStatus!['isSignedIn']) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🔐 Sign In to Cloud',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Connect to Firebase to sync your tasks across devices. Your data will be securely stored in the cloud.',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _openAuthScreen,
                              icon: _isLoading 
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.login),
                              label: const Text('Sign In / Sign Up'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Sync Actions
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '🔄 Sync Actions',
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
                                    label: const Text('Upload'),
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
                                    label: const Text('Download'),
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
                              label: const Text('Full Sync (Upload & Download)'),
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
                    
                    // Account Actions
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '👤 Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _signOut,
                              icon: const Icon(Icons.logout),
                              label: const Text('Sign Out'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Info Card
                  Card(
                    color: _syncStatus!['isMock'] == true 
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Colors.blue.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _syncStatus!['isMock'] == true 
                                    ? Icons.science 
                                    : Icons.info, 
                                color: _syncStatus!['isMock'] == true 
                                    ? Colors.orange 
                                    : Colors.blue,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _syncStatus!['isMock'] == true 
                                    ? 'Mock Firebase Service' 
                                    : 'About Cloud Sync',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _syncStatus!['isMock'] == true
                                ? '🧪 Development Mode Active\n'
                                  '• Using mock Firebase service for testing\n'
                                  '• Data stored locally but simulates cloud sync\n'
                                  '• Ready to switch to real Firebase when configured\n'
                                  '• All sync features work as intended'
                                : '• Keep your tasks synchronized across all devices\n'
                                  '• Automatic backup ensures your data is safe\n'
                                  '• Sign in once and access your tasks anywhere\n'
                                  '• Real Firebase authentication and storage',
                            style: const TextStyle(fontSize: 14),
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

  Future<void> _openAuthScreen() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const AuthenticationScreen(),
      ),
    );

    if (result == true) {
      _showSuccess('Authentication successful!');
      await _loadSyncStatus();
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out? Your local data will remain safe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _cloudSync.signOut();
      await _loadSyncStatus();
      _showSuccess('Signed out successfully');
    }
  }

  Future<void> _syncToCloud() async {
    setState(() => _isLoading = true);

    try {
      final todoBox = DatabaseHelper.getTodoBox();
      final todos = todoBox.values.toList();
      
      final success = await _cloudSync.syncToCloud(todos);
      
      if (success) {
        _showSuccess('Data uploaded to cloud successfully!');
        await _loadSyncStatus();
      } else {
        _showError('Failed to upload data to cloud');
      }
    } catch (e) {
      _showError('Upload error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncFromCloud() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download from Cloud'),
        content: const Text('This will replace your local tasks with data from the cloud. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Download'),
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
        
        _showSuccess('Data downloaded from cloud successfully!');
        await _loadSyncStatus();
      } else {
        _showError('No data found in cloud or download failed');
      }
    } catch (e) {
      _showError('Download error: $e');
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
      
      _showSuccess('Full sync completed successfully!');
      await _loadSyncStatus();
    } catch (e) {
      _showError('Full sync error: $e');
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