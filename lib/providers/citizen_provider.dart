import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:suwater_mobile/repositories/citizen_repository.dart';

// ─── Profile State ──────────────────────────────────────────────────────────

class CitizenProfileState {
  final CitizenProfile? profile;
  final bool isLoading;
  final String? error;

  CitizenProfileState({this.profile, this.isLoading = false, this.error});

  CitizenProfileState copyWith({
    CitizenProfile? profile,
    bool? isLoading,
    String? error,
  }) {
    return CitizenProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CitizenProfileNotifier extends StateNotifier<CitizenProfileState> {
  final CitizenRepository _repo;

  CitizenProfileNotifier(this._repo) : super(CitizenProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repo.getProfile();
      if (!mounted) return;
      state = CitizenProfileState(profile: profile);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: 'Failed to load profile');
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final profile = await _repo.updateProfile(data);
      state = CitizenProfileState(profile: profile);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final citizenProfileProvider =
    StateNotifierProvider<CitizenProfileNotifier, CitizenProfileState>((ref) {
  return CitizenProfileNotifier(CitizenRepository());
});

// ─── Readings State ─────────────────────────────────────────────────────────

class ReadingsState {
  final List<WaterReading> readings;
  final WaterReading? latest;
  final double totalConsumption;
  final int page;
  final int totalPages;
  final int total;
  final bool isLoading;
  final String? error;

  ReadingsState({
    this.readings = const [],
    this.latest,
    this.totalConsumption = 0.0,
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.isLoading = false,
    this.error,
  });
}

class ReadingsNotifier extends StateNotifier<ReadingsState> {
  final CitizenRepository _repo;

  ReadingsNotifier(this._repo) : super(ReadingsState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    if (!mounted) return;
    state = ReadingsState(isLoading: true);
    try {
      final latestResult = await _repo.getLatestReading();
      final result = await _repo.getReadings(page: 1);
      if (!mounted) return;
      state = ReadingsState(
        latest: latestResult['latest'] as WaterReading?,
        totalConsumption: latestResult['total_consumption'] as double,
        readings: result['data'] as List<WaterReading>,
        page: result['page'] as int,
        totalPages: result['totalPages'] as int,
        total: result['total'] as int,
      );
    } catch (e) {
      if (!mounted) return;
      state = ReadingsState(error: 'Failed to load readings');
    }
  }

  Future<void> loadMore() async {
    if (state.page >= state.totalPages || state.isLoading) return;
    final nextPage = state.page + 1;
    try {
      final result = await _repo.getReadings(page: nextPage);
      state = ReadingsState(
        latest: state.latest,
        readings: [...state.readings, ...result['data'] as List<WaterReading>],
        page: result['page'] as int,
        totalPages: result['totalPages'] as int,
        total: result['total'] as int,
      );
    } catch (_) {}
  }

  Future<bool> addReading(double value, {String? notes}) async {
    try {
      await _repo.createReading(readingValue: value, notes: notes);
      await loadAll();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteReading(String id) async {
    try {
      await _repo.deleteReading(id);
      await loadAll();
    } catch (_) {}
  }
}

final readingsProvider =
    StateNotifierProvider<ReadingsNotifier, ReadingsState>((ref) {
  return ReadingsNotifier(CitizenRepository());
});
