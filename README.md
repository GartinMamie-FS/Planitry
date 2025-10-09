# 🍏 Planitry: Personalized Meal Planner (iOS)

## Project Overview

**Planitry** is a native iOS application built using SwiftUI designed to simplify meal planning by providing quick, personalized meal suggestions based on the user's specific dietary needs, health goals, and calorie restrictions.

The core value proposition of Planitry is to deliver an immediate, relevant, single meal generation result by integrating with the **live Edamam API**.

## 🛠 Technology Stack

| Component | Technology | Rationale |
| :--- | :--- | :--- |
| **Platform** | **Native iOS** | Ensures high performance, smooth UI, and utilizes native iOS features. |
| **Framework** | **SwiftUI** | Modern, declarative framework for fast and responsive UI development. |
| **Data Persistence** | **UserDefaults** (`@AppStorage`) | Reliable, local storage for user preferences (Dietary, Health, Calories). |
| **Networking** | **URLSession** | Used for secure and asynchronous communication with the live Edamam API. |
| **Architecture** | **MVVM (Model-View-ViewModel)** | To maintain clean, scalable code and separation of business logic from the UI. |

## 🗺 Feature Contract & Scope

The project is executed in two main phases: **Alpha MVP** (Weeks 1-4) and **Beta Development** (Weeks 5+), based on the following feature tiers.

### 🥇 Primary Features: Alpha MVP Contract (Goal: Week 4 Turn-in)

These features must be fully functional using the **live Edamam API** for the Alpha demonstration.

| Feature | Description | Kanban Reference |
| :--- | :--- | :--- |
| **Preferences Persistence** | Ability to save and load **Dietary, Health, and Calorie** constraints using `@AppStorage`. | A2, A3 |
| **Live API Integration** | Successful use of **`URLSession`** to call the Edamam API, pass saved preferences, and decode the JSON response into Swift models. | A4, A5, A6 |
| **Single Meal Generation** | User taps "Generate" and receives a single, personalized meal result based on current constraints. | A7 |
| **End-to-End (E2E) Flow** | The complete user path: **Preferences set → API called with parameters → Real data displayed on Results View.** | A8 |

### 🥈 Secondary Features: Beta Development (Month 2 Focus)

These features expand the core utility from a "quick generator" to a full planning tool.

1. **Weekly Planning View:** Scale the API calls to generate a full 7-day, 3-meal plan (21 total meals).

2. **Inventory Management:** Dedicated screen and logic for users to input and manage ingredients they already have on hand.

3. **Grocery List Calculation:** Logic to compare the Weekly Plan ingredients against the user's Inventory to generate a list of *missing* items.

### 🥉 Tertiary Features: Polish & Future Scope

1. **Sequential Onboarding Flow:** A multi-screen initial setup sequence for first-time users.

2. **Haptic Feedback Integration:** Add subtle system haptics for key interactions (e.g., successful save).

## 🗓 Development Timeline & Weekly Progress

This timeline tracks the project across the core 6-week window, mapping progress directly to the Kanban tasks.

### Week 1: Planning and Design (Completed)

* **Focus:** Project Definition and Visual Contract.

* **Key Accomplishments:** Created the Project Proposal, finalized the Feature Map (Primary/Secondary/Tertiary), established the Kanban Board structure, and completed the **Figma prototype** (visual contract) for all Alpha screens.

* **Status:** Transitioning to Coding Phase.

### Week 2: Foundation and Persistence (Current Focus)

* **Focus:** Environment Setup and Data Input.

* **Tasks:** **A1** (Xcode Project Setup), **A2** (Data Persistence via `@AppStorage`), and **A3** (Single Preferences View UI).

* **Goal:** Have a fully working SwiftUI application shell where a user can save and load preferences.

### Week 3: Live API and Core Logic

* **Focus:** Implementing the core intelligence using external data.

* **Tasks:** **A4** (API Models/Key Setup), **A5** (Live `URLSession` Call), **A6** (JSON Decoding/Error Handling), **A7** (Quick Generator View).

* **Goal:** Successfully execute a live API call based on user input and retrieve the real meal data.

### Week 4: Alpha MVP Turn-in & E2E Validation

* **Focus:** Final assembly, testing, and demonstration preparation.

* **Tasks:** **A8** (Results View and Final E2E Test).

* **Goal:** Successfully demonstrate the complete, functional **Alpha MVP** (Preferences set → Live API call → Real results displayed).

### Weeks 5-8: Beta Phase 1 (Expanding Scope)

* **Focus:** Implementation of Secondary Features.

* **Tasks:** Begin implementation of **Weekly Planning View** and **Inventory Management** (S1, S2).

* **Goal:** Have the app generate a full 7-day meal plan.

## 🚀 Setup and Installation

### Requirements

* Xcode 15+

* Swift 5.9+

* A valid **Edamam API Key and App ID** (required for the live functionality starting Week 3).

### Local Setup

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/GartinMamie-FS/Planitry.git
   cd Planitry
   
2. **API Key Configuration (Required for Week 3+):**

For security, do not hardcode the keys. Configure an environment or property list file within the Xcode project to store your Edamam credentials.

3. **Run:** Open Planitry.xcodeproj and run on a simulator or physical device.

🤝 **Contribution and Contact**
This is an individual project submission.

Developer: 

Mamie Gartin
