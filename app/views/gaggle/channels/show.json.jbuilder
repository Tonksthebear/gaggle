json.name @channel.name
json.messages @channel.messages do |message|
  next if @notification && message.updated_at < @notification.message.created_at
  json.(message, :id, :content, :user_name)
end
