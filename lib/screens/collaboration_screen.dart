import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class CollaborationScreen extends StatefulWidget {
  const CollaborationScreen({super.key});

  @override
  State<CollaborationScreen> createState() => _CollaborationScreenState();
}

class _CollaborationScreenState extends State<CollaborationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🤝 Collaboration'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Share Tasks Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.share, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Share Tasks',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Share your task list or individual tasks with others',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _shareTaskList,
                            icon: const Icon(Icons.list),
                            label: const Text('Share Task List'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _shareTaskSummary,
                            icon: const Icon(Icons.summarize),
                            label: const Text('Share Summary'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Export for Collaboration Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cloud_upload, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Export for Collaboration',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Export your tasks in different formats for collaboration',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _exportAsCSV,
                            icon: const Icon(Icons.table_chart),
                            label: const Text('Export as CSV'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _exportForEmail,
                            icon: const Icon(Icons.email),
                            label: const Text('Send via Email'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Team Features Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.group, color: Colors.purple),
                        SizedBox(width: 8),
                        Text(
                          'Team Features',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Collaborate with your team members',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    
                    // Email input
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Team member email',
                        hintText: 'Enter email address',
                        prefixIcon: Icon(Icons.person_add),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Message input
                    TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        labelText: 'Message (optional)',
                        hintText: 'Add a message for your team member',
                        prefixIcon: Icon(Icons.message),
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    ElevatedButton.icon(
                      onPressed: _inviteTeamMember,
                      icon: const Icon(Icons.send),
                      label: const Text('Send Invitation'),
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
            
            // Quick Actions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.flash_on, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _shareViaWhatsApp,
                            icon: const Icon(Icons.chat),
                            label: const Text('WhatsApp'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _shareViaTelegram,
                            icon: const Icon(Icons.send),
                            label: const Text('Telegram'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _shareTaskList() async {
    try {
      // Get task list as formatted text
      final taskList = await _getFormattedTaskList();
      await Share.share(
        taskList,
        subject: 'My Task List - ${DateTime.now().toString().split(' ')[0]}',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to share task list: $e');
    }
  }

  void _shareTaskSummary() async {
    try {
      final summary = await _getTaskSummary();
      await Share.share(
        summary,
        subject: 'Task Summary - ${DateTime.now().toString().split(' ')[0]}',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to share summary: $e');
    }
  }

  void _exportAsCSV() async {
    try {
      final csvData = await _generateCSVData();
      await Share.share(
        csvData,
        subject: 'Tasks Export - CSV Format',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to export CSV: $e');
    }
  }

  void _exportForEmail() async {
    try {
      final emailBody = await _getFormattedTaskList();
      final Uri emailUri = Uri(
        scheme: 'mailto',
        query: Uri.encodeQueryComponent(
          'subject=Task List Shared&body=$emailBody'
        ),
      );
      
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _showErrorSnackBar('No email app found');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to open email: $e');
    }
  }

  void _inviteTeamMember() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter an email address');
      return;
    }

    try {
      final taskList = await _getFormattedTaskList();
      final message = _messageController.text.trim();
      final fullMessage = message.isNotEmpty 
          ? '$message\n\n$taskList'
          : 'I\'d like to share my task list with you:\n\n$taskList';
      
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: _emailController.text.trim(),
        query: Uri.encodeQueryComponent(
          'subject=Task Collaboration Invitation&body=$fullMessage'
        ),
      );
      
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        _emailController.clear();
        _messageController.clear();
      } else {
        _showErrorSnackBar('No email app found');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to send invitation: $e');
    }
  }

  void _shareViaWhatsApp() async {
    try {
      final taskList = await _getFormattedTaskList();
      final Uri whatsappUri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(taskList)}');
      
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('WhatsApp not installed');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to share via WhatsApp: $e');
    }
  }

  void _shareViaTelegram() async {
    try {
      final taskList = await _getFormattedTaskList();
      final Uri telegramUri = Uri.parse('https://t.me/share/url?text=${Uri.encodeComponent(taskList)}');
      
      if (await canLaunchUrl(telegramUri)) {
        await launchUrl(telegramUri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Telegram not installed');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to share via Telegram: $e');
    }
  }

  Future<String> _getFormattedTaskList() async {
    // This would get the actual task list from your data source
    // For now, returning a sample format
    return '''📝 My Task List - ${DateTime.now().toString().split(' ')[0]}

🔴 High Priority:
• Complete project presentation
• Review budget report

🟠 Medium Priority:
• Team meeting preparation
• Update documentation

🟢 Low Priority:
• Organize desk
• Plan weekend activities

📊 Progress: 60% completed
⏰ Due today: 3 tasks
🔄 Recurring: 2 tasks

Generated by Todo App''';
  }

  Future<String> _getTaskSummary() async {
    return '''📊 Task Summary - ${DateTime.now().toString().split(' ')[0]}

✅ Completed: 8 tasks
⏳ Pending: 12 tasks
🔴 Overdue: 2 tasks
📅 Due Today: 3 tasks

🎯 Top Categories:
• Work: 10 tasks
• Personal: 6 tasks
• Study: 4 tasks

🏆 Productivity: 67%
🔥 Current Streak: 5 days

Generated by Todo App''';
  }

  Future<String> _generateCSVData() async {
    return '''Title,Category,Priority,Due Date,Status,Completion Date
"Complete project presentation","Work","High","2025-10-12","Pending",""
"Review budget report","Work","High","2025-10-11","Completed","2025-10-10"
"Team meeting preparation","Work","Medium","2025-10-13","Pending",""
"Update documentation","Work","Medium","2025-10-15","Pending",""
"Organize desk","Personal","Low","2025-10-20","Pending",""
"Plan weekend activities","Personal","Low","2025-10-14","Pending",""''';
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}