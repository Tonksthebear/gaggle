json.array! @channels do |channel|
  json.(channel, :id, :name, :goose_ids)
end
