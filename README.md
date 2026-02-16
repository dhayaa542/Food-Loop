# FoodLoop — Walkthrough

**GitHub Repository:** [Food-Loop](https://github.com/dhayaa542/Food-Loop)

## What Was Built

Complete UI redesign of the existing Flutter "FreshCatch" app into **FoodLoop**, a sustainable food-sharing platform with 3 role-based interfaces and 15+ polished screens.

## Project Structure

```
lib/
├── main.dart                          # Entry point → SplashScreen
├── theme/
├── widgets/
└── screens/
    ├── splash_screen.dart             # Animated splash with gradient + logo
    ├── login_screen.dart              # Login with role selector
    ├── register_screen.dart           # Register with Buyer/Partner cards
    ├── buyer/
    ├── partner/
        ├── partner_shell.dart         # Dashboard + Custom Drawer
        ├── manage_offers_screen.dart  # Create/Edit offers
        ├── orders_screen.dart         # Order management tabs
        ├── profile_screen.dart        # Edit profile + parallax header
        └── settings_screen.dart       # Dark mode toggle
    └── admin/
        ├── admin_shell.dart           # 5-tab bottom nav
        ├── admin_dashboard.dart       # Metric cards + pie chart + activity feed
        ├── user_management_screen.dart     # User list with suspend
        ├── partner_approval_screen.dart    # Approve/reject partners
        ├── offer_monitoring_screen.dart    # Offers with deactivate
        └── analytics_screen.dart      # Pie chart + progress bars
```

## Design System

| Token | Value |
|-------|-------|
| Primary | `#2E7D32` (green) |
| Background | `#F9FBF9` (off-white) |
| Card radius | 16px |
| Font | Poppins (via google_fonts) |
| Shadows | Soft 12px blur |
| Material | Material 3 enabled |

## Verification

| Check | Result |
|-------|--------|
| `flutter pub get` | ✅ Resolved dependencies |
| `flutter analyze` | ✅ 11 remaining info-level warnings only |
| `flutter run -d chrome` | ✅ Compiled and launched successfully |

## Deleted Files
- `lib/login.dart` (old FreshCatch)
- `lib/sign_in.dart` (old FreshCatch)
- `lib/home.dart` (old FreshCatch)
