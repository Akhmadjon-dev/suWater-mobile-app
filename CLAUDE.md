# CLAUDE.md — suWater Mobile App

## Workflow Orchestration

### 1. Plan Mode Default
- Enter plan mode for ANY non-trivial task (3+ steps or architectural decisions)
- If something goes sideways, STOP and re-plan immediately
- Use plan mode for verification steps, not just building
- Write detailed specs upfront to reduce ambiguity

### 2. Subagent Strategy
- Use subagents liberally to keep main context window clean
- Offload research, exploration, and parallel analysis to subagents
- For complex problems, throw more compute at it via subagents
- One task per subagent for focused execution

### 3. Self-Improvement Loop
- After ANY correction from the user: update tasks/lessons.md with the pattern
- Write rules for yourself that prevent the same mistake
- Ruthlessly iterate on these lessons until mistake rate drops
- Review lessons at session start for relevant project

### 4. Verification Before Done
- Never mark a task complete without proving it works
- Diff behavior between main and your changes when relevant
- Ask yourself: "Would a staff engineer approve this?"
- Run tests, check logs, demonstrate correctness

### 5. Demand Elegance (Balanced)
- For non-trivial changes: pause and ask "is there a more elegant way?"
- If a fix feels hacky: "Knowing everything I know now, implement the elegant solution"
- Skip this for simple, obvious fixes -- don't over-engineer
- Challenge your own work before presenting it

### 6. Autonomous Bug Fixing
- When given a bug report: just fix it. Don't ask for hand-holding
- Point at logs, errors, failing tests -- then resolve them
- Zero context switching required from the user
- Go fix failing CI tests without being told how

## Task Management

1. Plan First: Write plan to tasks/todo.md with checkable items
2. Verify Plan: Check in before starting implementation
3. Track Progress: Mark items complete as you go
4. Explain Changes: High-level summary at each step
5. Document Results: Add review section to tasks/todo.md
6. Capture Lessons: Update tasks/lessons.md after corrections

## Core Principles

- Simplicity First: Make every change as simple as possible. Impact minimal code.
- No Laziness: Find root causes. No temporary fixes. Senior developer standards.
- Minimal Impact: Only touch what's necessary. No side effects with new bugs.

## Git Commits

- When committing, never include the `Co-authored-by` or any Claude/AI signature in commit messages. Commit as the user only.
- Use conventional commits: `feat:`, `fix:`, `refactor:`, `chore:`, `docs:`, `test:`
- Keep commit messages concise and descriptive of the actual change

---

## Project Architecture Rules

### Architecture: Clean Architecture + Riverpod

This project follows a strict layered architecture. Never violate the dependency direction:

```
UI (Screens/Widgets) → Providers (Riverpod) → Repositories → API Client (Dio)
```

**Rules:**
- Screens must NEVER call repositories or DioClient directly. Always go through providers.
- Repositories must NEVER import or reference any UI widget or provider.
- Models are pure data classes — no business logic, no UI logic, no provider references.
- Providers are the single bridge between UI and data. All state mutations happen here.

### Folder Structure Convention

```
lib/
├── core/           # Shared infrastructure (api, router, theme, storage, widgets)
├── features/       # Feature modules grouped by user role
│   ├── auth/
│   ├── citizen/
│   └── worker/
├── models/         # Domain models (pure Dart, no Flutter imports)
├── providers/      # Riverpod providers (state management)
└── repositories/   # Data access layer (API calls, data mapping)
```

**Rules:**
- New features go under `features/<role>/<feature_name>/`
- Each feature folder can contain: screen, widgets subfolder, and feature-specific helpers
- Shared widgets go in `core/widgets/`
- Never create a `utils/` or `helpers/` dump folder — place helpers near their usage

### State Management (Riverpod)

