# oclaudefsd

Claude Code Full Stack Development (FSD) - Your AI-powered development team in a box using Claude Code with ultrathink. This is "Only"claudefsd and uses Docker. Each project will create it's own claude dockcer container to work in isolation.

## What is this?

Remember when junior developers were going to be replaced by AI? Well, the tables have turned. As explained in the excellent article ["Revenge of the Junior Developer"](https://sourcegraph.com/blog/revenge-of-the-junior-developer), AI has actually made junior developers more powerful than ever.

This tool takes that concept to the next level by creating an entire **agent fleet** - multiple AI agents working together like a development team:

- 🧑‍💻 **Developer Agent**: Writes code, implements features, fixes bugs
- 📋 **Planner Agent**: Breaks down tasks, manages the development roadmap
- 👀 **Reviewer Agent**: Reviews code quality, catches issues, ensures best practices
- 🧪 **Tester Agent**: Runs tests, validates changes, commits clean code

Think of it as having a full development team that never sleeps, never gets tired, and always follows best practices. The AI agents work in cycles, planning tasks, implementing them, reviewing the work, and then moving on to the next task.

## Installation

```bash
# From GitHub:
npm install -g https://github.com/mkamrans/oclaude-fsd.git
# npm Server:
npm install oclaudefsd
```

## Quick Start

Just run:
```bash
oclaudefsd
```

On first run, you'll be guided through a setup wizard to configure how Claude is installed on your system. After that, you'll get an interactive menu to choose what you want to do. It's that simple!

## Commands

### Main wrapper command
```bash
oclaudefsd         # Interactive mode (recommended for beginners)
oclaudefsd dev     # Jump straight into development mode
oclaudefsd plan    # Jump straight into planning mode
oclaudefsd plan-gen # Generate a new project plan
```

### Individual commands (if you know what you're doing)

#### oclaudefsd-dev
Runs the development agent fleet. This command:
- Reads your project plan from `docs/PLAN.md`
- Picks the next open task
- Assigns it to the developer agent
- Has the code reviewed by the reviewer agent
- Tests and commits the changes if everything looks good
- Repeats until all tasks are done

Every 4th cycle, it activates "megathinking mode" for architectural planning. Code review uses ultrathink for thorough analysis.

#### oclaudefsd-plan
Interactive planning session where you work with AI to:
- Define project requirements
- Break down complex features into tasks
- Prioritize and organize work
- Update the project roadmap

#### oclaudefsd-plan-gen
Generates an initial project plan from scratch using Claude Code's ultrathink for comprehensive analysis based on:
- Your project requirements (`docs/REQUIREMENTS.md`)
- Any existing code or documentation
- Best practices for your tech stack

## How it Works

1. **You define what you want** in `docs/REQUIREMENTS.md`
2. **AI creates a plan** breaking it down into manageable tasks
3. **The agent fleet executes** the plan task by task
4. **You review and guide** the process when needed

The agents work in a continuous loop:
```
Plan → Develop → Review → Test → Commit → Repeat
```

## Requirements

### Required
- Node.js >= 14.0.0
- Unix-like environment (macOS, Linux)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (`claude` command)

All AI processing is handled by Claude Code with built-in ultrathink capabilities for advanced reasoning tasks.

### Security Recommendation

⚠️ **We strongly recommend using a containerized version of Claude** for security and isolation. Since oclaudefsd grants Claude extensive permissions to read, write, and execute code in your project, containerization provides an important security boundary.

See the [Claude Code Security Guide](https://docs.anthropic.com/en/docs/claude-code/security) for detailed information about:
- Setting up Claude in Docker
- Understanding permission models
- Best practices for secure usage

### Configuring Claude Command

On first run, oclaudefsd will guide you through setting up your Claude installation. It supports:
- Standard Claude installations (`claude` command)
- Docker-based Claude installations
- Custom commands

To reconfigure your settings later:
```bash
oclaudefsd config setup
```

To see your current configuration:
```bash
oclaudefsd config show
```

You can also override the configuration temporarily:
```bash
# Use a different Claude command for this run
oclaudefsd --claude-cmd=claude-docker dev

# Or set it via environment variable
export CLAUDE_CMD=claude-docker
oclaudefsd dev
```

#### Important: Docker Container Setup

If using Claude in a Docker container, you must first accept the permissions interactively:

```bash
# For Docker containers, use -it (interactive + tty)
docker exec -it your-container-name claude --dangerously-skip-permissions
```

**Note the `-it` flags are required** for the interactive permission acceptance. Without these flags, you'll get an error about "Raw mode is not supported".

After accepting permissions once, oclaudefsd will use the container automatically with the correct flags for non-interactive operation.

## Project Structure

Your project should have:
```
your-project/
├── docs/
│   ├── PLAN.md          # The development plan (tasks to do)
│   ├── REQUIREMENTS.md  # What you want built
│   ├── QUESTIONS.md     # Questions for clarification
│   └── IDEAS.md         # Future ideas and improvements
├── .oclaude/            # Working directory (auto-created)
│   ├── logs/           # Logs from each AI session
│   ├── tmp/            # Temporary files
│   └── cache/          # Cache files
└── BRIEF.md            # Project overview (optional)
```

### The .oclaude Directory

oclaudefsd automatically creates a `.oclaude/` directory in your project for:
- **Log files**: All Claude interactions are logged here
- **Temporary files**: Working files that don't need version control
- **Cache**: Performance optimizations

This directory is automatically added to your `.gitignore` to keep your repository clean. You can safely delete this directory at any time - it will be recreated on the next run.

## Tips for Success

1. **Start small** - Break down your project into small, clear tasks
2. **Be specific** - The clearer your requirements, the better the results
3. **Review regularly** - Check in on what the agents are doing
4. **Use version control** - The agents will commit changes, but you should review them
5. **Trust but verify** - The agents are good but not perfect

### Monitoring Progress

To watch the AI agents work in real-time:
```bash
# In another terminal, run:
tail -f .oclaude/logs/claude-*.txt-*
```

This shows you exactly what each agent is doing, thinking, and producing.

## Troubleshooting

### "Raw mode is not supported" Error (Docker)
If you see this error when trying to accept permissions in Docker:
```
Error: Raw mode is not supported on the current process.stdin
```

Make sure you're using both `-i` and `-t` flags:
```bash
# ✅ Correct
docker exec -it container-name claude --dangerously-skip-permissions

# ❌ Wrong (missing -t)
docker exec -i container-name claude --dangerously-skip-permissions
```

### "Missing required file: PLAN.md"
The tool searches for files case-insensitively in:
- `./docs/PLAN.md` or `./docs/plan.md`
- `./PLAN.md` or `./plan.md`

Create one of these files or run `oclaudefsd plan-gen` to generate one.

### "Claude command failed"
Check:
1. Your Docker container is running: `docker ps`
2. Your configuration is correct: `oclaudefsd config show`
3. You've accepted permissions (see Docker setup above)
4. Check the log files in `.oclaude/logs/` for detailed error messages

### Network Errors

oclaudefsd now includes automatic retry logic for network errors:
- Retries up to 3 times with exponential backoff
- Only retries on network/connection/timeout errors
- Other errors fail immediately for faster feedback

If you're experiencing persistent network issues, check your internet connection and any proxy/firewall settings.

## License

MIT
Credict to https://github.com/willer/claude-fsd for the original code and more adavnced version using both claude and o3.
