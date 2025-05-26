# oclaudefsd Requirements and Capabilities

## Overview
oclaudefsd (Claude Full Stack Development) is an AI-powered development automation tool that orchestrates multiple Claude instances to work as a cohesive development team. It enables continuous, autonomous development cycles with built-in code review and testing.

## Core Capabilities

### 1. Multi-Phase Development Workflow
- **Planning Phase**: Analyzes project plans and identifies next tasks
- **Development Phase**: Executes development tasks with full context
- **Review Phase**: Static code review runs in background
- **Testing/Committing Phase**: Final review, testing, and git operations

### 2. Docker Container Isolation
- Each project gets its own isolated Docker container
- Prevents cross-project contamination
- Automatic mount management for project directories
- Dynamic container naming (e.g., `claude-code-fsd-1`, `claude-code-fsd-2`)

### 3. Project Management
- Reads and updates `PLAN.md` files to track progress
- Supports case-insensitive file discovery
- Integrates with `BRIEF.md`, `QUESTIONS.md`, `REQUIREMENTS.md`, and `IDEAS.md`
- Megathinking mode activation every 4th cycle for architectural planning

### 4. Logging and Monitoring
- Separate log files for each phase:
  - `logs/claude-TIMESTAMP.txt-planner`
  - `logs/claude-TIMESTAMP.txt-developer`
  - `logs/claude-TIMESTAMP.txt-reviewer`
  - `logs/claude-TIMESTAMP.txt-tester`
- Real-time monitoring with tail -f
- Verbose mode (-v) for detailed output

### 5. Error Handling
- Specific detection for:
  - Token/usage limit errors
  - Rate limiting
  - Authentication issues
  - Network problems
  - Permission errors
- Shows actual Claude error messages
- Provides targeted solutions for each error type

### 6. Configuration Management
- Interactive setup wizard on first run
- Supports multiple Claude installation types:
  - Standard installation
  - Docker containers (recommended)
  - Custom commands
- Persistent configuration in `~/.config/oclaudefsd/config`

## Technical Requirements

### System Requirements
- Node.js >= 14.0.0
- Bash shell
- Git
- Docker (for containerized Claude)

### File Structure Requirements
Projects must have:
- `PLAN.md` or `plan.md` - Task list with checkboxes
- Optional: `BRIEF.md`, `QUESTIONS.md`, `REQUIREMENTS.md`, `IDEAS.md`
- Standard project structure with `docs/` directory supported

### Claude Requirements
- Claude Code installation
- Accepted permissions (`--dangerously-skip-permissions`)
- Valid authentication/API access
- Sufficient token allocation

## Usage Modes

### 1. Development Mode (default)
```bash
oclaudefsd dev
oclaudefsd -v  # verbose output
```
Continuously works through tasks in PLAN.md

### 2. Planning Mode
```bash
oclaudefsd plan
```
Updates project plan based on BRIEF.md

### 3. Plan Generation
```bash
oclaudefsd plan-gen
```
Creates initial project plan interactively

### 4. Docker Mount Management
```bash
oclaudefsd mount        # Mount current directory
oclaudefsd mount status # Check mount status
oclaudefsd mount list   # Show all project mappings
```

## Security Features
- Isolated Docker containers per project
- No cross-project file access
- Workspace path translation for Docker
- Secure permission handling

## Performance Features
- Concurrent phase execution (review runs in background)
- Efficient file discovery with case-insensitive search
- Process-based and path-based IPC for container coordination
- Automatic cleanup of orphaned containers

## Integration Capabilities
- Git integration for commits and pushes
- Linter integration (project-specific)
- Test framework awareness
- Markdown file management for documentation

## Monitoring and Debugging
- Multiple verbosity levels
- Progress indicators with timestamps
- Phase timing metrics
- Error stack traces in log files
- Debug mode with additional output

## Limitations
- Requires manual intervention for:
  - Initial permissions acceptance
  - Token limit issues
  - Complex merge conflicts
- Single task focus (one in-progress at a time)
- Sequential phase execution (except background review)