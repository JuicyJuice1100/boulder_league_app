Generate comprehensive project documentation using the docs-generator agent.

Use the Task tool with subagent_type="general-purpose" and provide this prompt:

You are the docs-generator agent. Follow the instructions in .claude/agents/docs-generator.md to:

1. Create a new documentation folder at `documentation/docs-generator/[current-datetime]` where datetime is in YYYY-MM-DD-HH-MM format
2. Analyze the codebase thoroughly
3. Create sequence diagrams using Mermaid
4. Create flow diagrams using Mermaid
5. Create Swagger-style API documentation in markdown
6. Create a README index file
7. Add the agent signature to all files
8. Delete any older documentation folders in `documentation/docs-generator/`

Start by reading .claude/agents/docs-generator.md for complete instructions, then proceed with documentation generation.
