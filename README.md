# MindFlow

**MindFlow** is an AI-driven smart lifestyle companion designed to support emotional wellbeing through mood tracking, journaling, behavioural insights, and accessible AI-assisted guidance.

Built with **Flutter and Firebase**, MindFlow combines everyday wellbeing tracking with an AI conversational assistant and quick-calming activities. The application is designed around the idea that users may interact with the system in different emotional states, including moments of high stress where a simple and immediate interaction is more appropriate than navigating through complex menus.

---

## Key Features

### AI-Powered MindFlow Guide

The **MindFlow Guide** provides conversational wellbeing support using Google's Gemini AI through Firebase AI services.

Users can interact with the assistant to:

* Discuss everyday feelings and situations.
* Receive general wellbeing-oriented guidance.
* Reflect on their emotional state.
* Access supportive suggestions based on their interaction.

The AI assistant is designed as a supportive companion rather than a replacement for professional medical or psychological care.

### Mood Tracking

Users can record their current emotional state through the mood-tracking features.

MindFlow stores mood information to help users:

* Monitor their emotional patterns.
* Review previous mood entries.
* Identify changes over time.
* Build greater awareness of their wellbeing.

### Personal Journal

The application provides a personal journaling feature where users can record thoughts, experiences, and reflections.

Journal information is associated with the authenticated user's account and stored using Firebase services.

### Behaviour Analysis & Wellness Insights

MindFlow analyses recorded wellbeing data to provide simple behavioural insights.

The analysis service can calculate information such as:

* Mood counts and percentages.
* Emotional trends.
* Frequently occurring moods.
* Basic wellbeing observations.

These insights are presented to help users understand their recorded patterns rather than provide medical diagnoses.

### Stress Pop — Quick Calm Activity

**Stress Pop** is a lightweight interactive activity designed for moments of stress.

It follows the project's **"Hot-State UX"** concept: when a user is experiencing high stress, the application should provide an immediate and simple interaction instead of requiring the user to navigate through multiple screens.

### Wellness & Music Suggestions

MindFlow can provide music-oriented wellbeing suggestions as part of its supportive experience.

The application also includes logic intended to avoid inappropriate music recommendations when crisis-related language is detected.

### User Profile & Personalisation

Users can manage their profile information and application preferences through the profile section.

The application also supports personalised onboarding and a user-specific experience.

### Dynamic Light & Dark Themes

MindFlow supports both **Light Mode** and **Dark Mode**.

A `ValueNotifier`-based approach is used for theme state propagation, allowing theme changes to be reflected throughout the application.

### Time-Aware Dashboard

The dashboard provides greetings based on the user's local device time, creating a more personalised experience when returning to the application.

---

## Firebase Architecture

Firebase provides the main backend services used by MindFlow.

The project currently integrates:

* **Firebase Authentication** — user registration and authentication.
* **Cloud Firestore** — storage of user-related application data.
* **Firebase AI / Gemini** — AI-powered conversational assistance.
* **Firebase App Check** — additional protection for Firebase resources.
* **Firebase Core** — Firebase initialization and integration with the Flutter application.

User-specific information is associated with authenticated accounts rather than relying solely on local device storage.

---

## Artificial Intelligence

MindFlow incorporates generative AI through **Google's Gemini models using Firebase AI services**.

The AI component is integrated into the application's **MindFlow Guide**, allowing users to communicate with an AI-based wellbeing companion directly from the application.

AI is used to enhance the user experience by providing conversational responses and general supportive suggestions.

The application does **not** present the AI assistant as a medical professional or diagnostic system.

---

## Security & Privacy Considerations

MindFlow uses Firebase's authentication and security features to help protect user-specific information.

Security-related components include:

* Firebase Authentication for account management.
* User-specific Firestore data.
* Firebase App Check to help protect backend resources from unauthorised clients.
* Separation of application configuration from sensitive server-side credentials.
* Firebase security rules for controlling access to stored data.

The application is designed so that personal wellbeing information is associated with the relevant authenticated user.

> **Note:** MindFlow is a student-developed wellbeing application and should not be considered a substitute for professional medical, psychological, or emergency services.

---

## Technical Architecture

### Framework

* **Flutter**
* **Dart**

### Backend & Cloud Services

