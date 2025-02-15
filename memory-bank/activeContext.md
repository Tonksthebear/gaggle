# Active Context for Gaggle Rails Engine Model Design

## Overview
This document summarizes the current model design and business logic for the Gaggle Rails Engine. The engine is intended for development purposes and uses a simplified mechanism for a single “user” – when a message’s sender (`goose_id`) is nil, it indicates that the message was sent by the user.

## Models and Their Structures

### Gaggle::Goose
- **Attributes:**
  - `name` (string)
  - `prompt` (text)
- **Associations:**
  - Has many `Gaggle::Message` records.
- **Notes:**
  - There is no direct association with threads. Thread participation is inferred from which geese have sent messages.

### Gaggle::Thread
- **Attributes:**
  - `name` (string)
- **Associations:**
  - Has many `Gaggle::Message` records.
- **Notes:**
  - No direct connection to geese; participants are determined by the senders of messages in the thread.

### Gaggle::Message
- **Attributes:**
  - `content` (text)
  - `thread_id` (foreign key to Gaggle::Thread)
  - `goose_id` (foreign key to Gaggle::Goose; optional – a nil value indicates the message was sent by the user)
- **Associations:**
  - Belongs to a `Gaggle::Thread`
  - Belongs to a `Gaggle::Goose` (optional)
- **Business Logic:**
  - Upon creation, trigger notification generation:
    - If `goose_id` is nil (message from the user), notify all geese that have previously sent messages in the thread.
    - If the message content includes an "@goose_name" mention, generate a notification for that specific goose even if they haven't participated in the thread.

### Gaggle::Notification
- **Attributes:**
  - `read_at` (timestamp, indicates when the notification was seen)
  - `message_id` (foreign key to the triggering message)
  - `goose_id` (foreign key to `Gaggle::Goose`; optional – a nil value implies the notification is for the user)
- **Associations:**
  - Belongs to a `Gaggle::Message`
  - Optionally belongs to a `Gaggle::Goose`

## Key Design Decisions
- **Namespacing:** All models are defined under the `Gaggle` module to avoid conflicts and ensure smooth integration with host applications.
- **Association Simplification:** 
  - No polymorphic associations are used. 
  - The relationship between threads and geese is derived from messages – there is no separate join table.
- **Notification Logic:**
  - Notifications are automatically generated after a message is created.
  - For messages from the user (nil sender), all participating geese in the thread are notified.
  - Specific @mentions in a message trigger targeted notifications.
- **Database Migrations:**
  - Tables will be prefixed appropriately (e.g., `gaggle_gooses`, `gaggle_threads`, `gaggle_messages`, `gaggle_notifications`) to avoid naming collisions in the host application.

## Completed Tasks
- Implemented the thread creation flow:
  - Updated the `Gaggle::ThreadsController` to include `new` and `create` actions.
  - Created the `app/views/gaggle/threads/new.html.erb` view with a form to create new threads.
  - Styled the form using Tailwind CSS.
  - Added an "Edit" button to the thread show view, styled with Tailwind CSS.

## Next Steps
- Implement models and migrations for the above structure.
- Develop the callback/service for notification generation within `Gaggle::Message`.
- Update the changelog and create any necessary ADR entries.
