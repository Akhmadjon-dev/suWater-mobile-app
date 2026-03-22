# suWater Mobile App - Features Overview

**App Name:** WaterFlow (suwater_mobile)
**Version:** 1.0.0+1
**Platform:** Flutter (Dart 3.3.4+)
**Theme:** Material 3 Dark
**Language:** Uzbek (primary UI labels) + English

---

## Shared / Authentication

### Login
- Email + password authentication
- Password visibility toggle
- Loading state with spinner
- Role-specific error messages (invalid credentials, mobile access disabled, etc.)
- Automatic redirect to role-based dashboard after login

### Registration (Citizen Only)
- Two-step flow:
  - **Step 1 - Account:** Full name, email, phone (optional), password (min 6 chars)
  - **Step 2 - Citizen Profile:** Home number, meter number, abonent number, region/district dropdowns (Uzbekistan regions), address search with Nominatim geocoding
- Option to skip profile completion
- All registrations assigned CITIZEN role automatically
- Staff accounts are created by administrators (noted in UI)

### Session Management
- Automatic session restore on app restart (secure storage)
- JWT access + refresh token flow
- Automatic token refresh on 401 via Dio interceptors
- Secure token storage (flutter_secure_storage, in-memory fallback for web)
- Logout from profile screen (clears all stored data)

### Role-Based Routing
- Authenticated users redirected by role: Citizens to `/citizen`, Workers to `/worker`
- Unauthenticated users redirected to `/login`
- Supported roles in model: Admin, Supervisor, Dispatcher, Worker, Citizen
- Mobile routing currently supports: **Citizen** and **Worker**

---

## Citizen Role

Citizens interact with the app through a **3-tab bottom navigation**: Dashboard, Reports, Profile.

### 1. Dashboard (Home)

**Water Consumption Display**
- Total consumption in m3 (large typography)
- Latest reading date with relative time formatting (today, yesterday, X days ago)

**Two Sub-Tabs:**

- **"Hisobim" (My Account)** - Water readings list
  - Scrollable list of all readings with value (m3) and relative date
  - Empty state with quick "Add Reading" button
  - Loading spinner

- **"Ma'lumotlarim" (My Information)** - Profile card
  - Full name, region, district, home number, subscriber number, meter number, installation date, address

**Add Water Reading (Modal)**
- Triggered from camera icon or empty-state button
- Decimal input for reading value (m3)
- Optional notes field
- Validation (positive decimal number)
- Auto-refreshes readings list on save

### 2. My Reports (Arizalar)

**Reports List**
- Pull-to-refresh
- Each report card shows:
  - Color-coded status bar (top border)
  - Status badge + issue type
  - Report title
  - Location (address)
  - Assigned worker name (if assigned)
  - **Status progress bar** - 4-stage visual: Reported > Assigned > In Progress > Completed
  - Cancelled reports show red badge instead of progress bar
- Empty state with guidance to submit first report

### 3. Emergency Report Submission

**Issue Type Selection (6 types, grid layout):**
- Pipe Burst, Water Leak, Contamination, Valve Failure, Hydrant Damage, Other
- Color-coded selectable cards

**Form Fields:**
- Title (required)
- Description (optional, multiline)
- Address search (Nominatim autocomplete)
- GPS location button (device geolocation)
- Interactive map with pin placement (OpenStreetMap)
- Coordinates badge display

**Photo/Video Upload:**
- Required (at least 1, max 3)
- Camera capture or gallery selection
- Thumbnail preview with remove option
- Image compression (max 1920x1920, 85% quality)

**Submission:**
- Creates event + uploads media files
- Success feedback and redirect to dashboard

### 4. Citizen Profile

**Display:**
- Avatar with initial, full name, email
- Profile info card (phone, home number, meter number, subscriber number, region, district, address)

**Edit Profile (Bottom Sheet):**
- Editable fields: full name, home number, meter number, subscriber number
- Region/district dropdowns (Uzbekistan regions data)
- Address search with auto-fill of region/district from geocoding
- Save with loading state

**Logout** - Red outlined button, clears session

---

## Worker Role

Workers interact with the app through a **2-tab bottom navigation**: Events, Profile.

### 1. Events List

**Event Loading & Display:**
- Paginated list (20 per page) with infinite scroll
- Pull-to-refresh
- Events grouped by status in workflow order:
  1. In Progress
  2. Assigned
  3. Reported
  4. Completed
  5. Cancelled
  6. Archived
