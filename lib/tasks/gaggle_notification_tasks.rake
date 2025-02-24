# lib/tasks/gaggle.rake
namespace :gaggle do
  desc <<-DESC
  Retrieves all notifications for a specific Goose
  To use: bin/rails gaggle:get_goose_notifications
  DESC

  task get_goose_notifications: :environment do
    goose_id = ENV["GOOSE_ID"]

    if goose_id.blank?
      puts "Error: Goose ID is required."
    else
      begin
        goose = Gaggle::Goose.find(goose_id)
        notifications = goose.notifications.unread.map do |notification|
          { id: notification.id, message_id: notification.message.id, read_at: notification.read_at }
        end
        puts JSON.generate(notifications)
      rescue ActiveRecord::RecordNotFound
        puts "Error: Goose with ID #{goose_id} not found."
      rescue => e
        STDERR.puts "Unexpected error: #{e.message}" # Debug
      end
    end
  end
end
