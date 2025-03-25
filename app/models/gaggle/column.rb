module Gaggle
  class Column < ApplicationRecord
    self.table_name = "gaggle_columns"

    belongs_to :board, class_name: "Gaggle::Board"
    has_many :tasks, class_name: "Gaggle::Task", dependent: :destroy

    validates :name, presence: true
    validates :board_id, presence: true
  end
end
