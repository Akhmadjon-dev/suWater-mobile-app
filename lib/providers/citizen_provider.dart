import 'package:flutter/foundation.dart';
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repo.updateProfile(data);
      if (!mounted) return true;
      state = CitizenProfileState(profile: profile);
      return true;
    } catch (e) {
      debugPrint('CitizenProfileNotifier.updateProfile failed: $e');
      if (!mounted) return false;
      state = state.copyWith(isLoading: false, error: 'Failed to update profile');
      return false;
    }
  }
}

final citizenProfileProvider =
    StateNotifierProvider<CitizenProfileNotifier, CitizenProfileState>((ref) {
  return CitizenProfileNotifier(ref.read(citizenRepositoryProvider));
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

  ReadingsState copyWith({
    List<WaterReading>? readings,
    WaterReading? latest,
    double? totalConsumption,
    int? page,
    int? totalPages,
    int? total,
    bool? isLoading,
    String? error,
  }) {
    return ReadingsState(
      readings: readings ?? this.readings,
      latest: latest ?? this.latest,
      totalConsumption: totalConsumption ?? this.totalConsumption,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReadingsNotifier extends StateNotifier<ReadingsState> {
  final CitizenRepository _repo;

  ReadingsNotifier(this._repo) : super(ReadingsState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final latestResult = await _repo.getLatestReading();
      final result = await _repo.getReadings(page: 1);
      if (!mounted) return;
      state = ReadingsState(
        latest: latestResult.latest,
        totalConsumption: latestResult.totalConsumption,
        readings: result.data,
        page: result.page,
        totalPages: result.totalPages,
        total: result.total,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: 'Failed to load readings');
    }
  }

  Future<void> loadMore() async {
    if (state.page >= state.totalPages || state.isLoading) return;
    final nextPage = state.page + 1;
    try {
      final result = await _repo.getReadings(page: nextPage);
      if (!mounted) return;
      state = state.copyWith(
        readings: [...state.readings, ...result.data],
        page: result.page,
        totalPages: result.totalPages,
        total: result.total,
      );
    } catch (e) {
      debugPrint('ReadingsNotifier.loadMore failed: $e');
    }
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
    } catch (e) {
      debugPrint('ReadingsNotifier.deleteReading failed: $e');
    }
  }
}

final readingsProvider =
    StateNotifierProvider<ReadingsNotifier, ReadingsState>((ref) {
  return ReadingsNotifier(ref.read(citizenRepositoryProvider));
});
