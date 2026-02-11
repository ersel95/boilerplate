# YK-Boilerplate iOS Template

## Overview
iOS SwiftUI boilerplate with MVVM-C architecture, VxHub SDK integration, and multi-environment support. Duplicate this project to start new iOS apps rapidly.

## Quick Start (New Project)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ersel95/boilerplate/main/create-project.sh)
```
The script handles renaming, bundle ID, xcodegen, and git init automatically.

## Architecture: MVVM-C (Model-View-ViewModel-Coordinator)

### Navigation Flow
- `AppCoordinator` — Root navigation manager, injected via SwiftUI environment
- `MainCoordinator` — Routes `AppScreens` enum to SwiftUI views
- `BaseCoordinator<T>` — Generic stack-based navigation with ViewModel caching
- `CoordinatorView` — SwiftUI wrapper binding NavigationStack + presentations

### Navigation Types
- `.push` — NavigationStack push
- `.sheet` — Modal sheet
- `.bottomSheet(detents:, isDraggable:, scrimColor:)` — Customizable bottom sheet
- `.fullScreenCover` — Full-screen modal
- `.popup(backgroundColor:, position:, isDismissable:)` — Custom overlay
- `.sideMenu` — Side menu overlay

### Adding a New Module
1. Create folder: `Modules/YourModule/`
2. Create screen enum: `YourModuleScreens.swift` conforming to `CoordinatorEntryPoint`
3. Add case to `AppScreens` enum in `MainCoordinator.swift`
4. Add navigation handler: `extension MainCoordinator { func handleYourModuleNavigation(...) }`
5. Create `YourView.swift` + `YourViewModel.swift` (extend `BaseViewModel`)
6. Wire delegation in `AppScreens` (id, navigationTitle, etc.)

### File Structure
```
YK-Boilerplate/
├── Application/           # App entry (BoilerplateApp, AppDelegate)
├── Core/
│   ├── BuildConfiguration/  # Dev/Staging/Prod xcconfig files
│   ├── Coordinator/         # Navigation system
│   ├── Networking/          # Alamofire API layer
│   │   ├── Base/            # BaseService, APITargetType, NetworkError
│   │   └── Services/        # Feature-specific API services
│   ├── Security/            # KeychainManager
│   ├── Constants/           # Environment config, error messages
│   ├── Utils/               # BaseViewModel, SessionManager, UserDefaults
│   ├── VxHub/               # VxHubManager bridge class
│   ├── Extensions/          # Swift extensions
│   └── Helpers/             # ThreadHelper, LazyView
├── Modules/                 # Feature modules (Splash, Auth, Home, etc.)
├── SharedUI/
│   ├── Components/          # AppButton, AppTextField, LoadingView, Toast
│   ├── Theme/               # Typography, Font+Custom
│   └── Modifiers/           # SwiftUI view modifiers
└── Assets/                  # xcassets, fonts
```

## VxHub SDK Integration

### Architecture
- `VxHubManager` (singleton) bridges VxHub SDK and the app
- Init in `AppDelegate.didFinishLaunchingWithOptions` (needs launchOptions + application)
- Warm start via `VxHubManager.shared.start()` in `BoilerplateApp` on `.active` scene phase
- `SplashViewModel` observes `VxHubManager.initState` via Combine
- Splash screen waits for SDK ready, then navigates to auth or home

### VxHub Provides (no separate integration needed)
- **RevenueCat** — In-app purchases, subscriptions, paywall UI
- **Amplitude** — Analytics, A/B testing
- **AppsFlyer** — Attribution
- **OneSignal** — Push notifications
- **Firebase** — Auth, analytics (GoogleService-Info.plist auto-downloaded)
- **Google/Apple Sign-In** — Social authentication
- **Facebook SDK** — Social auth + analytics
- **Sentry** — Crash reporting
- **SDWebImage** — Image loading/caching
- **Lottie** — Animations
- **Support** — Ticket-based customer support UI
- **Promo Codes** — Promotional code system
- **Retention Coins** — Reward system

### Common VxHub Usage Patterns
```swift
// Purchase
VxHub.shared.purchase(product) { result in ... }

// Analytics
VxHub.shared.logAmplitudeEvent(eventName: "screen_view", properties: ["screen": "home"])

// Show paywall (SwiftUI)
VxPaywallView(configuration: config, onPurchaseSuccess: { _ in }, onDismiss: { })

// Show support
VxSupportView(configuration: VxSupportConfiguration())

// Check premium
if VxHub.shared.isPremium { ... }

// Google Sign-In
try await VxHub.shared.signInWithGoogle(presenting: viewController)
```

## Networking

### Adding a New API Service
1. Create enum: `YourAPI.swift` conforming to `APITargetType`
2. Define endpoints with path, method, headers, parameters
3. Create service: `YourService.swift` extending `BaseService<YourAPI>`
4. Create protocol: `YourServiceProtocol.swift` for testability
5. Create mock: `YourMockService.swift` for development
6. Toggle real/mock via `EnvironmentsConstants.networkMode`

### APITargetType Protocol
```swift
protocol APITargetType {
    var baseUrl: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var parameters: RequestParameters? { get }
    var requiresAuth: Bool { get }
    var cachePolicy: CachePolicy { get }
    var retryCount: Int { get }
}
```

## Environment Configuration

### xcconfig Variables
| Variable | Description |
|----------|-------------|
| `PRODUCT_BUNDLE_IDENTIFIER` | App bundle ID |
| `PRODUCT_NAME` | Display name |
| `URL_SCHEME` | Deep link URL scheme |
| `BASE_URL` | API base URL |
| `ENVIRONMENT` | dev / staging / prod |
| `VXHUB_ID` | VxHub hub identifier |

### Build Configurations
- **Debug** — Dev xcconfig, mock-friendly
- **Release** — Prod xcconfig, optimized

## Coding Conventions

### Naming
- ViewModels: `{Feature}ViewModel` extending `BaseViewModel`
- Views: `{Feature}View` with `@ObservedObject var viewModel`
- Services: `{Feature}Service` with protocol `{Feature}ServiceProtocol`
- Screen enums: `{Module}Screens` conforming to `CoordinatorEntryPoint`

### Patterns
- Protocol-driven services (real + mock implementations)
- Dependency injection via initializers (not singletons, except managers)
- Navigation via `BaseViewModel.navigate(to:with:)`, never direct coordinator access
- State management via `UIStateManager<T>` for loading/data/toast/popup states
- Combine for reactive data flow (`@Published` + `sink`)

### Rules
- Always use `[weak self]` in closures
- Use `@MainActor` on ViewModels
- Never import UIKit in SwiftUI views (use coordinator for UIKit needs)
- Keep views dumb — all logic in ViewModels
- Use `Font.customFont(size:weight:)` for typography

## Dependencies
- **Alamofire** 5.10.2 — HTTP networking (app-level API calls)
- **VxHub** (SPM, branch: main) — Monetization, analytics, engagement SDK

## Project Generation
Uses XcodeGen (`project.yml`). After modifying project structure:
```bash
xcodegen generate
```
