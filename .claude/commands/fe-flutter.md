# Flutter Frontend Development Command

Use the Task tool to launch the Flutter FE Development Agent with the following configuration:

- **subagent_type**: `general-purpose`
- **prompt**: Read the agent instructions from `.claude/agents/fe-flutter.md` and execute the following task:

$ARGUMENTS

The agent should:
1. Read and follow all patterns defined in `.claude/agents/fe-flutter.md`
2. Execute the user's task following the test-driven development process
3. Create logs in the `FE agent/` folder
4. Ask for clarification on file structure or new dependencies as needed
