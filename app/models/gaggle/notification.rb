module Gaggle
  class Notification < ApplicationRecord
    self.table_name = "gaggle_notifications"

    belongs_to :message, class_name: "Gaggle::Message"
    belongs_to :messageable, polymorphic: true
    belongs_to :goose, class_name: "Gaggle::Goose", optional: true

    validates :read_at, uniqueness: { scope: [ :messageable_id, :messageable_type, :goose_id ] }

    after_create_commit :notify_goose, if: -> { goose.present? }

    def notify_goose
      update(delivered_at: Time.current)
      goose.notify_of_message(notification: self)
    end

    def mark_read!
      update(read_at: Time.current)
    end

    def unread_messageable
      messages = case messageable
      when Gaggle::Channel
          messageable.messages.where(created_at: created_at..)
      when Gaggle::Goose
          messageable.messages.where(created_at: created_at..)
      end
      mark_read!
      messages
    end

    class << self
      def messageables
        preload(:messageable).map(&:messageable)
      end

      def unread
        where(read_at: nil)
      end

      def for_messageable(messageable)
        where(messageable_id: messageable.id, messageable_type: messageable.class)
      end
    end
  end
end
