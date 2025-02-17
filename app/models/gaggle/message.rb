module Gaggle
  class Message < ApplicationRecord
    require "set"

    self.table_name = "gaggle_messages"

    belongs_to :thread, class_name: "Gaggle::Thread", foreign_key: "gaggle_thread_id"
    belongs_to :goose, class_name: "Gaggle::Goose", foreign_key: "gaggle_goose_id", optional: true

    has_many :notifications, class_name: "Gaggle::Notification", foreign_key: "gaggle_message_id", dependent: :destroy

    validates :content, presence: true

    after_create :generate_notifications

    def user_name
      goose&.name || "User"
    end

    private

    def generate_notifications
      notified_goose_ids = Set.new

      # If the message is sent by the user (no goose associated),
      # notify all geese that have previously participated in this thread.
      if goose.nil?
        participant_ids = thread.messages.where.not(gaggle_goose_id: nil).pluck(:gaggle_goose_id).uniq
        notified_goose_ids.merge(participant_ids)
      end

      # Find @mentions in the message content.
      # This regex captures sequences starting with '@' followed by word characters.
      content.scan(/@([\w]+)/).flatten.each do |mentioned_name|
        goose_mentioned = Gaggle::Goose.find_by(name: mentioned_name)
        notified_goose_ids.add(goose_mentioned.id) if goose_mentioned
      end

      # Create notifications for each unique goose.
      notified_goose_ids.each do |g_id|
        Gaggle::Notification.create!(gaggle_message: self, gaggle_goose_id: g_id)
      end
    end
  end
end
