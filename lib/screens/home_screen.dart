import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/quote_model.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../widgets/loading_widget.dart';
import '../widgets/quote_card.dart';
import '../widgets/task_card.dart';
import 'add_edit_task_screen.dart';
import 'login_screen.dart';

/// HomeScreen - main screen showing quote, task list, and actions
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final ApiService _apiService = ApiService();

  QuoteModel? _quote;
  bool _quoteLoading = true;
  String? _quoteError;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  /// Fetches a random motivational quote from the API
  Future<void> _fetchQuote() async {
    setState(() {
      _quoteLoading = true;
      _quoteError = null;
    });
    try {
      final quote = await _apiService.fetchRandomQuote();
      if (mounted) setState(() => _quote = quote);
    } catch (e) {
      if (mounted) {
        setState(() => _quoteError = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _quoteLoading = false);
    }
  }

  /// Shows logout confirmation dialog
  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Shows delete confirmation dialog and deletes task
  Future<void> _confirmDelete(String taskId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Task'),
        content: const Text(
            'Are you sure you want to delete this task? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _firestoreService.deleteTask(taskId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Task deleted successfully'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        _showError('Failed to delete task. Please try again.');
      }
    }
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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TaskFlow',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          // User avatar and logout
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PopupMenuButton<String>(
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onSelected: (val) {
                if (val == 'logout') _handleLogout();
              },
              child: CircleAvatar(
                backgroundColor: colorScheme.primary,
                radius: 20,
                child: Text(
                  (user?.email?.isNotEmpty == true)
                      ? user!.email![0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded,
                          color: colorScheme.error, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Sign Out',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // Quote section
          QuoteCard(
            quote: _quote,
            isLoading: _quoteLoading,
            error: _quoteError,
            onRefresh: _fetchQuote,
          ),

          // Task list header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: [
                Text(
                  'My Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Real-time task list via StreamBuilder
          Expanded(
            child: StreamBuilder<List<TaskModel>>(
              stream: _firestoreService.getTasksStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingWidget(message: 'Loading tasks...');
                }

                if (snapshot.hasError) {
                  return _buildErrorState(
                      snapshot.error.toString(), colorScheme);
                }

                final tasks = snapshot.data ?? [];

                if (tasks.isEmpty) {
                  return _buildEmptyState(colorScheme);
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskCard(
                      task: task,
                      onToggle: () async {
                        try {
                          await _firestoreService.toggleTaskCompletion(
                              task.id, task.isCompleted);
                        } catch (e) {
                          _showError('Failed to update task status.');
                        }
                      },
                      onEdit: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddEditTaskScreen(task: task),
                          ),
                        );
                      },
                      onDelete: () => _confirmDelete(task.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // FAB to add new task
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 72,
            color: colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Tasks Yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first task\nand start being productive.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.5),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 60, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your internet connection\nand try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}
