# Claude AI Instructions for Boulder League App

## Overview
You are working on the **Boulder League App**, a Flutter-based climbing league management application with Firebase backend.

## Critical: Always Read Main Context First

**Before responding to ANY user request**, you MUST read and familiarize yourself with the main context document:

📄 **[.claude/MAIN_CONTEXT.md](.claude/MAIN_CONTEXT.md)**

This document contains:
- Complete codebase architecture and folder structure
- All data models, types, and Firestore schemas
- All services (Auth, Boulder, Gym, Season, Scoring)
- UI component patterns and hierarchies
- Firebase integration and emulator setup
- Docker containerization details
- Development and deployment workflows
- Service flow diagrams

## Guidelines

### 1. **Maintain Consistency**
- Follow the established patterns documented in MAIN_CONTEXT.md
- Service methods: Return `Future<BaseReturnObject>` for CRUD, `Stream<List<T>>` for queries
- Components: Follow the Section → Filters → Form → Table pattern
- Forms: Support both create and edit modes with optional entity parameter

### 2. **Code Standards**
- Use Flutter's Material Design components
- Follow the existing naming conventions
- Include proper error handling (try-catch with FirebaseException)
- Add toast notifications for user feedback (success/error)
- Use StreamBuilder for real-time Firestore data
- Use FormBuilder for all forms with validation

### 3. **Firebase Integration**
- All Firestore operations go through service layer (never direct in UI)
- Check for duplicates before creating entities
- Include BaseMetaData in all main entities
- Use UUIDs for document IDs
- Use Firestore Timestamp for dates

### 4. **Development Workflow**
- Test with Firebase emulators before production
- Use Docker for consistent development environment
- Follow the Docker setup documented in MAIN_CONTEXT.md
- Run integration tests when modifying services

### 5. **When Adding New Features**
- Follow the established component patterns
- Create service methods before UI components
- Add appropriate Firestore indexes if needed
- Update security rules as necessary
- Document any new patterns or deviations

### 6. **Common Tasks**

**Adding a new model:**
1. Create model file in `lib/models/`
2. Include BaseMetaData
3. Add fromJson and toJson methods
4. Create filter object if needed

**Adding a new service:**
1. Create service file in `lib/services/`
2. Add CRUD methods returning BaseReturnObject
3. Add query method returning Stream<List<T>>
4. Include duplicate checking
5. Add proper error handling

**Adding a new feature section:**
1. Create section, filters, form, table components
2. Follow the pattern from boulders/scores/seasons/gyms
3. Use SectionWidget as the base container
4. Connect to appropriate service streams

## Quick Reference

### Service Layer Pattern
```dart
// CRUD operations
Future<BaseReturnObject> addEntity(Entity entity)
Future<BaseReturnObject> updateEntity(Entity entity)

// Query operations
Stream<List<Entity>> getEntities(EntityFilters? filters)
```

### Component Pattern
```
Section (Stateful)
├── Filters (Stateless - dropdowns)
├── Form (Stateful - create/edit dialog)
└── Table (Stateful - StreamBuilder)
```

### Firebase Collections
- `gyms` - Gym entities
- `seasons` - Season entities
- `boulders` - Boulder problems
- `scores` - User scored boulders

### Emulator Ports
- Firestore: localhost:8080
- Auth: localhost:9099
- UI: localhost:4000

### Docker Commands
```bash
# Start all services
docker-compose -f .docker/docker-compose.yml up --build

# Access points
# Web: http://localhost:8000
# Firebase UI: http://localhost:4000
```

## For AI Agents (Task Tool)

When launching specialized agents (Explore, general-purpose, etc.), ensure they:
1. **Read MAIN_CONTEXT.md first** to understand the codebase
2. Follow the established patterns and conventions
3. Reference the service layer architecture
4. Maintain consistency with existing code

## Remember
Always refer to [.claude/MAIN_CONTEXT.md](.claude/MAIN_CONTEXT.md) for detailed information before making any code changes or providing architectural guidance.

---

**This instructions file is automatically loaded at the start of every Claude Code conversation.**
