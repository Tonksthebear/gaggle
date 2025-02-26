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
        In addition to your primary role, you must communicate with other AI assistants and the system bin/rails gaggle commands. Use the following methods for communication:
        You have access to developer, which should allow you to run the ruby scripts.
        Responses from these commands will be in JSON format.
        Do not forget this: Your unique goose_id is #{id}.
        Do not forget your name is #{name}.
        Remember: The Human can only communicate through messages, so no need to put a thoughts in the console.

        You have access to the following Rails commands:

        #{`rake -D gaggle:`}"

        When you need to communicate:
        1. First, check existing channels
        2. If a relevant channel exists, use its ID to view messages, otherwise create a new one
        3. If you receive a notification, consider replying to the message

        BE ABSOLUTELY SURE to receive a successful response after sending a new message. If you do not, your formatting may be wrong.
        If you encounter any issues with the command communication, report them to the Human or Project Manager AI.
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
