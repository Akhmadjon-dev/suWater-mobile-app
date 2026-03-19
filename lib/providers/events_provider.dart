import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwater_mobile/models/event.dart';
import 'package:suwater_mobile/models/comment.dart';
import 'package:suwater_mobile/repositories/events_repository.dart';

final eventsRepositoryProvider = Provider<EventsRepository>((ref) {
  return EventsRepository();
});

// Status display order (workflow priority)
const statusOrder = [
  EventStatus.inProgress,
  EventStatus.createdAssigned,
  EventStatus.reported,
  EventStatus.completed,
  EventStatus.cancelled,
  EventStatus.archived,
];

class EventsListState {
  final List<WaterEvent> events;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final int totalPages;
  final int total;
  final bool hasReachedEnd;
  final bool filtersVisible;
  final EventStatus? filterStatus;
  final EventType? filterType;
  final EventPriority? filterPriority;

  const EventsListState({
    this.events = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.hasReachedEnd = false,
    this.filtersVisible = false,
    this.filterStatus,
    this.filterType,
    this.filterPriority,
  });

  EventsListState copyWith({
    List<WaterEvent>? events,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    int? totalPages,
    int? total,
    bool? hasReachedEnd,
    bool? filtersVisible,
    EventStatus? filterStatus,
    EventType? filterType,
    EventPriority? filterPriority,
    bool clearFilterStatus = false,
    bool clearFilterType = false,
    bool clearFilterPriority = false,
  }) {
    return EventsListState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      filtersVisible: filtersVisible ?? this.filtersVisible,
      filterStatus: clearFilterStatus ? null : (filterStatus ?? this.filterStatus),
      filterType: clearFilterType ? null : (filterType ?? this.filterType),
      filterPriority: clearFilterPriority ? null : (filterPriority ?? this.filterPriority),
    );
  }

  bool get hasActiveFilters =>
      filterStatus != null || filterType != null || filterPriority != null;

  /// Group events by status in workflow order
  Map<EventStatus, List<WaterEvent>> get grouped {
    final map = <EventStatus, List<WaterEvent>>{};
    for (final status in statusOrder) {
      final items = events.where((e) => e.status == status).toList();
      if (items.isNotEmpty) {
        map[status] = items;
      }
    }
    return map;
  }

  /// Count per status from loaded events
  Map<EventStatus, int> get statusCounts {
    final counts = <EventStatus, int>{};
    for (final e in events) {
      counts[e.status] = (counts[e.status] ?? 0) + 1;
    }
    return counts;
  }
}

class EventsNotifier extends StateNotifier<EventsListState> {
  final EventsRepository _repo;

  EventsNotifier(this._repo) : super(const EventsListState());

  Future<void> loadEvents({int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, error: null, hasReachedEnd: false);
    }

    try {
      final response = await _repo.getEvents(
        page: page,
        status: state.filterStatus?.value,
        type: state.filterType?.value,
        priority: state.filterPriority?.value,
      );

      final newEvents = page == 1
          ? response.data
          : [...state.events, ...response.data];

      state = state.copyWith(
        events: newEvents,
        isLoading: false,
        isLoadingMore: false,
        page: response.page,
        totalPages: response.totalPages,
        total: response.total,
        hasReachedEnd: response.page >= response.totalPages,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: 'Failed to load events: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.hasReachedEnd || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    await loadEvents(page: state.page + 1);
  }

  Future<void> refresh() async {
    state = state.copyWith(hasReachedEnd: false);
    await loadEvents(page: 1);
  }

  void setStatusFilter(EventStatus? status) {
    state = state.copyWith(
      filterStatus: status,
      clearFilterStatus: status == null,
    );
    loadEvents(page: 1);
  }

  void setTypeFilter(EventType? type) {
    state = state.copyWith(
      filterType: type,
      clearFilterType: type == null,
    );
    loadEvents(page: 1);
  }

  void setPriorityFilter(EventPriority? priority) {
    state = state.copyWith(
      filterPriority: priority,
      clearFilterPriority: priority == null,
    );
    loadEvents(page: 1);
  }

  void clearFilters() {
    state = state.copyWith(
      clearFilterStatus: true,
      clearFilterType: true,
      clearFilterPriority: true,
    );
    loadEvents(page: 1);
  }

  void toggleFilters() {
    state = state.copyWith(filtersVisible: !state.filtersVisible);
  }
}

final eventsProvider =
    StateNotifierProvider<EventsNotifier, EventsListState>((ref) {
  return EventsNotifier(ref.read(eventsRepositoryProvider));
});

// Single event detail
final eventDetailProvider =
    FutureProvider.family<WaterEvent, String>((ref, eventId) async {
  final repo = ref.read(eventsRepositoryProvider);
  return repo.getEvent(eventId);
});

// Event assignments
final eventAssignmentsProvider =
    FutureProvider.family<List<EventAssignment>, String>((ref, eventId) async {
  final repo = ref.read(eventsRepositoryProvider);
  return repo.getAssignments(eventId);
});

// Event comments
final eventCommentsProvider =
    FutureProvider.family<List<EventComment>, String>((ref, eventId) async {
  final repo = ref.read(eventsRepositoryProvider);
  return repo.getComments(eventId);
});