**Rules:**
- Use `StateNotifierProvider` for complex state with multiple mutations (lists, forms, auth)
- Use `FutureProvider.family` for async single-item fetches (detail screens)
- Use `Provider` for simple dependency injection (repositories)
- Every state class must have: data, loading, and error fields — never leave error states unhandled
- Every state class must have a `copyWith()` method — never create a new state that drops existing fields (e.g., `State(isLoading: true)` loses all other data)
- When setting loading state, always use `state = state.copyWith(isLoading: true)` — never `state = State(isLoading: true)`
- Always check `if (!mounted) return;` after every `await` in StateNotifier methods
- Filter/action methods that call async providers must return `Future<void>` — never fire-and-forget
- Always invalidate or refresh dependent providers when upstream data changes
- Dispose controllers and listeners properly in `ConsumerStatefulWidget.dispose()`
- Never use `setState()` for data that should be in a provider. Local UI state only (animations, text controllers) can use `setState()`

### Data Layer Rules

**Models:**
- All models live in `lib/models/` — NEVER define model classes inside repository files
- All models use `factory fromJson(Map<String, dynamic>)` constructors with explicit `as Type` casts
- Use safe type casting helpers (`_toDouble()`, `_toInt()`) for API response parsing — never trust the backend type
- All model fields that can be null from API must be nullable (`String?`, not `String`)
- Enums must have a fallback/unknown case with `debugPrint` warning to prevent silent data corruption
- Every state class must have a `copyWith()` method — never replace full state when only updating a subset

**Repositories:**
- One repository per domain area (auth, events, citizen, documents)
- Every repository must have a corresponding Riverpod `Provider` (e.g., `citizenRepositoryProvider`) — never instantiate directly with `Repository()`
- Repositories return typed models or typed response classes — NEVER return raw `Map<String, dynamic>` to providers
- Every repository method must have a try-catch with `debugPrint` and `rethrow` — never let errors go unlogged
- When returning paginated data, use a typed response class (e.g., `ReadingsResponse`) not a Map
- Token management stays in `DioClient` interceptors — repositories don't handle auth headers

**API Client:**
- All endpoints defined in `core/api/endpoints.dart` — never hardcode URL paths or use string interpolation for URLs
- For resource-by-ID endpoints, create named methods (e.g., `Endpoints.laborById(eventId, laborId)`) — never concatenate `'${Endpoints.labor(eventId)}/$id'`
- Base URLs come from `.env` files via `flutter_dotenv` — never commit real API URLs
- If `API_BASE_URL` env var is missing, fail fast with an error — never fall back to localhost silently
- Token refresh is handled by Dio interceptors automatically — don't retry manually in repositories
- Always validate token refresh responses (check HTTP status + field existence) before storing tokens

### UI & Widget Rules

**Screens:**
- All screens extend `ConsumerWidget` or `ConsumerStatefulWidget`
- Use `ref.watch()` for reactive state in `build()`, `ref.read()` for one-time actions in callbacks
- Never call `ref.watch()` inside callbacks, event handlers, or `initState()`
- Handle all three states in UI: loading (shimmer/spinner), error (user-friendly message + retry), data

**Widgets:**
- Extract widget subtrees into separate widgets when they exceed ~80 lines or are reused
- Prefer composition over inheritance — no deep widget class hierarchies
- Use `const` constructors wherever possible for performance
- Shared/reusable widgets go in `core/widgets/`, feature-specific widgets stay in their feature folder

**Theme & Styling:**
- Always use `AppColors`, `AppRadius`, `AppSpacing` constants from `core/theme/app_theme.dart` — never hardcode `Color(0xFF...)` values or magic numbers for spacing/radius
- Status colors and icons are defined in `core/theme/status_helpers.dart` — use them, don't duplicate
- This app uses Material 3 dark theme — respect the design system

**Date Formatting:**
- Use `DateFormatter` from `core/utils/date_formatter.dart` — never write inline date formatting logic
- Available methods: `.relative()`, `.relativeUz()`, `.dateTime()`, `.date()`, `.scheduled()`, `.compact()`
- Never duplicate date formatting in widgets — if a new format is needed, add it to `DateFormatter`

### Navigation (GoRouter)

