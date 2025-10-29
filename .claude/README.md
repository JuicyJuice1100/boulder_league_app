# Claude Configuration Guide

This directory contains configuration files for Claude Code AI assistance.

## Files Overview

### 📋 [instructions.md](instructions.md)
**Auto-loaded at the start of every conversation**

This file tells Claude:
- To always read MAIN_CONTEXT.md first
- Project-specific guidelines and patterns
- Code standards and conventions
- Quick reference for common tasks

### 📚 [MAIN_CONTEXT.md](MAIN_CONTEXT.md)
**Comprehensive codebase documentation**

Contains complete documentation of:
- Project architecture and tech stack
- All models, services, and components
- Firebase integration details
- Docker setup and deployment
- Service flow diagrams
- Development workflows

### ⚙️ [settings.local.json](settings.local.json)
**Project-specific settings**

Includes:
- Bash command permissions
- Pre-tool-use hooks
- Custom validations

## How It Works

### For Every Conversation

```
User starts conversation
         ↓
Claude reads instructions.md automatically
         ↓
Instructions tell Claude to read MAIN_CONTEXT.md
         ↓
Claude has full project context
         ↓
Claude responds with project-aware guidance
```

### For AI Agents (Task Tool)

When you launch agents, they also have access to these files:

```bash
# Example agent launch
"Please explore the scoring service"
         ↓
Agent reads instructions.md
         ↓
Agent reads MAIN_CONTEXT.md
         ↓
Agent explores with full context
         ↓
Agent provides informed analysis
```

## Testing the Setup

### Test 1: Ask a General Question
```
"How does the scoring system work?"
```
Claude should reference MAIN_CONTEXT.md and explain the ScoreCalculator.

### Test 2: Request a Code Change
```
"Add a new field to the Boulder model"
```
Claude should:
- Reference the existing Boulder model structure
- Follow the BaseMetaData pattern
- Update fromJson/toJson methods
- Suggest Firestore index updates

### Test 3: Launch an Agent
```
"Use the Explore agent to find all services"
```
The agent should understand the lib/services/ structure from MAIN_CONTEXT.md.

## Updating the Context

When you make significant changes to the codebase:

1. **Update MAIN_CONTEXT.md** with new patterns or architecture changes
2. **Update instructions.md** if you want to change Claude's behavior or add new guidelines
3. **No restart needed** - Changes take effect in the next conversation

## Best Practices

### ✅ Do's
- Keep MAIN_CONTEXT.md up-to-date with architectural changes
- Add new patterns and conventions to instructions.md
- Use specific examples in instructions.md
- Reference both files when asking complex questions

### ❌ Don'ts
- Don't duplicate information between files (instructions should reference MAIN_CONTEXT)
- Don't put temporary information in these files
- Don't forget to update after major refactors

## File Roles Summary

| File | Purpose | When Loaded | Update Frequency |
|------|---------|-------------|------------------|
| `instructions.md` | Behavior guidelines | Every conversation start | When patterns change |
| `MAIN_CONTEXT.md` | Technical documentation | Referenced by instructions | After architectural changes |
| `settings.local.json` | Tool permissions & hooks | Every conversation start | Rarely |

## Example Workflow

### Adding a New Feature

1. **You:** "I want to add a comments feature for boulders"

2. **Claude:**
   - Reads instructions.md (automatically)
   - Reads MAIN_CONTEXT.md (as instructed)
   - Understands existing patterns (Section → Filters → Form → Table)
   - Understands service layer (CRUD + Stream patterns)
   - Proposes solution following established conventions

3. **You:** Approve and implement

4. **After implementation:**
   - Update MAIN_CONTEXT.md with new Comment model and CommentService
   - Instructions.md automatically tells future Claude instances to read the updated context

## Getting Help

If Claude isn't following the instructions:
1. Check that `.claude/instructions.md` exists
2. Start a new conversation (instructions load at start)
3. Explicitly ask: "Have you read the MAIN_CONTEXT.md file?"
4. Verify the instructions are formatted correctly (valid Markdown)

## Pro Tips

### Tip 1: Explicit Reminders
If Claude seems to forget the context, remind it:
```
"Please reference the MAIN_CONTEXT.md for the service layer pattern"
```

### Tip 2: Agent Prompts
When launching agents, include a reminder:
```
"Use the Explore agent to [task]. Make sure to reference MAIN_CONTEXT.md for the folder structure."
```

### Tip 3: Version Context
Add version numbers to MAIN_CONTEXT.md to track major updates.

---

**Setup Complete!** 🎉

Your Claude AI agents are now configured to always use your project context.
