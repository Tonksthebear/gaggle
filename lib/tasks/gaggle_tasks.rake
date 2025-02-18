# lib/tasks/gaggle_tasks.rake

namespace :gaggle do
  desc "Creates a new thread with a given name"
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

  desc "Sends a message to a specific thread from a given Goose"
  task send_message: :environment do
    thread_id = ENV["thread_id"]
    goose_id = ENV["goose_id"]
    content = ENV["content"] || STDIN.read.chomp
    puts "Sending message to thread: #{thread_id} with content #{content}"

    if thread_id.blank? || goose_id.blank? || content.blank?
      puts "Error: Thread ID, Goose ID, and content are required."
    else
      thread = Gaggle::Thread.find(thread_id)
      goose = Gaggle::Goose.find(goose_id)
      Gaggle::Message.create(thread: thread, goose: goose, content: content)

      message = {
        status: "success",
        message: "Sent message to thread: #{thread.name} from Goose ID: #{goose.id}"
      }
      puts JSON.generate(message)
    end
  end

  desc "Retrieves all messages from a specific thread"
  task get_thread_messages: :environment do
    thread_id = ENV["thread_id"]

    if thread_id.blank?
      puts "Error: Thread ID is required."
    else
      thread = Gaggle::Thread.find(thread_id)
      messages = thread.messages.map do |message|
        { content: message.content, user_name: message.user_name, user_id: message.goose_id }
      end
      puts JSON.generate(messages)
    end
  end

  desc "Retrieves all notifications for a specific Goose"
  task get_goose_notifications: :environment do
    goose_id = ENV["goose_id"]

    if goose_id.blank?
      puts "Error: Goose ID is required."
    else
      goose = Gaggle::Goose.find(goose_id)
      notifications = goose.notifications.map do |notification|
        { id: notification.id, message_id: notification.message_id, read_at: notification.read_at }
      end
      puts JSON.generate(notifications)
    end
  end

  desc "Retrieves all threads"
  task get_threads: :environment do
    threads = Gaggle::Thread.all.map do |thread|
      { id: thread.id, name: thread.name }
    end
    puts JSON.generate(threads)
  end
end
