# Project Context: `nest` (Flutter mobile-only)

This document summarizes the current codebase so another AI (or developer) can extend it safely without re-reading the entire repo.

## High-level behavior (end-to-end)

- **App starts** → loads backend base URL from `.env` (`API_BASE_URL`)
- **Hydrated storage initializes** → `AuthCubit` persists logged-in user locally
- **If user exists** (`AuthState.isAuthenticated`) → opens **role-based shell** with a drawer
- **If not logged in** → opens **login screen**
- **Drawer options** differ by user role (`hostel`, `gate`, `transport`) but **every option routes to the same Scan page**
- **Scan page** supports:
  - **QR scanner** (camera) using `mobile_scanner`
  - **Manual input fallback** (text field + submit)
  - Submits scanned/manual code to backend, then **renders response as HTML/markup**

## Repo layout (mobile-only)

The repo has been cleaned to mobile-only:

- **Platforms**: `android/`, `ios/`
- **No**: `web/`, `windows/`, `linux/`, `macos/`

## Entry points

- **App entrypoint**: `lib/main.dart`
  - Minimal: `WidgetsFlutterBinding.ensureInitialized()` → `AppBootstrap.build()` → `runApp(app)`
- **Bootstrap/DI**: `lib/app/bootstrap/app_bootstrap.dart`
  - Loads `.env`
  - Initializes `HydratedBloc.storage`
  - Creates `Dio`
  - Creates `AuthApi`, `AuthCubit`
  - Adds the `UserContextInterceptor` to Dio
  - Populates `AppGlobals`
  - Returns `MultiRepositoryProvider` + `MultiBlocProvider` wrapped around `App`
- **Root widget**: `lib/app/app.dart`
  - Uses `BlocBuilder<AuthCubit, AuthState>` to choose:
    - `ShellPage` if authenticated
    - `LoginPage` otherwise

## Environment configuration

- `.env` (included as a Flutter asset via `pubspec.yaml`)
- Expected variable:
  - `API_BASE_URL=https://...`

If `API_BASE_URL` is missing/empty, the app throws at startup.

## Dependencies (core)

From `pubspec.yaml`:

- **State**: `flutter_bloc`, `hydrated_bloc`, `equatable`
- **Network**: `dio`
- **Config**: `flutter_dotenv`
- **QR**: `mobile_scanner`
- **Rendering HTML/markup**: `flutter_widget_from_html`
- **Storage dir**: `path_provider`

## Global/shared utilities

### Globals

File: `lib/app/app_globals.dart`

- `AppGlobals.apiBaseUrl` (String)
- `AppGlobals.dio` (Dio)
- `AppGlobals.authCubit` (AuthCubit)
- `AppGlobals.dts` (AppTextSizes) used for consistent font sizing

### Theme colors

File: `lib/app/theme/app_colors.dart`

Centralized colors in `AppColors` (no hard-coded colors elsewhere where possible).

### Responsive sizing helper

File: `lib/app/utils/x_utils.dart`

- `XUtils.getDimensions(context)` returns `XDimensions` based on `MediaQuery.sizeOf(context)`
- Provides `wp(factor)` / `hp(factor)` helpers for dynamic sizing.

## Networking

### Routes (backend endpoints)

File: `lib/app/network/api_routes.dart`

Enhanced enum:

- `ApiRoute.login` → `'/auth/login'`
- `ApiRoute.scan` → `'/qr/scan'`

### Dio factory

File: `lib/app/network/dio_factory.dart`

Creates a `Dio` instance with:
- `baseUrl`
- 20s connect timeout
- 30s send/receive timeout

### User context interceptor (adds user info to requests)

File: `lib/app/network/api_client.dart`

Class: `UserContextInterceptor`

When `AuthCubit.state.user` exists:

- Adds headers:
  - `x-user-id: <user.id>`
  - `x-user-role: <user.role.name>`
  - `authorization: Bearer <token>` (only if token exists and non-empty)
- If request `options.data` is a `Map<String, dynamic>`, merges:
  - `userId: <user.id>`
  - `userRole: <user.role.name>`

This means **every scan/login/etc request** can automatically carry user context once authenticated.

## Authentication (login + persistence)

### Domain model

- `lib/features/auth/domain/user_role.dart`
  - Enhanced enum `UserRole`: `hostel`, `gate`, `transport`
  - `tryParse(String?)` maps string to enum by `.name`
- `lib/features/auth/domain/auth_user.dart`
  - Fields: `id`, `name`, `role`, `token?`
  - JSON: stores `role` as `role.name`

### API

File: `lib/features/auth/data/auth_api.dart`

Login request:

- `POST ApiRoute.login.path` (`/auth/login`)
- Body:
  - `username`
  - `password`

