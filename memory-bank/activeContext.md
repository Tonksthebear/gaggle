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
  - Has many `Gaggle::Notification` records.
- **Notes:**
  - There is no direct association with channels. Channel participation is inferred from which geese have sent messages.

### Gaggle::Channel
- **Attributes:**
  - `name` (string)
- **Associations:**
  - Has many `Gaggle::Message` records.
- **Notes:**
  - No direct connection to geese; participants are determined by the senders of messages in the channel.

### Gaggle::Message
- **Attributes:**
  - `content` (text)
  - `channel_id` (foreign key to Gaggle::Channel)
  - `goose_id` (foreign key to Gaggle::Goose; optional – a nil value indicates the message was sent by the user)
- **Associations:**
  - Belongs to a `Gaggle::Channel`
  - Belongs to a `Gaggle::Goose` (optional)
- **Business Logic:**
  - Upon creation, trigger notification generation:
    - If `goose_id` is nil (message from the user), notify all geese that have previously sent messages in the channel.
    - If the message content includes an "@goose_name" mention, generate a notification for that specific goose even if they haven't participated in the channel.

### Gaggle::Notification
- **Attributes:**
  - `read_at` (timestamp, indicates when the notification was seen)
  - `message_id` (foreign key to the triggering message)
  - `goose_id` (foreign key to `Gaggle::Goose`; optional – a nil value implies the notification is for the user)
  - `messageable_id` (foreign key to the triggering message or channel)
  - `messageable_type` (string, the class name of the messageable object)
- **Associations:**
  - Belongs to a `Gaggle::Goose` (optional)
  - Belongs to a `Gaggle::Message`
  - Belongs to a `messageable`, polymorphic: true

## Key Design Decisions
- **Namespacing:** All models are defined under the `Gaggle` module to avoid conflicts and ensure smooth integration with host applications.
- **Association Simplification:** 
  - No polymorphic associations are used. 
  - The relationship between channels and geese is derived from messages – there is no separate join table.
- **Notification Logic:**
  - Notifications are automatically generated after a message is created.
  - For messages from the user (nil sender), all participating geese in the channel are notified.
  - Specific @mentions in a message trigger targeted notifications.
- **Database Migrations:**
  - Tables will be prefixed appropriately (e.g., `gaggle_gooses`, `gaggle_channels`, `gaggle_messages`, `gaggle_notifications`) to avoid naming collisions in the host application.

## Completed Tasks
- Implemented the channel creation flow:
  - Updated the `Gaggle::ChannelsController` to include `new` and `create` actions.
  - Created the `app/views/gaggle/channels/new.html.erb` view with a form to create new channels.
  - Styled the form using Tailwind CSS.
  - Added an "Edit" button to the channel show view, styled with Tailwind CSS.
- Implemented the Goose creation and edit flow:
  - Updated the `Gaggle::GooseController` to include full CRUD actions.
  - Created the profile view at `app/views/gaggle/gooses/show.html.erb`, and the new and edit views at `app/views/gaggle/goose/new.html.erb` and `app/views/gaggle/goose/edit.html.erb`.
  - Updated form partials with a card-style layout.
- Modified the sessions table to label sessions by their number instead of their ID.
- Reverted the change to make the sessions table scrollable.

## Next Steps
- Implement models and migrations for the above structure.
- Develop the callback/service for notification generation within `Gaggle::Message`.
  - Update the code so that we have the ability to send messages in channels and send notifications based on those messages and who is in the channels.
  - Added a form in `app/views/gaggle/channels/gooses/index.html.erb` for adding geese to a channel, using the same layout as the "new goose" form.
  - Update the changelog and create any necessary ADR entries.

## Rails Tasks
- The following Rails tasks have been created to allow external interaction with the Gaggle engine:
  - `gaggle:create_channel`: Creates a new channel with a given name. Returns JSON output with `status` and `message`.
  - `gaggle:send_message`: Sends a message to a specific channel from a given Goose. Requires `channel_id`, `goose_id`, and `content` environment variables. Returns JSON output with `status` and `message`.
  - `gaggle:get_channel_messages`: Retrieves all messages from a specific channel. Requires `channel_id` environment variable. Returns JSON output with `content` and `user_name` for each message.
  - `gaggle:get_goose_notifications`: Retrieves all notifications for a specific Goose. Requires `goose_id` environment variable. Returns JSON output.
  - `gaggle:get_channels`: Retrieves all channels. Returns JSON output.
