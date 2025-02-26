# lib/tasks/gaggle.rake
namespace :gaggle do
  desc <<-DESC
  Sends a message to a specific channel
  To use: bin/rails gaggle:send_public_message channel_id={id} content="{content}"
          Replace {id} with channel/goose IDs and {content} with the message content.
          Escape quotes in {content} if needed (e.g., "Hello \"world\"").
          If content is omitted, it will read from STDIN.
  DESC

  task send_public_message: :environment do
    channel_id = ENV["channel_id"]
    goose_id = ENV["GOOSE_ID"]
    content = ENV["content"].presence || (STDIN.tty? ? nil : STDIN.read.chomp)

    if channel_id.blank? || goose_id.blank? || content.blank?
      puts "Error: Channel ID, Goose ID, and content are required."
    else
      begin
        unless channel_id =~ /^\d+$/ && goose_id =~ /^\d+$/
          puts "Error: Channel ID and Goose ID must be numeric."
          next
        end

        channel = Gaggle::Channel.find(channel_id)
        goose = Gaggle::Goose.find(goose_id)
        message = Gaggle::Message.create!(messageable: channel, goose: goose, content: content)

        result = {
          status: "success",
          message: "Sent message to channel '#{channel.name}' from Goose ID: #{goose.id}",
          message_id: message.id
        }
        puts JSON.generate(result)
      rescue ActiveRecord::RecordNotFound
        puts "Error: #{channel_id =~ /^\d+$/ && Gaggle::Channel.find_by(id: channel_id).nil? ? 'Gaggle::Channel' : 'Gaggle::Goose'} with ID #{channel_id =~ /^\d+$/ ? (Gaggle::Channel.find_by(id: channel_id).nil? ? channel_id : goose_id) : 'invalid'} not found."
      rescue ActiveRecord::RecordInvalid => e
        puts "Error: Message creation failed - #{e.message}"
      end
    end
  end
end
