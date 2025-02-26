namespace :gaggle do
  # Shared method to process channel creation/update
  def process_channel(channel_id: nil, name:, goose_ids:)
    if name.blank?
      puts "Error: Channel name is required."
      return
    end
    if channel_id&.present? && channel_id !~ /^\d+$/
      puts "Error: Channel ID must be numeric."
      return
    end
    if goose_ids&.any? { |id| id !~ /^\d+$/ }
      puts "Error: All goose IDs must be numeric."
      return
    end

    begin
      channel = channel_id ? Gaggle::Channel.find(channel_id) : Gaggle::Channel.new
      channel.name = name

      if goose_ids.present?
        goose_ids = goose_ids.map(&:to_i)
        missing_ids = goose_ids - Gaggle::Goose.where(id: goose_ids).pluck(:id)
        if missing_ids.any?
          puts "Error: Gaggle::Goose IDs not found: #{missing_ids.join(', ')}"
          return
        end
        channel.goose_ids = goose_ids
      end

      action = channel.new_record? ? "Created" : "Updated"
      channel.save!
      message = {
        status: "success",
        message: "#{action} channel with ID: #{channel.id}, name: #{channel.name}, gooses: #{channel.goose_ids.join(', ')}"
      }
      puts JSON.generate(message)
    rescue ActiveRecord::RecordNotFound
      puts "Error: Gaggle::Channel with ID #{channel_id} not found."
    rescue ActiveRecord::RecordInvalid => e
      puts "Error: Channel #{action.downcase} failed - #{e.message}"
    end
  end

  desc <<-DESC
    Retrieves all channels
    To use: bin/rails gaggle:get_channels
  DESC
  task get_channels: :environment do
    begin
      channels = Gaggle::Channel.all.order(:id).map do |channel|
        { id: channel.id, name: channel.name }
      end
      puts JSON.generate(channels)
    rescue => e
      puts "Error: Failed to retrieve channels - #{e.message}"
    end
  end

  desc <<-DESC
    Creates a new channel with a given name and optional goose IDs
    To use: bin/rails gaggle:create_channel name="{name}" [goose_ids="{ids}"]
            Replace {name} with the name of the channel and {ids} with a comma-separated list of goose IDs (optional)
  DESC
  task create_channel: :environment do
    name = ENV["name"]
    goose_ids = ENV["goose_ids"]&.split(",")&.map(&:strip)
    process_channel(name: name, goose_ids: goose_ids)
  end

  desc <<-DESC
    Updates a channel with a given name and optional goose IDs
    To use: bin/rails gaggle:update_channel channel_id={id} name="{name}" [goose_ids="{ids}"]
            Replace {id} with channel id, {name} with the new name, and {ids} with a comma-separated list of goose IDs (optional)
  DESC
  task update_channel: :environment do
    channel_id = ENV["channel_id"]
    name = ENV["name"]
    goose_ids = ENV["goose_ids"]&.split(",")&.map(&:strip)

    if channel_id.blank?
      puts "Error: Channel ID and name are required."
    else
      process_channel(channel_id: channel_id, name: name, goose_ids: goose_ids)
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
    elsif channel_id !~ /^\d+$/
      puts "Error: Channel ID must be numeric."
    else
      begin
        channel = Gaggle::Channel.find(channel_id)
        channel.destroy!
        message = {
          status: "success",
          message: "Deleted channel with ID: #{channel.id}"
        }
        puts JSON.generate(message)
      rescue ActiveRecord::RecordNotFound
        puts "Error: Gaggle::Channel with ID #{channel_id} not found."
      end
    end
  end

  desc <<-DESC
    Retrieves all messages from a specific channel
    To use: bin/rails gaggle:get_channel_messages channel_id={id} GOOSE_ID={goose_id}
            Replace {id} with the channel ID and {goose_id} with the goose ID.
            Returns messages since the last unread notification, or all if none.
  DESC
  task get_channel_messages: :environment do
    channel_id = ENV["channel_id"]
    goose_id = ENV["GOOSE_ID"]

    if channel_id.blank? || goose_id.blank?
      puts "Error: Channel ID and Goose ID are required."
    elsif channel_id !~ /^\d+$/ || goose_id !~ /^\d+$/
      puts "Error: Channel ID and Goose ID must be numeric."
    else
      begin
        goose = Gaggle::Goose.find(goose_id)
        channel = Gaggle::Channel.find(channel_id)
        notification = goose.notifications.unread.for_messageable(channel).first
        messages = channel.messages.later_than(notification&.message&.created_at).map do |message|
          { content: message.content, user_name: message.user_name, user_id: message.goose_id }
        end
        puts JSON.generate(messages)
        notification&.mark_read!
      rescue ActiveRecord::RecordNotFound => e
        puts "Error: #{e.message.include?('Goose') ? 'Gaggle::Goose' : 'Gaggle::Channel'} with ID #{e.message.include?('Goose') ? goose_id : channel_id} not found."
      end
    end
  end

  desc <<-DESC
    Retrieves list of channels with unread messages
    To use: bin/rails gaggle:get_unread_channels GOOSE_ID={goose_id}
            Replace {goose_id} with the goose ID.
  DESC
  task get_unread_channels: :environment do
    goose_id = ENV["GOOSE_ID"]

    if goose_id.blank?
      puts "Error: Goose ID is required."
    elsif goose_id !~ /^\d+$/
      puts "Error: Goose ID must be numeric."
    else
      begin
        goose = Gaggle::Goose.find(goose_id)
        messageables = goose.notifications.unread.messageables.map do |messageable|
          { type: messageable.class.name, id: messageable.id }
        end
        puts JSON.generate(messageables)
      rescue ActiveRecord::RecordNotFound
        puts "Error: Gaggle::Goose with ID #{goose_id} not found."
      end
    end
  end
end