Expected login response (current assumption):

```json
{
  "id": "string",
  "name": "string",
  "role": "hostel|gate|transport",
  "token": "string (optional)"
}
```

If the backend returns different keys/shape, update `AuthApi.login(...)`.

### State management (Hydrated)

- `lib/features/auth/presentation/auth_state.dart`
  - `AuthState(user, isLoggingIn, errorMessage)`
  - `toJson` persists only `user`
  - `fromJson` restores `user`
- `lib/features/auth/presentation/auth_cubit.dart`
  - `login(username, password)` → calls `AuthApi.login`, saves user into state (persisted)
  - `logout()` → clears state (removes persisted user)

### UI

File: `lib/features/auth/presentation/login_page.dart`

- Fields: username + password
- CTA: `Continue`
- Shows backend URL as text (for debug/visibility)
- Errors are shown via `SnackBar` (from `errorMessage`)

## Role-based shell (drawer modularization)

### Drawer items enum

File: `lib/features/shell/domain/app_drawer_item.dart`

Enhanced enum `AppDrawerItem`:
- `scanEntry`, `scanExit`, `scanPackage`, `scanTransport`
- `forRole(UserRole role)` returns allowed items per role:
  - hostel → entry/exit/package
  - gate → entry/exit
  - transport → transport

### Shell page

File: `lib/features/shell/presentation/shell_page.dart`

- Reads authenticated user from `AuthCubit`
- Drawer shows:
  - user name
  - role label
  - role-specific drawer options
  - logout
- `body` always renders `ScanPage(title: selectedItem.title)`
  - The title is also sent as context in scan requests.

## Scanning feature (QR + manual input + response rendering)

### API

File: `lib/features/scan/data/scan_api.dart`

Request:
- `POST ApiRoute.scan.path` (`/qr/scan`)
- Body:
  - `code`
  - `context` (currently the drawer item title)

Response handling:
- If response is a `String` → treated as HTML/text content
- If response is `{"html": "<...>"}` → uses `html`
- If response is `{"message": "..."}` → uses `message`
- Otherwise → `toString()`

### State

- `lib/features/scan/presentation/scan_state.dart`
  - `isSubmitting`, `lastCode`, `responseHtml`, `errorMessage`
- `lib/features/scan/presentation/scan_cubit.dart`
  - `submit(code, contextLabel)` → calls `ScanApi.submitCode`, updates state
  - `clear()` → resets

### UI composition

File: `lib/features/scan/presentation/scan_page.dart`

- Creates feature-scoped `ScanApi` and `ScanCubit`
- Renders:
  - `ScannerCard` (QR)
  - `ScanInputCard` (manual fallback)
  - `ScanResponseView` (HTML + errors + loading)

Widgets:
- `lib/features/scan/presentation/widgets/scanner_card.dart`
  - Uses `MobileScanner`
  - Basic throttling: after detection, waits 2 seconds before allowing another scan
- `lib/features/scan/presentation/widgets/scan_input_card.dart`
  - TextField + Submit button
- `lib/features/scan/presentation/widgets/scan_response_view.dart`
  - Renders loading, errors, and HTML using `HtmlWidget`

## Mobile permissions

- Android camera permission:
  - `android/app/src/main/AndroidManifest.xml`
  - `<uses-permission android:name="android.permission.CAMERA" />`

- iOS camera usage text:
  - `ios/Runner/Info.plist`
  - `NSCameraUsageDescription`

## Testing

- `test/widget_test.dart` is a simple smoke test placeholder (no UI integration tests yet).

## Known intentional simplifications / next likely changes

- **Auth response shape** is assumed; adjust `AuthApi.login` once backend is confirmed.
- **Scan endpoint** and payload fields are assumed; adjust `ScanApi.submitCode`.
- **“Context label”** currently uses drawer title; you may want a stable enum name instead.
- **Error handling** is currently `e.toString()`; production apps usually map Dio errors to user-friendly messages.
- If you want stricter architecture: introduce feature modules + repositories + typed DTOs.

## “Where do I change X?”

- **Backend base URL**: `.env` (`API_BASE_URL`)
- **Login endpoint/path**: `lib/app/network/api_routes.dart` (`ApiRoute.login`)
- **Login request/response mapping**: `lib/features/auth/data/auth_api.dart`
- **Persisted user fields**: `lib/features/auth/domain/auth_user.dart`
- **Roles**: `lib/features/auth/domain/user_role.dart`
- **Drawer items per role**: `lib/features/shell/domain/app_drawer_item.dart`
- **Scan endpoint/payload/response parsing**: `lib/features/scan/data/scan_api.dart`
- **Attach user context to all requests**: `lib/app/network/api_client.dart` (`UserContextInterceptor`)

