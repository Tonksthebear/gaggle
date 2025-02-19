# Progress for Gaggle Rails Engine

## Current Status

- Finalized model design and business logic for the engine.
- Active Context has been updated to reflect the design choices:
  - The `Gaggle::Notification` model now belongs to a `Gaggle::Thread`.
  - All models are namespaced under the `Gaggle` module (i.e. `Gaggle::Goose`, `Gaggle::Thread`, `Gaggle::Message`, and `Gaggle::Notification`).
  - There are no polymorphic associations. Instead, `Gaggle::Message` belongs to `Gaggle::Goose` optionally—where a nil value indicates the message was sent by the user.
  - `Gaggle::Thread` has no direct association with geese; participants are derived from the senders of messages.
  - Notification logic is defined such that when a message is created:
    - If it is sent by the user (nil sender), all geese that have previously participated in the thread are notified.
    - Additionally, an "@goose_name" mention in the message triggers a targeted notification to that goose even if they haven’t yet participated.
- Implemented the thread creation flow:
  - Updated the `Gaggle::ThreadsController` to include `new` and `create` actions.
  - Created the `app/views/gaggle/threads/new.html.erb` view with a form to create new threads.
  - Styled the form using Tailwind CSS.
  - Added an "Edit" button to the thread show view, styled with Tailwind CSS.
- Gaggle::Session managing the running executables
- Removed that model from autoload so that the class variables don't get reset whenever a file gets saved
- Full session management from starting the executable, viewing the session, messaging the session, and stopping the session

## Next Steps

1.  The `gaggle_notifications` migration has been updated to use a polymorphic association.
2.  The `Gaggle::Notification` model has been updated to use a polymorphic association.
3.  The `Gaggle::Goose` model has been updated to use `messageable.message.thread.id`
4.  Update the code so that we have the ability to send messages in threads and send notifications based on those messages and who is in the threads
5. Write tests to cover model validations, associations, and notification logic.
6. Update supporting documentation (CHANGELOG, ADRs) as the implementation evolves.
7. Implemented Rails tasks for external interaction with the Gaggle engine:
   - `gaggle:create_thread` (returns JSON output)
   - `gaggle:send_message` (requires environment variables, returns JSON output)
   - `gaggle:get_thread_messages` (requires environment variable, returns JSON output)
   - `gaggle:get_goose_notifications` (requires environment variable, returns JSON output)
   - `gaggle:get_threads` (returns JSON output)
- Updated the `app/views/gaggle/overviews/show.html.erb` file to include a welcome page with instructions to create a Goose using the left sidebar. The welcome page is styled with Tailwind CSS.
- Modified the sessions table to label sessions by their number instead of their ID.
- Reverted the change to make the sessions table scrollable.

## Notes
- This design is targeted for development purposes and may evolve as implementation progresses.
- Future modifications may be required based on further testing and integration with host applications.
