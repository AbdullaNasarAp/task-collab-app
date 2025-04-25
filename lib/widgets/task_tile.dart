import 'package:flutter/material.dart';
import 'package:task_collab_app/model/task_model.dart';
import 'package:share_plus/share_plus.dart';

class TaskTile extends StatelessWidget {
  final TaskModel task;
  final Function(String email) onShareWithEmail;

  const TaskTile({
    super.key,
    required this.task,
    required this.onShareWithEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Task Title and Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.email),
                tooltip: "Share via Email",
                onPressed: () => _showEmailShareDialog(context),
              ),

              IconButton(
                icon: const Icon(Icons.share),
                tooltip: "Share externally",
                onPressed: () => _shareTaskExternally(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(task.description),
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
            title: const Text("Share Task via Email"),
            content: TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Enter email",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final email = emailController.text.trim();
                  if (email.isNotEmpty) {
                    onShareWithEmail(email);
                    Navigator.pop(context);
                  }
                },
                child: const Text("Share"),
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

Login to the app to view the full task!

Task ID: ${task.id}
''';
    Share.share(message);
  }
}
