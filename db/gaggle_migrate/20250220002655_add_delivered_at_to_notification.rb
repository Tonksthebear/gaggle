class AddDeliveredAtToNotification < ActiveRecord::Migration[7.2]
  def change
    add_column :gaggle_notifications, :delivered_at, :datetime
  end
end
