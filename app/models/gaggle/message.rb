module Gaggle
  class Message < ApplicationRecord
    require "set"

    self.table_name = "gaggle_messages"

    belongs_to :thread, class_name: "Gaggle::Thread"
    belongs_to :goose, class_name: "Gaggle::Goose", optional: true

    has_many :notifications, class_name: "Gaggle::Notification", dependent: :destroy

    validates :content, presence: true

    after_create_commit :generate_notifications
    after_create_commit :broadcast_create

    def user_name
      goose&.name || "User"
    end

    private

    def generate_notifications
      goose_to_notify = thread.messages.joins(:goose).where.not(goose_id: goose_id).map(&:goose).uniq


      # Find @mentions in the message content.
      # This regex captures sequences starting with '@' followed by word characters.
      content.scan(/@([\w]+)/).flatten.each do |mentioned_name|
        goose_mentioned = Gaggle::Goose.find_by(name: mentioned_name)
        goose_to_notify << goose_mentioned if goose_mentioned
      end

      # Create notifications for each unique goose.
      goose_to_notify.each do |goose|
        Gaggle::Notification.create!(message: self, goose: goose)
      end
    end

    def broadcast_create
      broadcast_prepend_to thread, target: "messages"
    end
  end
end
