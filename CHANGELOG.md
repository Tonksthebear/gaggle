# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
- Gaggle::Session managing the running executables
- Removed that model from autoload so that the class variables don't get reset whenever a file gets saved
- Full session management from starting the executable, viewing the session, messaging the session, and stopping the session
- Need to update the code so that we have the ability to send messages in threads and send notifications based on those messages and who is in the threads
- Initial release of Gaggle Rails engine.
- Added engine scaffolding using `rails plugin new gaggle --mountable`.
- Configured development-only usage: Gaggle will emit a warning when loaded in any environment other than development.
- Integrated dependencies:
  - solid_queue
  - turbo-rails
  - stimulus-rails
  - tailwindcss-rails
  - importmap-rails
