namespace :gaggle do
  desc <<-DESC
  Retrieves all channels
  To use: bin/rails gaggle:get_channels
  DESC
  task get_channels: :environment do
    channels = Gaggle::Channel.all.map do |channel|
      { id: channel.id, name: channel.name }
    end
    puts JSON.generate(channels)
  end

  desc <<-DESC
  Creates a new channel with a given name.
  To use: bin/rails gaggle:create_channel name="{name}"
          Replace {name} with the name of the channel
  DESC
  task create_channel: :environment do
    name = ENV["name"]
    if name.blank?
      puts "Error: Channel name is required."
    else
      channel = Gaggle::Channel.create(name: name)
      message = {
        status: "success",
        message: "Created channel with ID: #{channel.id} and name: #{channel.name}"
      }
      puts JSON.generate(message)
    end
  end

  desc <<-DESC
  Updates a channel with a given name
  To use: bin/rails gaggle:update_channel channel_id={id} name="{name}"
          Replace {id} with channel id and {name} with the new name
  DESC
  task update_channel: :environment do
    channel_id = ENV["channel_id"]
    name = ENV["name"]

    if channel_id.blank? || name.blank?
      puts "Error: Channel ID and name are required."
    else
      channel = Gaggle::Channel.find(channel_id)
      channel.update(name: name)
      message = {
        status: "success",
        message: "Updated channel with ID: #{channel.id} and name: #{channel.name}"
      }
      puts JSON.generate(message)
    end
  end

  desc <<-DESC
  Deletes a channel with a given ID
  To use: bin/rails gaggle:delete_channel channel_id={id}
          Replace {id} with channel id
  DESC
  task delete_channel: :environment do
    channel_id = ENV["channel_id"]

    if channel_id.blank?
      puts "Error: Channel ID is required."
    else
      channel = Gaggle::Channel.find(channel_id)
      channel.destroy
      message = {
        status: "success",
        message: "Deleted channel with ID: #{channel.id}"
      }
      puts JSON.generate(message)
    end
  end

  desc <<-DESC
  Retrieves all messages from a specific channel
  To use: bin/rails gaggle:get_channel_messages channel_id={id}
          Replace {id} with the actual channel ID.
          This will return new messages since the last time the task was run.
          If there are no new messages, it will return all messages.
  DESC
  task get_channel_messages: :environment do
    channel_id = ENV["channel_id"]
    goose_id = ENV["GOOSE_ID"]
    goose = Gaggle::Goose.find(goose_id)

    if channel_id.blank?
      puts "Error: Channel ID is required."
    else
      channel = Gaggle::Channel.find(channel_id)
      notification = goose.notifications.unread.for_messageable(channel).first
      messages = channel.messages.later_than(notification&.message&.created_at).map do |message|
        { content: message.content, user_name: message.user_name, user_id: message.goose_id }
      end
      puts JSON.generate(messages)
      notification&.mark_read!
    end
  end

  desc <<-DESC
    Retrieves list of channels with unread messages
    To use: bin/rails gaggle:get_unread_channels
  DESC
  task get_unread_channels: :environment do
    goose_id = ENV["GOOSE_ID"]
    goose = Gaggle::Goose.find(goose_id)

    messageables = goose.notifications.unread.messageables.map do |messageable|
      { type: messageable.class, id: messageable.id }
    end

    puts JSON.generate(messageables)
  end
end
