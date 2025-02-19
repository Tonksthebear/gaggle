namespace :gaggle do
  desc <<-DESC
  Sends a message to a specific channel
  To use: bin/rails gaggle:send_public_message channel_id={id} content={content}"
          Replace {id} with channel id and {content} with the content of the message
          BE SURE to escape anything that may break out of the surrounding quotation marks. It needs to all be delivered as a single argument.
  DESC

  task send_public_message: :environment do
    channel_id = ENV["channel_id"]
    goose_id = ENV["GOOSE_ID"]
    content = ENV["content"] || STDIN.read.chomp
    puts "Sending message to channel: #{channel_id} with content #{content}"

    if channel_id.blank? || goose_id.blank? || content.blank?
      puts "Error: Channel ID, Goose ID, and content are required."
    else
      channel = Gaggle::Channel.find(channel_id)
      goose = Gaggle::Goose.find(goose_id)
      Gaggle::Message.create(messageable: channel, goose: goose, content: content)

      message = {
        status: "success",
        message: "Sent message to channel: #{channel.name} from Goose ID: #{goose.id}"
      }
      puts JSON.generate(message)
    end
  end
end
