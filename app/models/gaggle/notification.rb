module Gaggle
  class Notification < ApplicationRecord
    self.table_name = "gaggle_notifications"

    belongs_to :message, class_name: "Gaggle::Message"
    belongs_to :goose, class_name: "Gaggle::Goose", optional: true

    after_create_commit :notify_goose, if: -> { goose.present? }

    def notify_goose
      update(read_at: Time.current) if goose.notify_of_message(message: message)
    end
  end
end
