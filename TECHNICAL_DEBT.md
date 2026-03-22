# Technical Debt Report — suWater Mobile App

> Generated: 2026-03-22 | ~8,800 LOC across ~44 Dart files

---

## Summary

| Severity | Count | Description |
|----------|-------|-------------|
| CRITICAL | 5 | Security risks, data loss potential, architectural violations |
| HIGH | 12 | Crash potential, silent failures, missing error handling |
| MEDIUM | 15 | Inconsistencies, duplication, maintainability blockers |
| LOW | 10 | Code style, magic numbers, minor improvements |

---

## CRITICAL

### 1. Zero Test Coverage
- **Location:** `test/` — only scaffold `widget_test.dart` exists
- **Impact:** No regression safety net. Every change risks breaking existing features.
- **Fix:** Add unit tests for repositories/providers, widget tests for key flows (login, report, event detail).

### 2. Hardcoded Organization UUID
- **Location:** [auth_repository.dart:50](lib/repositories/auth_repository.dart#L50) — `'org_id': 'c17ac9d4-f136-401a-a8bc-bffb2bf901c7'`
- **Impact:** App locked to single org. Cannot support multi-tenant deployment.
- **Fix:** Move to `.env` or fetch from auth response.

### 3. Hardcoded Active Region
- **Location:** [region.dart:81-83](lib/core/config/region.dart#L81-L83) — `const activeRegionKey = 'jizzakh'`
- **Impact:** App locked to single region. Deployment to other regions requires code change + recompile.
- **Fix:** Make region selectable at runtime or configurable via env/remote config.

### 4. Models Defined Inside Repository File
- **Location:** [citizen_repository.dart:4-72](lib/repositories/citizen_repository.dart#L4-L72) — `CitizenProfile` and `WaterReading` models inline
- **Impact:** Violates architecture (models in data layer), makes testing harder, hides models from project structure.
- **Fix:** Move to `lib/models/citizen_profile.dart` and `lib/models/water_reading.dart`.

### 5. Business Logic in UI Screens
- **Location:**
  - [citizen_report_screen.dart:147-212](lib/features/citizen/report/citizen_report_screen.dart#L147-L212) — direct `eventsRepo.createEvent()` + upload calls
  - [comments_section.dart:26-46](lib/features/worker/event_detail/comments_section.dart#L26-L46) — direct `repo.addComment()`
  - [transition_buttons.dart:24-45](lib/features/worker/event_detail/transition_buttons.dart#L24-L45) — direct `repo.transitionEvent()`
  - [documents_section.dart:20-38](lib/features/worker/event_detail/documents_section.dart#L20-L38) — upload logic inline
- **Impact:** Violates clean architecture. UI should only talk to providers, never repositories.
- **Fix:** Create dedicated providers for report submission, comments, transitions, and document uploads.

---

## HIGH

### 6. No Error Handling in Events Repository
- **Location:** [events_repository.dart](lib/repositories/events_repository.dart) — **zero try-catch blocks** across all methods
- **Impact:** Any API failure propagates as unhandled exception, potential app crash.
- **Fix:** Add try-catch with typed exceptions or let providers handle consistently.

### 7. Silent Exception Swallowing
- **Location:**
  - [citizen_provider.dart:126](lib/providers/citizen_provider.dart#L126) — `deleteReading()` bare `catch (_) {}`
  - [citizen_provider.dart:143](lib/providers/citizen_provider.dart#L143) — `loadMore()` bare `catch (_) {}`
  - [auth_repository.dart:72-77](lib/repositories/auth_repository.dart#L72-L77) — `getCurrentUser()` returns null on any error
  - [dio_client.dart:109-115](lib/core/api/dio_client.dart#L109-L115) — token refresh silently swallows all errors
- **Impact:** Bugs hidden. Failures invisible to user and developer. Impossible to debug production issues.
- **Fix:** At minimum `debugPrint` the error. Propagate to UI where user action is needed.

### 8. Missing toJson on 7 Model Classes
- **Location:** All models except `User` — `EventComment`, `EventDocument`, `WaterEvent`, `EventLabor`, `EventEquipment`, `EventMaterial`, `EventAssignment`
- **Impact:** Cannot serialize for API requests, caching, or logging.
- **Fix:** Add `toJson()` methods or adopt `freezed`/`json_serializable` (already in dev_dependencies but unused).

### 9. Missing == / hashCode on All Models
- **Location:** All 9 model classes
- **Impact:** Riverpod state comparison always treats objects as different → unnecessary rebuilds. Cannot use models in Sets or as Map keys.
- **Fix:** Implement equality or adopt `freezed` which generates it automatically.

### 10. Unsafe Null Assertions in Router
- **Location:** [app_router.dart:51](lib/core/router/app_router.dart#L51) — `state.pathParameters['id']!`
- **Impact:** Malformed deep links or URLs crash the app.
- **Fix:** Null-check with fallback redirect to events list.

### 11. Web Token Storage is Plaintext In-Memory
- **Location:** [secure_storage.dart:15,38-40](lib/core/storage/secure_storage.dart#L15) — `_webFallback` Map
- **Impact:** Tokens exposed to browser dev tools, extensions, any JS with memory access.
- **Fix:** Use encrypted web storage or session-only cookies.

### 12. Token Refresh Has No Response Validation
- **Location:** [dio_client.dart:88-94](lib/core/api/dio_client.dart#L88-L94)
- **Impact:** 500 errors or malformed responses silently corrupt auth state with invalid tokens.
- **Fix:** Validate HTTP status and check token fields exist before storing.

### 13. Loosely-Typed Repository Returns
- **Location:** [citizen_repository.dart:91-115](lib/repositories/citizen_repository.dart#L91-L115) — returns `Map<String, dynamic>` instead of typed models
- **Impact:** Type safety lost. Providers cast unsafely (`as WaterReading?`, `as double`).
- **Fix:** Create `LatestReadingResponse` and `PaginatedResponse<WaterReading>` models.

### 14. Inconsistent Repository Instantiation
- **Location:**
  - [citizen_provider.dart:59,149](lib/providers/citizen_provider.dart#L59) — `CitizenRepository()` directly instantiated
  - [auth_provider.dart:112](lib/providers/auth_provider.dart#L112) — uses `ref.read(authRepositoryProvider)`
  - [upload_provider.dart:49](lib/providers/upload_provider.dart#L49) — uses `ref.read(documentsRepositoryProvider)`
- **Impact:** Inconsistent DI pattern. Direct instantiation blocks testing with mocks.
- **Fix:** Create `citizenRepositoryProvider` and use it everywhere.

### 15. Missing Loading/Error States in Multiple Providers
- **Location:**
  - `CitizenProfileNotifier.updateProfile()` — no loading state
  - `ReadingsNotifier.addReading()` / `deleteReading()` — no loading or error state
  - `UploadNotifier.upload()` — doesn't reset `isUploading` on success
- **Impact:** UI cannot show progress or handle failures gracefully.

### 16. State Reset Bug in ReadingsNotifier
- **Location:** [citizen_provider.dart:95](lib/providers/citizen_provider.dart#L95)
- **Impact:** `ReadingsState(isLoading: true)` resets `totalConsumption`, `latest`, and all other fields to defaults. Data flashes away on reload.
- **Fix:** Use copyWith pattern: `state = state.copyWith(isLoading: true)`.

### 17. String-Based Error Parsing in Auth
- **Location:** [auth_provider.dart:63-68, 90-96](lib/providers/auth_provider.dart#L63-L68)
- **Impact:** Fragile `e.toString().contains()` checks. Any change in error message format breaks error handling.
- **Fix:** Use typed exceptions or DioException status codes.

---

## MEDIUM

### 18. Freezed/JsonSerializable Configured But Unused
- **Location:** [pubspec.yaml:42-43,56-57](pubspec.yaml#L42-L43) — `freezed_annotation`, `json_annotation`, `freezed`, `json_serializable` all present
- **Impact:** Manual `fromJson` factories everywhere. Missing `toJson`, `copyWith`, `==`, `hashCode` that freezed generates automatically.
- **Fix:** Migrate models to freezed. This fixes issues #8, #9, and reduces boilerplate significantly.

### 19. Duplicated Date Formatting Logic (4 implementations)
- **Location:**
  - [worker_event_detail_screen.dart:555-579](lib/features/worker/event_detail/worker_event_detail_screen.dart#L555-L579)
  - [event_card.dart](lib/features/worker/events_list/event_card.dart) — `_formatDate()`
  - [comments_section.dart:300-307](lib/features/worker/event_detail/comments_section.dart#L300-L307)
  - [citizen_home_screen.dart:313-325](lib/features/citizen/home/citizen_home_screen.dart#L313-L325)
- **Fix:** Create single `DateFormatter` utility in `core/`.

### 20. Oversized Build Methods
- **Location:**
  - [citizen_report_screen.dart:215-589](lib/features/citizen/report/citizen_report_screen.dart#L215-L589) — **374 lines**
  - [register_screen.dart:90-443](lib/features/auth/register_screen.dart#L90-L443) — **353 lines**
  - [citizen_profile_screen.dart:152-408](lib/features/citizen/profile/citizen_profile_screen.dart#L152-L408) — edit sheet **256 lines**
  - [worker_event_detail_screen.dart:21-208](lib/features/worker/event_detail/worker_event_detail_screen.dart#L21-L208) — **187 lines**
- **Fix:** Extract sections into separate widget classes.

### 21. Hardcoded Uzbek Strings Throughout UI
- **Location:** Scattered across all screens — "Bugun", "Kecha", "kun oldin", validation messages, form labels
- **Impact:** Cannot localize to other languages. Strings not centralized.
- **Fix:** Use `intl` package (already a dependency) with ARB files for localization.

### 22. Hardcoded Colors in Screens
- **Location:** [citizen_report_screen.dart:34-41](lib/features/citizen/report/citizen_report_screen.dart#L34-L41) — `Color(0xFF4A90D9)`, `Color(0xFF6BA5E7)`, `Color(0xFFFF8C42)`, etc.
- **Impact:** Bypasses theme system. Won't adapt if theme changes.
- **Fix:** Define in `AppColors` or theme extensions.

### 23. Duplicate API Call Patterns in Events Repository
- **Location:** [events_repository.dart:78-151](lib/repositories/events_repository.dart#L78-L151) — 5 identical `getX()` methods, 3 identical `addX()` methods, 3 identical `deleteX()` methods
- **Fix:** Generic helper method: `Future<List<T>> _fetchList<T>(String url, T Function(Map) fromJson)`.

### 24. Raw String URL Construction for Delete Endpoints
- **Location:**
  - [events_repository.dart:116](lib/repositories/events_repository.dart#L116) — `'${Endpoints.labor(eventId)}/$laborId'`
  - [events_repository.dart:133](lib/repositories/events_repository.dart#L133)
  - [events_repository.dart:150](lib/repositories/events_repository.dart#L150)
- **Fix:** Add `Endpoints.laborById(eventId, laborId)` etc.

### 25. Filter Methods Fire-and-Forget
- **Location:** [events_provider.dart:164,172,180,189](lib/providers/events_provider.dart#L164) — `setStatusFilter`, `setTypeFilter`, etc. call `loadEvents()` without `await`
- **Impact:** State changes asynchronously. Race conditions possible if filters change rapidly.

### 26. AddressSearchField Creates Own Dio Instance
- **Location:** [address_search_field.dart:67,127-143](lib/core/widgets/address_search_field.dart#L67)
- **Impact:** Bypasses app's DioClient. Cannot mock in tests. Duplicates HTTP config.
- **Fix:** Inject Dio or extract to a geocoding service.

### 27. LocationPickerMap Coupled to Global Region
- **Location:** [location_picker_map.dart:60](lib/core/widgets/location_picker_map.dart#L60) — directly imports `activeRegion`
- **Impact:** Cannot reuse for other regions. Hard to test.
- **Fix:** Accept region bounds as constructor parameter.

### 28. Enum Fallbacks Are Silent
- **Location:** All 4 enums (`EventStatus`, `EventType`, `EventPriority`, `UserRole`) silently fall back to defaults on unknown values
- **Impact:** API contract violations go unnoticed. New enum values from backend get silently mapped to wrong defaults.
- **Fix:** Add `debugPrint` warning on fallback.

### 29. Magic Numbers in Theme
- **Location:** [app_theme.dart](lib/core/theme/app_theme.dart) — scattered `BorderRadius.circular(12)`, `circular(10)`, `circular(6)`, padding values
- **Fix:** Define `AppRadius`, `AppSpacing` constants.

### 30. Missing Error States in Map/Location Widgets
- **Location:** [location_picker_map.dart](lib/core/widgets/location_picker_map.dart) — no loading indicator, no error fallback if tiles fail
- **Fix:** Add error builder and loading state.

---

## LOW

### 31. No Logging Framework
- All repositories and providers use no structured logging. Production debugging impossible.
- **Fix:** Add `logger` package or structured `debugPrint` wrapper.

### 32. Minimal Lint Rules
- [analysis_options.yaml](analysis_options.yaml) — uses default `flutter_lints` only, no custom rules enabled
- **Fix:** Enable `prefer_const_constructors`, `avoid_print`, `prefer_single_quotes`, `always_use_package_imports`.

### 33. Missing Accessibility
- No `Semantics` widgets, missing alt text on images, small touch targets, fixed font sizes.

### 34. EventAssignment.role is String Instead of Enum
- **Location:** [event.dart](lib/models/event.dart) — `role` field is `String` with comment `// lead | support`
- **Fix:** Create `EventAssignmentRole` enum.

### 35. Timestamp Fields Are Strings, Not DateTime
- All models store dates as `String` / `String?` instead of parsed `DateTime`.
- **Fix:** Parse in `fromJson`, format only in UI layer.

### 36. No Retry/Timeout Configuration on DioClient
- **Location:** [dio_client.dart](lib/core/api/dio_client.dart) — no connectTimeout, receiveTimeout, or retry interceptor
- **Fix:** Add timeouts and exponential backoff retry interceptor.

### 37. Constructor Error Handling in Notifiers
- [citizen_provider.dart:29-31,89-91](lib/providers/citizen_provider.dart#L29-L31) — constructors call async methods without error handling
- **Fix:** Wrap initial loads in try-catch or use AsyncValue.

### 38. Hardcoded Localhost Fallback URL
- [dio_client.dart:18](lib/core/api/dio_client.dart#L18) — `'http://localhost:3001/api/v1'`
- **Fix:** Fail fast with clear error if env var missing instead of silently connecting to localhost.

### 39. No Pagination Model
- Pagination handled ad-hoc in each provider/repository. No shared `PaginatedResponse<T>` model.

### 40. .env Files Listed as Flutter Assets
- [pubspec.yaml:63-64](pubspec.yaml#L63-L64) — `.env.development` and `.env.production` bundled as assets
- **Impact:** Both env files ship in production builds. Production app contains dev API URL.
- **Fix:** Use build flavors to include only the relevant env file.

---

## Recommended Fix Priority

### Phase 1 — Safety (Week 1)
1. Fix silent error swallowing (#7) — add at minimum `debugPrint`
2. Fix state reset bug (#16) — user-visible data loss
3. Add null-check in router (#10) — crash prevention
4. Validate token refresh response (#12) — auth stability
5. Move hardcoded org_id to env (#2)

### Phase 2 — Architecture (Week 2-3)
6. Move models out of repository file (#4)
7. Create providers for report/comments/transitions (#5) — restore clean architecture
8. Adopt freezed for all models (#18) — fixes #8, #9 automatically
9. Standardize repository DI pattern (#14)
10. Add typed response models (#13)

### Phase 3 — Quality (Week 3-4)
11. Add unit tests for providers and repositories (#1)
12. Extract oversized build methods (#20)
13. Centralize date formatting (#19)
14. Centralize hardcoded strings for i18n (#21)
15. Add endpoints for delete operations (#24)

### Phase 4 — Polish (Ongoing)
16. Enable stricter lint rules (#32)
17. Add structured logging (#31)
18. Add timeouts and retry to DioClient (#36)
19. Fix accessibility issues (#33)
20. Make region configurable (#3)
