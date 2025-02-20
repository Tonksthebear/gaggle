module Gaggle
  class Message < ApplicationRecord
    require "set"

    self.table_name = "gaggle_messages"

    belongs_to :messageable, polymorphic: true
    belongs_to :goose, class_name: "Gaggle::Goose", optional: true

    has_many :notifications, class_name: "Gaggle::Notification", dependent: :destroy

    validates :content, presence: true

    after_create_commit :generate_notifications
    after_create_commit :broadcast_create
    after_create_commit :associate_goose, if: -> { goose_id.present? && messageable_type == 'Gaggle::Channel' }

    scope :later_than, ->(time = 0) { where(created_at: time..) }

    def user_name
      goose&.name || "Human"
    end

    private

    def generate_notifications
      goose_to_notify = case messageable
      when Gaggle::Channel
        messageable.gooses.where.not(id: goose_id)
      when Gaggle::Goose
        Array.wrap(messageable)
      end


      # Find @mentions in the message content.
      # This regex captures sequences starting with '@' followed by word characters.
      content.scan(/@([\w]+)/).flatten.each do |mentioned_name|
        goose_mentioned = Gaggle::Goose.find_by(name: mentioned_name)
        goose_to_notify << goose_mentioned if goose_mentioned
      end

      # Create notifications for each unique goose.
      goose_to_notify.each do |goose|
        notification = Gaggle::Notification.create(message: self, goose:, messageable:)
        notification.save || notification.notify_goose
      end
    end

    def broadcast_create
      broadcast_prepend_to messageable, target: "messages"
    end

    def associate_goose
      goose.channels << self.messageable
    end
  end
end