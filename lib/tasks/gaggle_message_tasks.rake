namespace :gaggle do
  desc <<-DESC
  Sends a message to a specific thread
  To use: bin/rails gaggle:send_public_message thread_id={id} content={content}"
          Replace {id} with thread id and {content} with the content of the message
          BE SURE to escape anything that may break out of the surrounding quotation marks. It needs to all be delivered as a single argument.
  DESC

  task send_public_message: :environment do
    thread_id = ENV["thread_id"]
    goose_id = ENV["GOOSE_ID"]
    content = ENV["content"] || STDIN.read.chomp
    puts "Sending message to thread: #{thread_id} with content #{content}"

    if thread_id.blank? || goose_id.blank? || content.blank?
      puts "Error: Thread ID, Goose ID, and content are required."
    else
      thread = Gaggle::Thread.find(thread_id)
      goose = Gaggle::Goose.find(goose_id)
      Gaggle::Message.create(messageable: thread, goose: goose, content: content)

      message = {
        status: "success",
        message: "Sent message to thread: #{thread.name} from Goose ID: #{goose.id}"
      }
      puts JSON.generate(message)
    end
  end
end
