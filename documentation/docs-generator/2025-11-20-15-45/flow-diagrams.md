# Flow Diagrams

## Application State Flows

### App Initialization Flow

```mermaid
flowchart TD
    A[App Start] --> B[Initialize Flutter Binding]
    B --> C[Initialize Firebase]
    C --> D{Debug Mode?}

    D -->|Yes| E[Configure Emulators]
    E --> F[Connect Auth Emulator]
    F --> G[Connect Firestore Emulator]
    G --> H[Run App]

    D -->|No| H

    H --> I[Create Provider]
    I --> J[Create MaterialApp]
    J --> K[HomeController]
    K --> L{User Signed In?}

    L -->|Yes| M[HomeScreen]
    L -->|No| N[LoginScreen]
```

### Authentication State Flow

```mermaid
flowchart TD
    A[HomeController] --> B[Listen to onAuthStateChanged]
    B --> C{Stream Event}

    C -->|User Data| D[User Signed In]
    D --> E[Show HomeScreen]

    C -->|Null| F[User Signed Out]
    F --> G[Show LoginScreen]

    E --> H{User Action}
    H -->|Logout| I[Call AuthService.logout]
    I --> F

    G --> J{User Action}
    J -->|Login| K[Call AuthService.login]
    K --> L{Success?}
    L -->|Yes| D
    L -->|No| M[Show Error]
    M --> G

    J -->|Sign Up| N[Navigate to SignUpScreen]
    N --> O[Call AuthService.createAccount]
    O --> P{Success?}
    P -->|Yes| Q[Navigate to LoginScreen]
    P -->|No| R[Show Error]
    R --> N
```

## Navigation Flows

### Main Navigation Structure

```mermaid
flowchart TD
    A[HomeScreen] --> B[BottomNavigationBar]

    B --> C[Leaderboard Tab]
    B --> D[Score Tab]
    B --> E[Boulders Tab]
    B --> F[Seasons Tab]
    B --> G[Gyms Tab]

    C --> H[LeaderboardSection]
    D --> I[ScoresSection]
    E --> J[BouldersSection]
    F --> K[SeasonsSection]
    G --> L[GymsSection]

    A --> M[Drawer Menu]
    M --> N[User Info]
    M --> O[Logout]
    M --> P[Feedback Link]
    M --> Q[Bug Submission Link]
```

### Screen Navigation Flow

```mermaid
flowchart TD
    A[Initial Route '/'] --> B[HomeController]
    B --> C{Authenticated?}

    C -->|Yes| D[HomeScreen]
    C -->|No| E[LoginScreen]

    E --> F{User Action}
    F -->|Create Account| G[SignUpScreen]
    G --> H{Registration Success?}
    H -->|Yes| E
    H -->|No| G

    F -->|Login| I{Login Success?}
    I -->|Yes| D
    I -->|No| E

    D --> J{Drawer Action}
    J -->|Account| K[AccountScreen]
    J -->|Logout| E
```

## Business Logic Flows

### Score Calculation Flow

```mermaid
flowchart TD
    A[Score Input] --> B{Boulder Completed?}

    B -->|No| C[Score = 0]

    B -->|Yes| D[Base Score = 100]
    D --> E{Attempts = 1?}

    E -->|Yes| F[Flash Bonus +25]
    F --> G[Final Score = 125]

    E -->|No| H[Penalty = attempts * 0.1]
    H --> I[Final Score = 100 - Penalty]

    C --> J[Return Score]
    G --> J
    I --> J
```

### Leaderboard Aggregation Flow

```mermaid
flowchart TD
    A[Get Filtered Scores] --> B[Stream of ScoredBoulder list]
    B --> C[Group by User ID]
    C --> D[For Each User]
    D --> E[Sum Total Score]
    E --> F[Create LeaderboardEntry]
    F --> G[Collect All Entries]
    G --> H[Sort by Total Score DESC]
    H --> I[Display Ranked List]
```

### Data Filtering Flow

```mermaid
flowchart TD
    A[User Sets Filters] --> B[Build Query]

    B --> C{Gym Selected?}
    C -->|Yes| D[Add gymId filter]
    C -->|No| E[Skip]

    D --> F{Season Selected?}
    E --> F

    F -->|Yes| G[Add seasonId filter]
    F -->|No| H[Skip]

    G --> I{Week Selected?}
    H --> I

    I -->|Yes| J[Add week filter]
    I -->|No| K[Skip]

    J --> L[Execute Query]
    K --> L

    L --> M[Return Stream]
```

## Error Handling Flows

### Service Error Handling Flow

```mermaid
flowchart TD
    A[Service Method Call] --> B[Try Operation]

    B --> C{Success?}
    C -->|Yes| D[Return BaseReturnObject]
    D --> E[success: true]
    E --> F[message: Success message]

    C -->|No| G{Error Type}

    G -->|FirebaseAuthException| H[Extract error message]
    G -->|Other Exception| I[Use generic message]

    H --> J[Return BaseReturnObject]
    I --> J
    J --> K[success: false]
    K --> L[message: Error details]

    F --> M[UI Handles Response]
    L --> M

    M --> N{Success?}
    N -->|Yes| O[Show Success Toast]
    N -->|No| P[Show Error Toast]
```

### Duplicate Check Flow

```mermaid
flowchart TD
    A[Add/Update Entity] --> B[Query for Duplicates]
    B --> C[Get Matching Documents]

    C --> D{Add or Update?}

    D -->|Add| E{Any Matches?}
    E -->|Yes| F[Return Error: Duplicate exists]
    E -->|No| G[Proceed with Add]

    D -->|Update| H{Match with Different ID?}
    H -->|Yes| F
    H -->|No| I[Proceed with Update]

    G --> J[Save to Firestore]
    I --> J
    J --> K[Return Success]
```

## Data Synchronization Flow

### Real-time Updates Flow

```mermaid
flowchart TD
    A[Component Mounted] --> B[Subscribe to Stream]
    B --> C[Firestore Listener Active]

    C --> D{Data Change Event}
    D -->|Added| E[Process New Doc]
    D -->|Modified| F[Process Updated Doc]
    D -->|Removed| G[Process Deleted Doc]

    E --> H[Update UI State]
    F --> H
    G --> H

    H --> I[Rebuild Widget]
    I --> J[Display Updated Data]

    J --> C

    K[Component Disposed] --> L[Cancel Subscription]
```

---
*Generated by docs-generator agent on 2025-11-20 15:45*
