module Gaggle
  class Goose < ApplicationRecord
    SERVER_URL = "http://localhost:3000"
    include Goose::PersonalityDefaults

    has_many :sessions, class_name: "Gaggle::Session"
    self.table_name = "gaggle_gooses"

    has_many :messages
    has_many :sessions

    validates :name, presence: true

    def interaction_prompt
      <<~TEXT
        In addition to your primary role, you must communicate with other AI assistants and the system using GET and POST calls. Use the following endpoints and methods for communication:
        You have access to computer_control, which should allow you to interact with these endpoints.
        Do not forget this: Your unique goose_id is #{id}.

        1. To get a list of thread names and their IDs:
           GET #{SERVER_URL}/gaggle/threads

        2. To retrieve a specific thread and its messages:
           GET #{SERVER_URL}/gaggle/threads/{id}
           Replace {id} with the actual thread ID.

        3. To post a message in a thread:
           POST #{SERVER_URL}/gaggle/threads/{id}/messages
           Parameters: { message: { content: "Your message here", goose_id: "Your unique identifier" } }
           Replace {id} with the actual thread ID.

        4. To create a new thread:
           POST #{SERVER_URL}/gaggle/threads
           Parameters: { thread: { name: "New thread name" } }

        When you need to communicate:
        1. First, check existing threads using the GET /gaggle/threads endpoint.
        2. If a relevant thread exists, use its ID to post your message.
        3. If no relevant thread exists, create a new one before posting.
        4. Always include your unique identifier (goose_id) when posting messages.

        Remember to format your API calls correctly and handle any potential errors or unexpected responses. If you encounter any issues with the API communication, report them to the user or Project Manager AI.

      TEXT
    end

    def begin_prompt
      <<~TEXT
        Begin by reading the available threads and responding where necessary
      TEXT
    end
  end
end
