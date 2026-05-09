import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/firestore_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

/// AddEditTaskScreen - form screen for adding or editing a task
class AddEditTaskScreen extends StatefulWidget {
  /// Pass a [task] to edit it; pass null to create a new one
  final TaskModel? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;
  bool get _isEditing => widget.task != null;

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Pre-fill fields when editing
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _dateController.text = widget.task!.date;
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Opens Material date picker and updates date field
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme,
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateController.text = DateFormat('MMM dd, yyyy').format(picked);
    }
  }

  /// Handles save/update form submission
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final task = TaskModel(
        id: _isEditing ? widget.task!.id : '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        date: _dateController.text.trim(),
        isCompleted: _isEditing ? widget.task!.isCompleted : false,
      );

      if (_isEditing) {
        await _firestoreService.updateTask(task);
      } else {
        await _firestoreService.addTask(task);
      }

      if (!mounted) return;
      _showSuccess(_isEditing ? 'Task updated!' : 'Task added!');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to save task. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(msg),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header illustration area
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.primaryContainer.withOpacity(0.5),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isEditing
                              ? Icons.edit_note_rounded
                              : Icons.add_task_rounded,
                          size: 40,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isEditing ? 'Edit Task' : 'Create New Task',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                            Text(
                              _isEditing
                                  ? 'Update your task details'
                                  : 'Fill in the details below',
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.primary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Title field
                  CustomTextField(
                    label: 'Task Title *',
                    hint: 'Enter a clear task title',
                    controller: _titleController,
                    prefixIcon: Icons.title_rounded,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Task title is required';
                      }
                      if (val.trim().length < 3) {
                        return 'Title must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Description field
                  CustomTextField(
                    label: 'Description',
                    hint: 'Add a detailed description (optional)',
                    controller: _descriptionController,
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),

                  // Date picker field
                  CustomTextField(
                    label: 'Due Date *',
                    hint: 'Select a due date',
                    controller: _dateController,
                    prefixIcon: Icons.calendar_month_outlined,
                    readOnly: true,
                    onTap: _pickDate,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please select a due date';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 36),

                  // Save button
                  CustomButton(
                    label: _isEditing ? 'Update Task' : 'Add Task',
                    onPressed: _handleSave,
                    isLoading: _isLoading,
                    icon: _isEditing ? Icons.save_rounded : Icons.add_rounded,
                  ),
                  const SizedBox(height: 16),

                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: colorScheme.outline.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
