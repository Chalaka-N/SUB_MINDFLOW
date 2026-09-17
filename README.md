# MindFlow

MindFlow is a mindful tracking and wellness application built with Flutter. Designed with a "Hot-State" UX philosophy, it minimizes cognitive load for users experiencing high stress, providing immediate kinetic relief alongside long-term mood and journal tracking.

## Key Features

*   **Hot-State UX (SOS Quick Calm):** A dedicated kinetic-release interaction designed for high-stress moments, allowing users to rapidly decompress without navigating complex menus.
*   **Local Authentication:** Secure, frictionless first-time user onboarding and password protection to keep personal journal entries private.
*   **Activity History (CRUD):** Users can Create, Read, and Update their personal journal entries, dynamically reflecting their latest logged emotional state.
*   **Dynamic Theming:** Seamless Light and Dark mode toggling built on a custom `ValueNotifier` architecture for instant, app-wide UI updates.
*   **Time-Aware Greetings:** Dynamic dashboard greetings that adapt to the user's local device time.

## Technical Architecture

*   **Framework:** Flutter (Dart)
*   **State Management:** `StatefulWidget` for localized UI updates and `ValueNotifier` for global theme state propagation.
*   **Data Persistence:** `shared_preferences` for local on-device storage. This handles the lightweight local authentication system, saves user settings, and persists journal/mood data across app reboots.

## UI/UX Design

The visual identity relies on a calming, organic color palette to reduce visual fatigue:
*   **Deep Navy (`#0D1B3E`) & Teal (`#2CB5C0`)** for primary structuring and calmness.
*   **Coral (`#F16E73`)** strategically used for high-priority "Hot-State" actions (like the SOS button) and warnings.
*   **Leaf Green & Purple** for secondary mood categorizations.

## How to Run the Project

1. Ensure you have the Flutter SDK installed and configured on your machine.
2. Clone or download this repository.
3. Open a terminal in the project root directory and run:
   ```bash
   flutter pub get