- Total assigned events count badge

**Filtering:**
- Status filter (In Progress, Assigned, Reported, Completed, Cancelled, Archived)
- Type filter (Leak, Pipe Burst, Contamination, Valve Failure, Hydrant Damage, Other)
- Priority filter (Low, Medium, High, Critical)
- Collapsible filter panel with clear-all button
- Active filter indicator dot

**Stats Row:**
- Horizontal scrollable pills showing count per status
- Tappable to quick-filter

**States:**
- Loading shimmer/spinner
- Empty state (no events vs no filter matches)
- Error state with retry

### 2. Event Detail

**Event Information:**
- Header with status + type + priority badges (gradient background)
- Title and description
- Priority indicator (color-coded dot)
- Scheduled date (DD.MM.YYYY HH:MM)
- Assigned supervisor name with avatar
- Location: address + coordinates with "Open in Maps" button
- Event details text
- Completion notes (green highlight, shown when completed)
- Timestamps: created (relative time) and completed date

**Pull-to-refresh** reloads event + all related data

### 3. Workflow Transitions

**State Machine:**
- **ASSIGNED** -> "START WORK" button (transitions to In Progress)
- **IN PROGRESS** -> "MARK COMPLETE" button (opens completion dialog)
  - Completion notes required (multiline input)
  - Transitions to Completed with notes
- **COMPLETED / CANCELLED / ARCHIVED** -> No action buttons (terminal states)

Loading states with disabled buttons and spinners during API calls.

### 4. Comments & Collaboration

**Comment Thread:**
- List of all event comments
- Each comment shows: avatar (initials), name, role badge, stage badge, timestamp, content
- Stage badge indicates workflow phase (e.g., PLANNING, EXECUTION)

**Add Comment:**
- Multiline text input with send button
- Empty comment prevention
- Auto-refresh after posting

### 5. Worker Assignments

- List of assigned workers per event
- Each worker card: avatar, name, role badge (LEAD / SUPPORT)
- Current user highlighted with "(You)" label and tinted background
- Contact info (phone/email) displayed

### 6. Resources Tracking

**Three resource categories:**

- **Labor:** Worker name, hours type (Regular/Overtime), work date, hours worked, start/end times
- **Equipment:** Equipment name, work date, units used, hours used, description
- **Materials:** Material name, work date, unit type, size/quantity, comments

Each category has loading, empty, and error states.

### 7. Documents & Media

**Upload:**
- Camera capture or gallery selection
- Image compression (max 1920x1920, 85% quality)
- Upload progress bar
- Auto-refresh after upload

**Display:**
- Image gallery: horizontal scrollable carousel with cached thumbnails + add button
- Other files: listed with type-specific icon (PDF in red), file name, size, download icon
- File type detection: images, PDFs, videos, generic documents

### 8. Worker Profile

- Avatar with initial, full name, role badge ("WORKER")
- Email and phone info cards
- Sign Out button (red outlined)

---

## Core Infrastructure

### API Layer
- Dio HTTP client (singleton) with 15s timeout
- Bearer token injection via interceptors
- Automatic 401 token refresh with isolated Dio instance
- All endpoints centralized in `endpoints.dart`
- Base URL from `.env` files (environment-specific)

### State Management
- Riverpod (StateNotifierProvider for complex state, FutureProvider.family for detail screens)
- Every state includes: data, loading, and error fields

### Navigation
- GoRouter with auth-aware redirects
- Role-based route protection

### Maps & Location
- Flutter Map with OpenStreetMap tiles (no API key)
- Nominatim geocoding for address search
- Device GPS via Geolocator
- Region-aware map centering (configured for Jizzakh, Uzbekistan)

### Storage
- flutter_secure_storage for tokens and user data
- Web platform fallback to in-memory storage

### Theme
- Material 3 dark theme
- Color palette: primary blue (#4A90D9), dark backgrounds (#0D1117 to #282E36)
- Status colors: Reported (orange), Assigned (blue), In Progress (yellow), Completed (green), Cancelled (red), Archived (gray)
- Priority colors: Low (green), Medium (yellow), High (orange), Critical (red)

### Dependencies (Key)
- flutter_riverpod, go_router, dio, flutter_secure_storage
- flutter_map, latlong2, geolocator
- image_picker, cached_network_image
- flutter_dotenv, intl



https://stitch.withgoogle.com/projects/13204884200183863843
