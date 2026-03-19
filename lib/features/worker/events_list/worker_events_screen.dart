import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwater_mobile/core/theme/app_theme.dart';
import 'package:suwater_mobile/providers/events_provider.dart';
import 'package:suwater_mobile/features/worker/events_list/widgets/stats_row.dart';
import 'package:suwater_mobile/features/worker/events_list/widgets/filter_panel.dart';
import 'package:suwater_mobile/features/worker/events_list/widgets/section_header.dart';
import 'package:suwater_mobile/features/worker/events_list/widgets/event_card.dart';

class WorkerEventsScreen extends ConsumerStatefulWidget {
  const WorkerEventsScreen({super.key});

  @override
  ConsumerState<WorkerEventsScreen> createState() => _WorkerEventsScreenState();
}

class _WorkerEventsScreenState extends ConsumerState<WorkerEventsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(eventsProvider.notifier).loadEvents());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(eventsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(eventsProvider);
    final notifier = ref.read(eventsProvider.notifier);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
            child: Row(
              children: [
                const Icon(Icons.water_drop, color: AppColors.primary, size: 28),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'WaterFlow',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                if (state.total > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.total}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(
                        state.filtersVisible
                            ? Icons.filter_list
                            : Icons.filter_list_outlined,
                        color: state.hasActiveFilters
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      onPressed: notifier.toggleFilters,
                    ),
                    if (state.hasActiveFilters)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Stats row
          if (!state.isLoading && state.events.isNotEmpty) ...[
            const SizedBox(height: 8),
            StatsRow(
              counts: state.statusCounts,
              total: state.total,
              activeFilter: state.filterStatus,
              onTap: (status) {
                notifier.setStatusFilter(status);
                if (!state.filtersVisible && status != null) {
                  notifier.toggleFilters();
                }
              },
            ),
          ],

          // Filter panel
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: state.filtersVisible
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: FilterPanel(
              selectedStatus: state.filterStatus,
              selectedType: state.filterType,
              selectedPriority: state.filterPriority,
              hasActiveFilters: state.hasActiveFilters,
              onStatusChanged: notifier.setStatusFilter,
              onTypeChanged: notifier.setTypeFilter,
              onPriorityChanged: notifier.setPriorityFilter,
              onClear: notifier.clearFilters,
            ),
            secondChild: const SizedBox(height: 0),
          ),

          const Divider(height: 1),

          // Content
          Expanded(
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2.5,
                    ),
                  )
                : state.error != null
                    ? _ErrorView(
                        error: state.error!,
                        onRetry: notifier.refresh,
                      )
                    : state.events.isEmpty
                        ? _EmptyView(
                            hasFilters: state.hasActiveFilters,
                            onClearFilters: notifier.clearFilters,
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            backgroundColor: AppColors.bgCard,
                            onRefresh: notifier.refresh,
                            child: _GroupedEventList(
                              state: state,
                              scrollController: _scrollController,
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _GroupedEventList extends StatelessWidget {
  final EventsListState state;
  final ScrollController scrollController;

  const _GroupedEventList({
    required this.state,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final grouped = state.grouped;
    final slivers = <Widget>[];

    for (final entry in grouped.entries) {
      // Section header
      slivers.add(
        SliverToBoxAdapter(
          child: SectionHeader(
            status: entry.key,
            count: entry.value.length,
          ),
        ),
      );

      // Event cards in this group
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  top: index == 0 ? 6 : 0,
                  bottom: index == entry.value.length - 1 ? 8 : 0,
                ),
                child: EventCard(event: entry.value[index]),
              );
            },
            childCount: entry.value.length,
          ),
        ),
      );
    }

    // Loading more indicator
    if (state.isLoadingMore) {
      slivers.add(
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    // End of list
    if (state.hasReachedEnd && state.events.isNotEmpty) {
      slivers.add(
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              child: Text(
                'All events loaded',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return CustomScrollView(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: slivers,
    );
  }
}

class _EmptyView extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClearFilters;

  const _EmptyView({required this.hasFilters, required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.bgSurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              size: 36,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'No events match filters' : 'No events assigned',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          if (hasFilters)
            TextButton(
              onPressed: onClearFilters,
              child: const Text('Clear filters'),
            )
          else
            const Text(
              'Pull down to refresh',
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
