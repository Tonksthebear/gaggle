class ForceAssociationOnGaggleNotification < ActiveRecord::Migration[8.0]
  def change
    reversible do |dir|
      dir.up do
        # backfill messageable association
        Gaggle::Notification.find_each do |notification|
          notification.update_columns(messageable_type: 'Gaggle::Thread', messageable_id: notification.message.thread_id)
        end
      end
    end

    change_column_null :gaggle_notifications, :messageable_id, false
    change_column_null :gaggle_notifications, :messageable_type, false
  end
end
