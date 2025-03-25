module Gaggle
  class Task < ApplicationRecord
    self.table_name = "gaggle_tasks"

    belongs_to :assigned_goose, class_name: "Gaggle::Goose", optional: true

    validates :title, presence: true
    validates :status, presence: true

    enum status: { todo: 0, in_progress: 1, done: 2 }
  end
end
