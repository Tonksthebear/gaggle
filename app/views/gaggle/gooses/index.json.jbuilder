json.key_format! camelize: :lower

json.array! @gooses do |goose|
  json.(goose, :id, :name)
end
