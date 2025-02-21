class AddDeliveredAtToNotification < ActiveRecord::Migration[8.0]
  def change
    add_column :gaggle_notifications, :delivered_at, :datetime
  end
end
