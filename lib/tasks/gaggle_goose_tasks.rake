namespace :gaggle do
  desc <<-DESC
    Gets a list of all gooses and their associated ids in JSON format
    To use: bin/rails gaggle:goose_list [goose_id=<id>]
  DESC

  task goose_list: :environment do
    goose_id = ENV["goose_id"]

    gooses = Gaggle::Goose.where.not(id: goose_id).map do |goose|
      {
        id: goose.id,
        name: goose.name
      }
    end

    puts gooses.to_json
  end
end
