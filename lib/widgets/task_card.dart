import 'package:flutter/material.dart';
import '../models/task_model.dart';

/// TaskCard - displays a single task with edit, delete, and toggle actions
class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isCompleted = task.isCompleted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? colorScheme.primaryContainer.withOpacity(0.4)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCompleted
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Completion toggle checkbox
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: isCompleted
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(width: 14),

            // Task content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? colorScheme.onSurface.withOpacity(0.5)
                          : colorScheme.onSurface,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: isCompleted
                            ? colorScheme.onSurface.withOpacity(0.35)
                            : colorScheme.onSurface.withOpacity(0.6),
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Date and status row
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: colorScheme.primary.withOpacity(0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.date,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.primary.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? colorScheme.primary.withOpacity(0.15)
                              : colorScheme.tertiary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isCompleted ? 'Completed' : 'Pending',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? colorScheme.primary
                                : colorScheme.tertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action buttons
            Column(
              children: [
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary.withOpacity(0.08),
                    minimumSize: const Size(36, 36),
                    padding: EdgeInsets.zero,
                  ),
                  tooltip: 'Edit task',
                ),
                const SizedBox(height: 6),
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: colorScheme.error,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.error.withOpacity(0.08),
                    minimumSize: const Size(36, 36),
                    padding: EdgeInsets.zero,
                  ),
                  tooltip: 'Delete task',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
