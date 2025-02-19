namespace :gaggle do
  desc <<-DESC
  Retrieves all threads
  To use: bin/rails gaggle:get_threads
  DESC
  task get_threads: :environment do
    threads = Gaggle::Thread.all.map do |thread|
      { id: thread.id, name: thread.name }
    end
    puts JSON.generate(threads)
  end

  desc <<-DESC
  Creates a new thread with a given name.
  To use: bin/rails gaggle:create_thread name="{name}"
          Replace {name} with the name of the thread
  DESC
  task create_thread: :environment do
    name = ENV["name"]
    if name.blank?
      puts "Error: Thread name is required."
    else
      thread = Gaggle::Thread.create(name: name)
      message = {
        status: "success",
        message: "Created thread with ID: #{thread.id} and name: #{thread.name}"
      }
      puts JSON.generate(message)
    end
  end

  desc <<-DESC
  Updates a thread with a given name
  To use: bin/rails gaggle:update_thread thread_id={id} name="{name}"
          Replace {id} with thread id and {name} with the new name
  DESC
  task update_thread: :environment do
    thread_id = ENV["thread_id"]
    name = ENV["name"]

    if thread_id.blank? || name.blank?
      puts "Error: Thread ID and name are required."
    else
      thread = Gaggle::Thread.find(thread_id)
      thread.update(name: name)
      message = {
        status: "success",
        message: "Updated thread with ID: #{thread.id} and name: #{thread.name}"
      }
      puts JSON.generate(message)
    end
  end

  desc <<-DESC
  Deletes a thread with a given ID
  To use: bin/rails gaggle:delete_thread thread_id={id}
          Replace {id} with thread id
  DESC
  task delete_thread: :environment do
    thread_id = ENV["thread_id"]

    if thread_id.blank?
      puts "Error: Thread ID is required."
    else
      thread = Gaggle::Thread.find(thread_id)
      thread.destroy
      message = {
        status: "success",
        message: "Deleted thread with ID: #{thread.id}"
      }
      puts JSON.generate(message)
    end
  end

  desc <<-DESC
  Retrieves all messages from a specific thread
  To use: bin/rails gaggle:get_thread_messages thread_id={id}
          Replace {id} with the actual thread ID.
          This will return new messages since the last time the task was run.
          If there are no new messages, it will return all messages.
  DESC
  task get_thread_messages: :environment do
    thread_id = ENV["thread_id"]
    goose_id = ENV["GOOSE_ID"]
    goose = Gaggle::Goose.find(goose_id)

    if thread_id.blank?
      puts "Error: Thread ID is required."
    else
      thread = Gaggle::Thread.find(thread_id)
      notification = goose.notifications.unread.for_messageable(thread).first
      messages = thread.messages.later_than(notification&.message&.created_at).map do |message|
        { content: message.content, user_name: message.user_name, user_id: message.goose_id }
      end
      puts JSON.generate(messages)
      notification&.mark_read!
    end
  end

  desc <<-DESC
    Retrieves list of threads with unread messages
    To use: bin/rails gaggle:get_unread_threads
  DESC
  task get_unread_threads: :environment do
    goose_id = ENV["GOOSE_ID"]
    goose = Gaggle::Goose.find(goose_id)

    messageables = goose.notifications.unread.messageables.map do |messageable|
      { type: messageable.class, id: messageable.id }
    end

    puts JSON.generate(messageables)
  end
end
