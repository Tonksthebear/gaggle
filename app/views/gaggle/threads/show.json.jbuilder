json.thread_name @thread.name
json.messages do
  @thread.messages.each do |message|
    json.child! do
      json.content message.content
      json.user_name message.user_name
    end
  end
end
