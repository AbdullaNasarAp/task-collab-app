// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task_collab_app/model/task_model.dart';
import 'package:share_plus/share_plus.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final Function(String email) onShareWithEmail;
  final VoidCallback onEditPressed;
  final VoidCallback? onToggleCompletion;

  const TaskTile({
    super.key,
    required this.task,
    required this.onShareWithEmail,
    required this.onEditPressed,
    this.onToggleCompletion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple[100],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Task Title, Checkbox, and Action Buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (value) => onToggleCompletion?.call(),
                activeColor: Colors.deepPurple,
                checkColor: Colors.white,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontFamily: GoogleFonts.poppins().fontFamily,
                        fontWeight: FontWeight.w600,
                        color:
                            task.isCompleted
                                ? Colors.deepPurple.withOpacity(0.6)
                                : Colors.deepPurple[900],
                        decoration:
                            task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: GoogleFonts.inter().fontFamily,
                          color: Colors.deepPurple[700]?.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.deepPurple),
                    tooltip: "Edit Task",
                    onPressed: onEditPressed,
                  ),
                  IconButton(
                    icon: const Icon(Icons.email, color: Colors.deepPurple),
                    tooltip: "Share via Email",
                    onPressed: () => _showEmailShareDialog(context),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.deepPurple),
                    tooltip: "Share externally",
                    onPressed: () => _shareTaskExternally(),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          /// Priority and Due Date
          Wrap(
            spacing: 8,
            children: [
              if (task.priority != 'none')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        task.priority == 'high'
                            ? Colors.red.withOpacity(0.2)
                            : task.priority == 'medium'
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.priority.capitalize(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color:
                          task.priority == 'high'
                              ? Colors.red
                              : task.priority == 'medium'
                              ? Colors.orange
                              : Colors.green,
                    ),
                  ),
                ),
              if (task.dueDate != null)
                Text(
                  'Due: ${task.dueDate!.toDate().toLocal().toString().split(' ')[0]}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.deepPurple[700]?.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEmailShareDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(
              "Share Task via Email",
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            content: TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Enter email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.inter(color: Colors.deepPurple),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  final email = emailController.text.trim();
                  if (email.isNotEmpty) {
                    onShareWithEmail(email);
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  "Share",
                  style: GoogleFonts.inter(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _shareTaskExternally() {
    final message = '''
📌 *Task Shared with You* 📌

📝 Title: ${task.title}
📄 Description: ${task.description}
${task.isCompleted ? '✅ Status: Completed' : '⏳ Status: Pending'}
${task.priority != 'none' ? '🔥 Priority: ${task.priority.capitalize()}' : ''}
${task.dueDate != null ? '📅 Due: ${task.dueDate!.toDate().toLocal().toString().split(' ')[0]}' : ''}

Login to the app to view the full task!

Task ID: ${task.id}
''';
    Share.share(message);
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
