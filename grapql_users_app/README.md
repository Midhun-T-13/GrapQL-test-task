# GraphQL Users App

A production-quality Flutter application demonstrating Clean Architecture principles with GraphQL API integration, Cubit state management, and modern UI patterns.


## Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/
│   ├── error/              # Failures and Exceptions
│   ├── network/            # GraphQL Client Configuration
│   └── usecase/            # Base UseCase class
├── features/
│   └── users/
│       ├── data/
│       │   ├── datasources/    # Remote data sources
│       │   ├── models/         # Data models with JSON serialization
│       │   └── repositories/   # Repository implementations
│       ├── domain/
│       │   ├── entities/       # Business entities
│       │   ├── repositories/   # Repository interfaces
│       │   └── usecases/       # Business logic
│       └── presentation/
│           ├── cubit/          # State management (Cubit)
│           ├── pages/          # UI screens
│           └── widgets/        # Reusable widgets
└── injection_container.dart    # Dependency Injection setup
```

### Layer Responsibilities

**Domain Layer** (Business Logic)
- Entities: Pure Dart objects representing business models
- Repositories: Abstract interfaces defining data operations
- Use Cases: Single-responsibility business logic units

**Data Layer** (Data Management)
- Models: Data transfer objects with JSON serialization
- Data Sources: GraphQL API integration
- Repository Implementations: Concrete implementations of domain repositories

**Presentation Layer** (UI)
- Pages: Screen-level widgets
- Cubits: State management with BLoC pattern
- Widgets: Reusable UI components

##  Libraries Used

### State Management
- **flutter_bloc** (^9.1.1)
  - State management using Cubit pattern
  - Predictable state transitions with BlocBuilder
  - Cleaner alternative to traditional Bloc with less boilerplate
  - Easy to test and maintain

### GraphQL & Networking
- **graphql_flutter** (^5.1.2)
  - Declarative GraphQL queries and mutations
  - Built-in caching and error handling
  - Type-safe GraphQL operations
  - Automatic network request management

### Dependency Injection
- **get_it** (^7.6.4)
  - Service locator pattern for dependency injection
  - Singleton and factory registrations
  - Clean separation of concerns
  - Easy to mock dependencies for testing

### Navigation
- **go_router** (^14.6.2)
  - Declarative routing with type-safe navigation
  - Deep linking support
  - Route parameter passing
  - Better than MaterialPageRoute for complex navigation

### UI & Responsiveness
- **flutter_screenutil** (^5.9.3)
  - Responsive UI that adapts to different screen sizes
  - Proportional font sizes, padding, and dimensions
  - `.w`, `.h`, `.sp`, `.r` extensions for adaptive sizing
  - Consistent UI across devices

### Utilities
- **equatable** (^2.0.5)
  - Value equality for Dart objects
  - Cleaner state comparisons in Cubits
  - Reduces boilerplate for `==` operator and `hashCode`



## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed on your machine:

- **Flutter SDK** (3.9.2 or higher)
- **Dart SDK** (^3.9.2) - comes with Flutter
- **Git** - for cloning the repository
- **Android Studio** / **VS Code** - recommended IDEs
- **Android Emulator** or **iOS Simulator** (or physical device)

### Step-by-Step Setup

#### 1. Clone the Repository

# Clone the repository
git clone <your-repository-url>

# Navigate to project directory
cd grapql_users_app


#### 2. Verify Flutter Installation

# Check Flutter installation and dependencies
flutter doctor

# This will show any missing dependencies or issues

#### 3. Install Dependencies

# Get all Flutter packages
flutter pub get

This will install all dependencies listed in `pubspec.yaml` including:
- flutter_bloc
- graphql_flutter
- go_router
- flutter_screenutil
- get_it
- equatable

#### 4. (Optional) Generate Mock Files for Testing

If you want to run tests or modify test files:

# Generate mock files
flutter pub run build_runner build --delete-conflicting-outputs

#### 5. Run the Application

**Option A: Using Command Line**

# Run on connected device/emulator
flutter run

# Run in debug mode (default)
flutter run --debug

# Run in release mode (optimized)
flutter run --release

# Run on specific device
flutter devices  # List all connected devices
flutter run -d <device-id>

**Option B: Using IDE**

- **Android Studio**: Press `Run` (▶) or `Shift + F10`
- **VS Code**: Press `F5` or use Run menu

#### 6. Build for Production

**Android APK:**
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk


**Android App Bundle:**
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab


**iOS:**
flutter build ios --release
# Requires macOS and Xcode


## API

This app uses the public GraphQL API:
- **Endpoint**: https://graphqlzero.almansi.me/api
- **Documentation**: [GraphQLZero](https://graphqlzero.almansi.me/)

### GraphQL Operations

**Query - Get Users (Paginated)**
```graphql
query GetUsers($page: Int!, $limit: Int!) {
  users(options: { paginate: { page: $page, limit: $limit } }) {
    data {
      id
      name
      username
      email
      phone
      website
      company {
        name
      }
    }
    meta {
      totalCount
    }
  }
}
```

**Query - Get User by ID**
```graphql
query GetUser($id: ID!) {
  user(id: $id) {
    id
    name
    username
    email
    phone
    website
    address {
      street
      suite
      city
      zipcode
    }
    company {
      name
    }
  }
}
```

**Mutation - Create User**
```graphql
mutation CreateUser($name: String!, $username: String!, $email: String!) {
  createUser(input: { name: $name, username: $username, email: $email }) {
    id
    name
    username
    email
  }
}
```


## App Screenshots and Screen recording

Screenshots and recording are added in the repository




