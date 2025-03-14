module Gaggle
  class Goose < ApplicationRecord
    SERVER_URL = "http://localhost:60053"
    self.table_name = "gaggle_gooses"
    include Goose::PersonalityDefaults

    default_scope { order(created_at: :asc) }

    has_many :messages, dependent: :destroy
    has_many :private_messages, class_name: "Gaggle::Message", as: :messageable, dependent: :destroy
    has_many :sessions, dependent: :destroy
    has_many :notifications, dependent: :destroy
    has_many :recipient_notifications, class_name: "Gaggle::Notification", as: :messageable
    has_and_belongs_to_many :channels

    validates :name, presence: true, uniqueness: true

    def private_channel(goose)
      Gaggle::Message.where(messageable: self, goose:).or(Gaggle::Message.where(messageable: goose, goose: self))
    end

    def interaction_prompt
      <<~TEXT
        In addition to your primary role, you must communicate with other AI assistants and the gaggle MCP tools.
        Do not forget this: Your unique goose_id is #{id}. This id will let you know which messages are yours vs others.
        Do not forget your name is #{name}.
        Remember: The Human can only communicate through messages, so no need to put a thoughts in the console.

        Gaggle is a chat board style interface with channels to communicate and messages to send.

        Here is the flow for working in the system

        ```mermaid
          graph TD
            A[Start] --> B[Check Existing Channels]
            B --> C{Anyone Needs a Response?}
            C -->|Yes| D[Respond to Relevant Messages]
            C -->|No| E[Perform Tasks Needing Resumption]
            D --> E
            E --> F[Check for Notifications]
            F -->|Yes| G[Check Channel for Notification]
            G --> H{Message Relevant?}
            H -->|Yes| I{Need to Respond?}
            I -->|Yes| J[Respond to Notification]
            I -->|No| K[End]
            H -->|No| K
            F -->|No| K
            K[End - Wait for Next Notification]
        ```

        Here is how to manage bugs:

        ```mermaid
          graph TD
            A[Start] --> B{Hit a Bug or Issue?}
            B -->|Yes| C[Choose Action]
            C --> D{Ask in Relevant Channel}
            C --> E{Create Relevant Channel}
            D --> F[Post Bug/Issue Details]
            E --> F
            F --> G[Wait for Human Response]
            B -->|No| H{Want to Delete Channel?}
            H -->|Yes| I[Confirm Deletion in Channel]
            I --> J[Wait for Human Confirmation]
            J -->|Confirmed| K[Delete Channel]
            J -->|Not Confirmed| L[Keep Channel]
            H -->|No| M[Continue Monitoring]
            G --> M
            K --> M
            L --> M
          ```

        DO NOT FORGET: Whenever you are trying to interact with the system, use the gaggle MCP tools.
      TEXT
    end

    def begin_prompt
      <<~TEXT
        Begin by reading the available channels and responding where necessary
      TEXT
    end

    def notify_of_message(notification:)
      Rails.logger.info "Notifying goose of message: #{notification.message_id}"
      if session = sessions.running.first
        session.write_to_executable("Automated: You have a new message in #{notification.messageable_type}: #{notification.messageable_id}. Please respond")
        true
      else
        Rails.logger.error "No running sessions found for goose: #{id}"
        false
      end
    end
  end
end
