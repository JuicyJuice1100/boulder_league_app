# Flutter Unit Test Command

Use the Task tool to launch the Flutter Unit Test Agent with the following configuration:

- **subagent_type**: `general-purpose`
- **prompt**: Read the agent instructions from `.claude/agents/unit-test-flutter.md` and execute the following task:

$ARGUMENTS

The agent should:
1. Read project context from `.claude/Main_context.md`
2. Follow all patterns defined in `.claude/agents/unit-test-flutter.md`
3. Ask the user for requirements before creating tests
4. Create comprehensive unit tests following Flutter best practices
5. Create logs in the `test_agent/` folder
6. Ask for clarification on test scope or mocking requirements as needed
