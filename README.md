# YK-Boilerplate

iOS SwiftUI project template with MVVM-C architecture, VxHub SDK integration, and Alamofire networking layer. Generate a new project in seconds.

## Quick Start

Run this command on any Mac to create a new project:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ersel95/boilerplate/main/create-project.sh)
```

The script will ask for:

| Input | Example | Description |
|-------|---------|-------------|
| **Project Name** | `SuperApp` | PascalCase, used for folder, Xcode target, App struct |
| **Bundle ID** | `com.company.superapp` | Reverse-domain notation |
| **VxHub ID** | *(optional)* | Leave empty to set later |
| **Target Directory** | `~/Desktop/Projects` | Where the project folder will be created |

The script automatically:
- Clones the template (or uses local copy if available)
- Renames all files, folders, and references
- Configures bundle ID, URL scheme, and product name
- Runs `xcodegen generate` to create the Xcode project
- Initializes a git repo with an initial commit
- Sets up `CLAUDE.md` for Claude Code compatibility

### Requirements

- **Xcode** 16.0+
- **XcodeGen** — `brew install xcodegen`
- **Git**

## Architecture

**MVVM-C** (Model-View-ViewModel-Coordinator)

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│    View      │────▶│  ViewModel   │────▶│   Service   │
│  (SwiftUI)   │◀────│ (BaseViewModel)│◀────│ (Protocol)  │
└─────────────┘     └──────┬───────┘     └─────────────┘
                           │
                    ┌──────▼───────┐
                    │  Coordinator  │
                    │ (Navigation)  │
                    └──────────────┘
```

### Navigation

All navigation goes through coordinators. ViewModels call `navigate(to:with:)` — never direct coordinator access.

| Type | Usage |
|------|-------|
| `.push` | NavigationStack push |
| `.sheet` | Modal sheet |
| `.bottomSheet(detents:)` | Customizable bottom sheet |
| `.fullScreenCover` | Full-screen modal |
| `.popup(position:)` | Custom overlay |
| `.sideMenu` | Side menu overlay |

## Project Structure

```
{ProjectName}/
├── Application/              # App entry point, AppDelegate
├── Core/
│   ├── BuildConfiguration/   # xcconfig files
│   ├── Coordinator/          # Navigation system
│   ├── Networking/           # Alamofire API layer
│   │   ├── Base/             # BaseService, APITargetType, NetworkError
│   │   └── Services/         # Feature-specific API services
│   ├── Security/             # KeychainManager
│   ├── Constants/            # Environment config, error messages
│   ├── Utils/                # BaseViewModel, SessionManager
│   ├── VxHub/                # VxHubManager bridge
│   ├── Extensions/           # Swift extensions
│   └── Helpers/              # ThreadHelper, LazyView
├── Modules/                  # Feature modules
│   ├── Splash/
│   ├── Auth/
│   ├── Home/
│   └── Example/              # API usage example (PostList)
├── SharedUI/
│   ├── Components/           # AppButton, AppTextField, Toast
│   ├── Theme/                # CoreColors, Typography, Fonts
│   └── Modifiers/            # SwiftUI view modifiers
└── Assets/                   # xcassets, fonts, images
```

## Adding a New Module

1. Create folder under `Modules/YourModule/`
2. Create `YourModuleScreens.swift` conforming to `CoordinatorEntryPoint`
3. Add case to `AppScreens` enum in `MainCoordinator.swift`
4. Create `YourView.swift` + `YourViewModel.swift` (extend `BaseViewModel`)

## Adding a New API Service

1. Create `YourAPI.swift` conforming to `APITargetType`
2. Create `YourService.swift` extending `BaseService<YourAPI>`
3. Create `YourServiceProtocol.swift` for testability
4. Create `YourMockService.swift` for development
5. Toggle real/mock via `EnvironmentsConstants.networkMode`

## VxHub SDK

VxHubManager bridges the [VxHub SDK](https://github.com/ersel95/VxHub-iOS) — no separate integration needed for:

- **RevenueCat** — In-app purchases, subscriptions, paywall UI
- **Amplitude** — Analytics, A/B testing
- **AppsFlyer** — Attribution
- **OneSignal** — Push notifications
- **Firebase** — Auth, analytics
- **Google/Apple Sign-In** — Social authentication
- **Facebook SDK** — Social auth + analytics
- **Sentry** — Crash reporting
- **SDWebImage** — Image loading/caching
- **Lottie** — Animations

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [Alamofire](https://github.com/Alamofire/Alamofire) | 5.10.2 | HTTP networking |
| [VxHub](https://github.com/ersel95/VxHub-iOS) | main | Monetization, analytics, engagement |

## License

MIT
