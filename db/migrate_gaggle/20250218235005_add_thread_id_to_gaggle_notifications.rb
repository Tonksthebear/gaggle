class AddThreadIdToGaggleNotifications < ActiveRecord::Migration[6.0]
  def change
    add_reference :gaggle_notifications, :messageable, polymorphic: true, null: true
  end
end
