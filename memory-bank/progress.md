# Progress for Gaggle Rails Engine

## Current Status

- Finalized model design and business logic for the engine.
- Active Context has been updated to reflect the design choices:
  - The `Gaggle::Notification` model now belongs to a `Gaggle::Channel`.
  - All models are namespaced under the `Gaggle` module (i.e. `Gaggle::Goose`, `Gaggle::Channel`, `Gaggle::Message`, and `Gaggle::Notification`).
  - There are no polymorphic associations. Instead, `Gaggle::Message` belongs to `Gaggle::Goose` optionally—where a nil value indicates the message was sent by the user.
  - `Gaggle::Channel` has no direct association with geese; participants are derived from the senders of messages.
  - Notification logic is defined such that when a message is created:
    - If it is sent by the user (nil sender), all geese that have previously participated in the channel are notified.
    - Additionally, an "@goose_name" mention in the message triggers a targeted notification to that goose even if they haven't yet participated.
- CI pipeline fully operational with GitHub Actions
- Asset pipeline flexibility implemented (Propshaft/Sprockets support)
- Channel-Goose relationships formalized with join table
- Notification system enhanced with delivery tracking
- Session management system implemented with:
  - Thread-safe communication
  - Real-time output broadcasting
  - Proper resource cleanup
  - Session-specific logging
  - 3-second output silence requirement for input control

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
- Gaggle::Session managing the running executables:
  - Removed model from autoload to prevent class variable resets
  - Implemented thread-safe command handling
  - Added input control with 3-second output silence requirement
  - Full session management from starting to stopping
- Modified the sessions table to label sessions by their number instead of their ID
- Reverted the change to make the sessions table scrollable
- Implemented Rails tasks for external interaction:
  - `gaggle:create_channel`
  - `gaggle:send_message`
  - `gaggle:get_channel_messages`
  - `gaggle:get_goose_notifications`
  - `gaggle:get_channels`

## Next Steps

1. The `gaggle_notifications` migration has been updated to use a polymorphic association.
2. The `Gaggle::Notification` model has been updated to use a polymorphic association.
3. The `Gaggle::Goose` model has been updated to use `messageable.message.channel.id`
4. Update the code so that we have the ability to send messages in channels and send notifications based on those messages and who is in the channels
5. Write tests to cover model validations, associations, and notification logic.
6. Update supporting documentation (CHANGELOG, ADRs) as the implementation evolves.
7. Added a form to `app/views/gaggle/channels/gooses/index.html.erb` for adding geese to a channel, using the same layout as the "new goose" form.

## Notes
- This design is targeted for development purposes and may evolve as implementation progresses.
- Future modifications may be required based on further testing and integration with host applications.
