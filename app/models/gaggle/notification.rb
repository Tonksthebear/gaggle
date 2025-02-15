module Gaggle
  class Notification < ApplicationRecord
    self.table_name = "gaggle_notifications"

    belongs_to :message, class_name: "Gaggle::Message", foreign_key: "gaggle_message_id"
    belongs_to :goose, class_name: "Gaggle::Goose", foreign_key: "gaggle_goose_id", optional: true
  end
end
