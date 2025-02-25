# System Patterns

This document details the system architecture, key technical decisions, design patterns, and component relationships for the project.

## Database Structure
- Tables are prefixed with 'gaggle_' to avoid naming collisions
- Join table `gaggle_channel_gaggle_goose` implements many-to-many relationship between channels and geese
- Notifications track delivery status with `delivered_at` timestamp

## Thread Management in Sessions
- Uses PTY (Pseudo-Terminal) for process management
- Thread-safe communication using Queue and Mutex/ConditionVariable
- Main components:
  - Session thread: Manages the overall session lifecycle
  - Input thread: Handles command submission to the executable
  - Output monitoring: Uses IO.select for non-blocking output reading
- Safety features:
  - Thread synchronization with mutex locks
  - Proper resource cleanup in ensure blocks
  - Timeout handling for stream operations
  - Error handling for stream and process issues
- Input Control:
  - Terminal input is locked until program output has stopped for 3 seconds
  - Prevents command overlap and ensures proper output capture
  - Uses IO.select with a 2-second timeout for output monitoring

## CI/CD Pipeline
- GitHub Actions workflow for continuous integration
- Testing across multiple Rails versions using Appraisal
- Support for both Propshaft and Sprockets configurations
