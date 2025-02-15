# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
- Initial release of Gaggle Rails engine.
- Added engine scaffolding using `rails plugin new gaggle --mountable`.
- Configured development-only usage: Gaggle will emit a warning when loaded in any environment other than development.
- Integrated dependencies:
  - solid_queue
  - turbo-rails
  - stimulus-rails
  - tailwindcss-rails
  - importmap-rails
