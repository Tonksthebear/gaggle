module Gaggle
  class Goose < ApplicationRecord
    SERVER_URL = "http://localhost:3000"
    include Goose::PersonalityDefaults

    has_many :sessions, class_name: "Gaggle::Session"
    self.table_name = "gaggle_gooses"

    has_many :messages
    has_many :sessions
    has_many :notifications

    validates :name, presence: true, uniqueness: true

    def interaction_prompt
      <<~TEXT
        In addition to your primary role, you must communicate with other AI assistants and the system bin/rails gaggle commands. Use the following methods for communication:
        You have access to developer, which should allow you to run the ruby scripts.
        Responses from these commands will be in JSON format.
        Do not forget this: Your unique goose_id is #{id}.
        Do not forget your name is #{name}.

        1. To get a list of thread names and their IDs:
           bin/rails gaggle:get_threads

        2. To retrieve a specific thread and its messages:
           bin/rails gaggle:get_thread_messages thread_id={id}
           Replace {id} with the actual thread ID.

        3. To post a message in a thread:
           bin/rails gaggle:send_message thread_id={id} goose_id={goose_id} content={content}
           Replace {id} with thread id, {goose_id} with your own id, {content} with the content of the message
           It is recommended to use a heredoc for the content of the message so that the command receives the full message content

        4. To create a new thread:
           bin/rails gaggle:create_thread name={name}
           Replace {name} with the name of the thread

        When you need to communicate:
        1. First, check existing threads
        2. If a relevant thread exists, use its ID to view messages, otherwise create a new one
        3. If you receive a notification, consider replying to the message

        If you encounter any issues with the command communication, report them to the user or Project Manager AI.
      TEXT
    end

    def begin_prompt
      <<~TEXT
        Begin by reading the available threads and responding where necessary
      TEXT
    end

    def notify_of_message(message:)
      Rails.logger.info "Notifying goose of message: #{message.id}"
      if session = sessions.running.first
        session.write_to_executable("Automated Reply: You have a new message in thread: #{message.thread.id}")
        true
      else
        Rails.logger.error "No running sessions found for goose: #{id}"
        false
      end
    end
  end
end
