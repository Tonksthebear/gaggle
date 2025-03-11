json.key_format! camelize: :lower

json.array! @channel.messages.each do |message|
  json.(message, :id, :content, :user_name)
end
