import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ophth_board/core/views/widgets/custom_bottom_sheet.dart';
import 'package:ophth_board/features/evaluations/provider/resident_evaluation_provider.dart';
import 'resident_evaluation_result_screen.dart';
import '../../../core/models/user.dart';
import '../../../core/providers/auth_provider.dart';
import 'widgets/evaluation_list_card.dart';
import 'resident_evaluation_form_view.dart';

/// Evaluation list screen styled like the leave list screen.
/// If [rotationId] or [residentId] is provided, it will fetch that specific list.
/// Otherwise it falls back to the currently authenticated user to decide.
class EvaluationListScreen extends ConsumerStatefulWidget {
  final String? rotationId;
  final String? residentId;
  final String title;

  const EvaluationListScreen({
    super.key,
    this.rotationId,
    this.residentId,
    this.title = 'Evaluations',
  });

  @override
  ConsumerState<EvaluationListScreen> createState() => _EvaluationListScreenState();
}

class _EvaluationListScreenState extends ConsumerState<EvaluationListScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  String _searchQuery = '';
  bool _isSearchVisible = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
      if (!_isSearchVisible) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
    
    if (_isSearchVisible) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    if (widget.rotationId == null && widget.residentId == null && currentUser == null) {
      return Scaffold(
        appBar: _buildAppBar(context, theme),
        body: _buildEmptyState(context, 'Please sign in to view evaluations'),
      );
    }

    // Choose provider precedence: explicit args > current user role
    final provider = (widget.rotationId != null)
        ? getAllEvaluationsForRotationProvider(widget.rotationId!)
        : (widget.residentId != null)
        ? getAllEvaluationsForResidentProvider(widget.residentId!)
        : (currentUser!.role == UserRole.resident
              ? getAllEvaluationsForResidentProvider(currentUser.id)
              : getAllEvaluationsForRotationProvider(currentUser.id));

    final evaluationsList = ref.watch(provider);

    return Scaffold(
      appBar: _buildAppBar(context, theme),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(provider);
        },
        child: evaluationsList.when(
          data: (evaluationList) {
            final filteredList = _filterEvaluations(evaluationList);
            
            if (filteredList.isEmpty && _searchQuery.isNotEmpty) {
              return _buildEmptyState(context, 'No evaluations found for "$_searchQuery"');
            }
            
            if (filteredList.isEmpty) {
              return _buildEmptyState(context, 'No evaluations found');
            }

            return _buildEvaluationsList(filteredList);
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(context, error.toString()),
        ),
      ),
      floatingActionButton: currentUser?.role == UserRole.supervisor
          ? _buildFloatingActionButton(context, theme)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 2,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Search evaluations...',
                  hintStyle: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : Text(
                widget.title,
                key: const ValueKey('title'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
      actions: [
        AnimatedRotation(
          turns: _isSearchVisible ? 0.25 : 0,
          duration: const Duration(milliseconds: 300),
          child: IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _isSearchVisible ? 'Close search' : 'Search evaluations',
          ),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilterOptions,
          tooltip: 'Filter evaluations',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
      ),
    );
  }

  List<dynamic> _filterEvaluations(List<dynamic> evaluations) {
    if (_searchQuery.isEmpty) return evaluations;
    
    return evaluations.where((evaluation) {
      final residentName = evaluation.residentName.toLowerCase();
      final rotationTitle = evaluation.rotationTitle.toLowerCase();
      final supervisorName = evaluation.supervisorName.toLowerCase();
      
      return residentName.contains(_searchQuery) ||
             rotationTitle.contains(_searchQuery) ||
             supervisorName.contains(_searchQuery);
    }).toList();
  }

  Widget _buildEvaluationsList(List<dynamic> evaluationList) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 16),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildStatsCard(evaluationList),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final evaluation = evaluationList[index];
                return TweenAnimationBuilder<double>(
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: EvaluationListCard(
                            evaluation: evaluation,
                            onView: () => _handleEvaluationTap(evaluation),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              childCount: evaluationList.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 80), // Space for FAB
        ),
      ],
    );
  }

  Widget _buildStatsCard(List<dynamic> evaluationList) {
    final theme = Theme.of(context);
    final completedCount = evaluationList.where((e) => e.id != null).length;
    final pendingCount = evaluationList.length - completedCount;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.3),
              theme.colorScheme.secondaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                icon: Icons.assignment_turned_in,
                label: 'Completed',
                value: completedCount.toString(),
                color: Colors.green,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.pending_actions,
                label: 'Pending',
                value: pendingCount.toString(),
                color: Colors.orange,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: theme.colorScheme.outline.withOpacity(0.3),
            ),
            Expanded(
              child: _buildStatItem(
                icon: Icons.analytics,
                label: 'Total',
                value: evaluationList.length.toString(),
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading evaluations...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Trigger a rebuild to retry
                setState(() {});
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Evaluations Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, ThemeData theme) {
    return FloatingActionButton.extended(
      onPressed: () {
        _showCreateEvaluationDialog(context);
      },
      icon: const Icon(Icons.add),
      label: const Text('New Evaluation'),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
    );
  }

  void _handleEvaluationTap(dynamic evaluation) {
    if (evaluation.id != null) {
      CustomBottomSheet.show(
        context: context,
        child: EvaluationResultsScreen(
          evaluationId: evaluation.id!,
          residentName: evaluation.residentName.isNotEmpty
              ? evaluation.residentName
              : 'Resident',
          residentLevel: evaluation.trainingLevelDisplay,
        ),
      );
    } else {
      CustomBottomSheet.show(
        context: context,
        child: ResidentEvaluationFormView(
          residentName: evaluation.residentName,
          rotationId: evaluation.rotationId,
          supervisorId: evaluation.supervisorId,
          residentId: evaluation.residentId,
          supervisorName: evaluation.supervisorName,
          rotationName: evaluation.rotationTitle,
        ),
      );
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Options',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.assignment_turned_in),
                title: const Text('Completed Only'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement filter logic
                },
              ),
              ListTile(
                leading: const Icon(Icons.pending_actions),
                title: const Text('Pending Only'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement filter logic
                },
              ),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('By Date Range'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement date range picker
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showCreateEvaluationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Evaluation'),
        content: const Text('Would you like to create a new evaluation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to evaluation creation form
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