* **Firebase Core**
* **Firebase Authentication**
* **Cloud Firestore**
* **Firebase AI**
* **Firebase App Check**

### Application Architecture

The project separates major functionality into screens and service classes.

Examples include:

* `screens/` — user interface screens and application flows.
* `services/` — reusable application and data-related functionality.
* `firebase_options.dart` — Firebase configuration generated for the Flutter project.
* `main.dart` — application entry point and initialization.

Key application services include functionality for:

* Behaviour analysis.
* Analytics.
* Location-related features.
* AI interaction.
* Firebase-backed application functionality.

---

## UI/UX Design

MindFlow uses a calming visual identity intended to create a simple and approachable wellbeing experience.

### Primary Colours

* **Deep Navy — `#0D1B3E`**
* **Teal — `#2CB5C0`**
* **Coral — `#F16E73`**

Deep Navy and Teal form the primary visual foundation of the application, while Coral is used for important actions and high-priority interactions such as the quick-calm experience.

Additional colours are used for mood categorisation and supporting interface elements.

The application also provides **Light and Dark themes** to improve usability across different environments.

---

## Main Application Areas

The current application includes major areas such as:

* Authentication
* Onboarding
* Home Dashboard
* Mood Logger
* Mood Tracker
* Journal
* History
* AI Assistant / MindFlow Guide
* Stress Pop
* User Profile
* Profile Editing
* Main Navigation

These components work together to provide a single wellbeing-focused application rather than isolated tracking features.

---

## How to Run the Project

### Prerequisites

Make sure the following are installed and configured:

* Flutter SDK
* Dart SDK
* Android Studio or another supported Flutter development environment
* Android emulator or physical Android device
* A Firebase project configured for the application

### Installation

1. Clone the repository.

2. Open a terminal in the project root directory.

3. Install the Flutter dependencies:

```bash
flutter pub get
```

4. Verify the Flutter environment:

```bash
flutter doctor
```

5. Connect an Android device or start an Android emulator.

6. Run the application:

```bash
flutter run
```

### Firebase Configuration

The application requires the corresponding Firebase configuration for the project.

Firebase configuration files and project settings should be kept consistent with the application's configured Android package and Firebase project.

For a new development environment, Firebase services such as Authentication, Firestore, AI services, and App Check must be configured appropriately before all features can be used.

---

## Project Structure

```text
lib/
├── screens/
│   ├── ai_assistant_screen.dart
│   ├── ai_chat_screen.dart
│   ├── auth_screen.dart
│   ├── edit_profile_screen.dart
│   ├── history_screen.dart
│   ├── home_dashboard.dart
│   ├── journal_screen.dart
│   ├── main_navigation_screen.dart
│   ├── mood_logger_screen.dart
│   ├── mood_tracker_screen.dart
│   ├── onboarding_screen.dart
│   ├── profile_screen.dart
│   └── stress_pop_screen.dart
│
├── services/
│   ├── AI-related services
│   ├── Behaviour analysis
│   ├── Analytics
│   ├── Location-related functionality
│   └── Firebase-related functionality
│
├── firebase_options.dart
└── main.dart
```

---

## Future Enhancements

Potential future improvements include:

* More advanced long-term wellbeing trend analysis.
* Expanded personalised recommendations.
* Additional calming activities.
* Enhanced location-based wellbeing features such as walking suggestions.
* Further improvements to AI personalisation.
* Additional accessibility and usability enhancements.
* More comprehensive analytics and visual reporting.

---

## Project Context

**MindFlow** was developed as an MSc Information Technology project exploring the use of mobile application development, cloud services, behavioural data analysis, and generative AI to create a technology-assisted wellbeing experience.

The project demonstrates the integration of:

* Mobile application development with Flutter.
* Cloud backend services with Firebase.
* User authentication and data management.
* Generative AI through Gemini.
* Behavioural data analysis.
* Interactive UX design.
* Security considerations for cloud-based applications.

---

## Disclaimer

MindFlow is an academic/student-developed wellbeing application.

The application provides general wellbeing support and self-reflection features. It is **not a medical device, diagnostic system, or replacement for qualified professional healthcare or emergency assistance**.

Users experiencing a mental health emergency or immediate danger should contact the appropriate emergency or professional support services in their location.

---

## License

This project was developed for academic purposes as part of an MSc Information Technology programme.
