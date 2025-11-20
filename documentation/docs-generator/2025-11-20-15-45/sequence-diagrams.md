# Sequence Diagrams

## Authentication Flows

### User Login Flow

```mermaid
sequenceDiagram
    participant User
    participant LoginScreen
    participant AuthService
    participant FirebaseAuth
    participant HomeController

    User->>LoginScreen: Enter email/password
    LoginScreen->>AuthService: login(email, password)
    AuthService->>FirebaseAuth: signInWithEmailAndPassword()

    alt Success
        FirebaseAuth-->>AuthService: User credential
        AuthService-->>LoginScreen: BaseReturnObject(success: true)
        FirebaseAuth->>HomeController: onAuthStateChanged stream update
        HomeController->>User: Navigate to HomeScreen
    else Failure
        FirebaseAuth-->>AuthService: FirebaseAuthException
        AuthService-->>LoginScreen: BaseReturnObject(success: false, message)
        LoginScreen->>User: Show error toast
    end
```

### User Registration Flow

```mermaid
sequenceDiagram
    participant User
    participant SignUpScreen
    participant AuthService
    participant FirebaseAuth

    User->>SignUpScreen: Enter username/email/password
    SignUpScreen->>AuthService: createAccount(username, email, password)
    AuthService->>FirebaseAuth: createUserWithEmailAndPassword()

    alt Success
        FirebaseAuth-->>AuthService: User credential
        AuthService->>FirebaseAuth: updateDisplayName(username)
        AuthService->>FirebaseAuth: sendEmailVerification()
        AuthService-->>SignUpScreen: BaseReturnObject(success: true)
        SignUpScreen->>User: Navigate to LoginScreen
    else Failure
        FirebaseAuth-->>AuthService: FirebaseAuthException
        AuthService-->>SignUpScreen: BaseReturnObject(success: false, message)
        SignUpScreen->>User: Show error toast
    end
```

### User Logout Flow

```mermaid
sequenceDiagram
    participant User
    participant HomeScreen
    participant AuthService
    participant FirebaseAuth
    participant HomeController

    User->>HomeScreen: Tap Logout
    HomeScreen->>AuthService: logout()
    AuthService->>FirebaseAuth: signOut()
    FirebaseAuth->>HomeController: onAuthStateChanged (null)
    HomeController->>User: Navigate to LoginScreen
```

## Data Management Flows

### Add Boulder Flow

```mermaid
sequenceDiagram
    participant User
    participant BouldersSection
    participant BoulderForm
    participant BoulderService
    participant Firestore

    User->>BouldersSection: Tap Add Boulder
    BouldersSection->>BoulderForm: Open form dialog
    User->>BoulderForm: Fill name, gym, season, week
    BoulderForm->>BoulderService: addBoulder(boulder)

    BoulderService->>Firestore: Query for duplicates
    Firestore-->>BoulderService: Existing docs

    alt No Duplicate
        BoulderService->>Firestore: add(boulder)
        Firestore-->>BoulderService: Success
        BoulderService-->>BoulderForm: BaseReturnObject(success: true)
        BoulderForm->>User: Close dialog, show success toast
    else Duplicate Exists
        BoulderService-->>BoulderForm: BaseReturnObject(success: false)
        BoulderForm->>User: Show error toast
    end
```

### Record Score Flow

```mermaid
sequenceDiagram
    participant User
    participant ScoresSection
    participant ScoreForm
    participant ScoringService
    participant ScoreCalculator
    participant Firestore

    User->>ScoresSection: Tap Add Score
    ScoresSection->>ScoreForm: Open form dialog
    User->>ScoreForm: Select boulder, enter attempts, completed
    ScoreForm->>ScoreCalculator: calculateScore(attempts, completed)
    ScoreCalculator-->>ScoreForm: Calculated score

    ScoreForm->>ScoringService: addScore(scoredBoulder)
    ScoringService->>Firestore: Query for existing score

    alt New Score
        ScoringService->>Firestore: add(scoredBoulder)
        Firestore-->>ScoringService: Success
        ScoringService-->>ScoreForm: BaseReturnObject(success: true)
        ScoreForm->>User: Close dialog, show success toast
    else Score Exists
        ScoringService-->>ScoreForm: BaseReturnObject(success: false)
        ScoreForm->>User: Show error toast
    end
```

### Load Leaderboard Flow

```mermaid
sequenceDiagram
    participant User
    participant LeaderboardSection
    participant ScoringService
    participant Firestore

    User->>LeaderboardSection: View Leaderboard tab
    LeaderboardSection->>ScoringService: getScores(filters)
    ScoringService->>Firestore: Query with filters
    Firestore-->>ScoringService: Stream<List<ScoredBoulder>>
    ScoringService-->>LeaderboardSection: Score data

    LeaderboardSection->>LeaderboardSection: Aggregate by user
    LeaderboardSection->>LeaderboardSection: Calculate totals
    LeaderboardSection->>LeaderboardSection: Sort by score
    LeaderboardSection->>User: Display ranked leaderboard
```

### Create Season Flow

```mermaid
sequenceDiagram
    participant User
    participant SeasonsSection
    participant SeasonForm
    participant SeasonService
    participant Firestore

    User->>SeasonsSection: Tap Add Season
    SeasonsSection->>SeasonForm: Open form dialog
    User->>SeasonForm: Enter name, gym, start/end dates
    SeasonForm->>SeasonService: addSeason(season)

    SeasonService->>Firestore: Query for duplicate name in gym
    Firestore-->>SeasonService: Results

    alt No Duplicate
        SeasonService->>Firestore: add(season)
        Firestore-->>SeasonService: Success
        SeasonService-->>SeasonForm: BaseReturnObject(success: true)
        SeasonForm->>User: Close dialog, show success toast
    else Duplicate Name
        SeasonService-->>SeasonForm: BaseReturnObject(success: false)
        SeasonForm->>User: Show error toast
    end
```

### Create Gym Flow

```mermaid
sequenceDiagram
    participant User
    participant GymsSection
    participant GymForm
    participant GymService
    participant Firestore

    User->>GymsSection: Tap Add Gym
    GymsSection->>GymForm: Open form dialog
    User->>GymForm: Enter gym name
    GymForm->>GymService: addGym(gym)

    GymService->>Firestore: Query for duplicate name
    Firestore-->>GymService: Results

    alt No Duplicate
        GymService->>Firestore: add(gym)
        Firestore-->>GymService: Success
        GymService-->>GymForm: BaseReturnObject(success: true)
        GymForm->>User: Close dialog, show success toast
    else Duplicate Name
        GymService-->>GymForm: BaseReturnObject(success: false)
        GymForm->>User: Show error toast
    end
```

## Real-time Data Sync

### Stream-based Data Updates

```mermaid
sequenceDiagram
    participant Firestore
    participant Service
    participant StreamBuilder
    participant UIComponent
    participant User

    Service->>Firestore: collection.snapshots()
    Firestore-->>Service: Stream<QuerySnapshot>

    loop On Data Change
        Firestore->>Service: New snapshot
        Service->>StreamBuilder: Updated list
        StreamBuilder->>UIComponent: Rebuild widget
        UIComponent->>User: Display updated data
    end
```

---
*Generated by docs-generator agent on 2025-11-20 15:45*