- All routes defined in `core/router/app_router.dart`
- Use path parameters for entity IDs: `/worker/events/:id`
- Always null-check `state.pathParameters['id']` with a fallback — never use `!` null assertion on route params
- Auth and role-based redirects are handled in the router's `redirect` callback
- Never use `Navigator.push()` directly — always use `context.go()` or `context.push()` from GoRouter
- New screens must be registered in the router before use

### Error Handling

- NEVER use bare `catch (_) {}` or `catch (_)` — always capture the error variable and at minimum `debugPrint` it
- API errors: catch in providers, store in state, display in UI with retry option
- User-facing error messages must be human-readable — NEVER expose raw exception strings like `'Failed: $e'` to UI
- Use `DioException` status codes for error differentiation — never parse `e.toString().contains('401')` strings
- 401 errors are handled by DioClient token refresh — don't handle in providers
- 409 (duplicate), 400 (validation) — handle with specific user messages
- Repository methods: `debugPrint` + `rethrow` — let providers decide what to show the user
- Provider methods: catch, log, and store error in state — UI reads error from state

### Security & Configuration

- Tokens stored via `flutter_secure_storage` — never in SharedPreferences or plain text
- Never log tokens, passwords, or sensitive user data
- API keys, secrets, and org IDs go in `.env` files which are gitignored — never hardcode UUIDs or credentials in source code
- Validate all user input before sending to API (email format, required fields, etc.)
- Environment selection: use `--dart-define=ENV=production` at build time — the app loads `.env.$ENV` accordingly
- Always validate API responses before trusting them (check status codes, check field existence)

### Performance

- Use `const` widgets and constructors wherever possible
- Lists must use `ListView.builder` (lazy) — never `ListView(children: [...])` for dynamic data
- Images loaded from network must use `CachedNetworkImage` — never raw `Image.network()`
- Avoid unnecessary rebuilds: scope `ref.watch()` to the smallest widget that needs it
- Pagination: load more on scroll, don't fetch entire datasets at once

### Code Style

- Follow Dart/Flutter conventions: `lowerCamelCase` for variables/functions, `UpperCamelCase` for classes
- Use trailing commas for better formatting and cleaner diffs
- Keep methods under 40 lines — extract if longer
- Name files in `snake_case.dart`
- Private members prefixed with `_`
- Prefer `final` over `var` — immutability by default
- Use string interpolation `'$var'` not concatenation `'text' + var`

### What NOT to Do

- Do NOT add packages to `pubspec.yaml` without asking first — dependency management matters
- Do NOT create separate files for single-use helper functions — keep them near usage
- Do NOT write platform-specific code without handling all target platforms
- Do NOT use `print()` in production code — use `debugPrint()` for debug logs
- Do NOT ignore lint warnings — fix them or explicitly suppress with a comment explaining why
- Do NOT store state in global variables — always use Riverpod providers
- Do NOT hardcode strings that will be user-facing — prepare for localization with `intl`
- Do NOT use bare `catch (_) {}` — always log the error with `debugPrint`
- Do NOT expose raw exception messages to users — always use human-readable error messages
- Do NOT parse error types via `e.toString().contains()` — use `DioException` status codes
- Do NOT instantiate repositories directly (`Repository()`) — always use Riverpod providers
- Do NOT define models inside repository files — models belong in `lib/models/`
- Do NOT return `Map<String, dynamic>` from repositories — always create typed response classes
- Do NOT create new state objects that drop existing fields — always use `copyWith()`
- Do NOT duplicate utility logic (date formatting, etc.) — check `core/utils/` first, add methods there
- Do NOT use null assertion `!` on route parameters or API responses — always null-check with fallbacks
- Do NOT concatenate URL strings for endpoints — add named methods to `Endpoints` class
- Do NOT hardcode `Color(0xFF...)` in widgets — add to `AppColors` if missing
- Do NOT use magic numbers for spacing/radius — use `AppSpacing` and `AppRadius` constants

### Run Before Committing

- Run `flutter analyze` — fix all errors and warnings before committing
- Info-level hints (prefer_const) are acceptable but should be addressed when touching that code
