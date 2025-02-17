json.threads do
  @threads.each do |thread|
    json.name thread.name
    json.id thread.id
  end
end
