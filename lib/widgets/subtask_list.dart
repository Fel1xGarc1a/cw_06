import 'package:flutter/material.dart';
import '../models/task.dart';

class SubtaskList extends StatelessWidget {
  final Task task;

  const SubtaskList({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    if (task.subtasks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No subtasks added yet'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: task.subtasks.length,
      itemBuilder: (context, index) {
        final entry = task.subtasks.entries.elementAt(index);
        final dayTimeRange = entry.key;
        final subtasks = entry.value;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayTimeRange,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Divider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: subtasks.length,
                  itemBuilder: (context, subtaskIndex) {
                    return ListTile(
                      dense: true,
                      title: Text(subtasks[subtaskIndex]),
                      leading: const Icon(Icons.arrow_right),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 