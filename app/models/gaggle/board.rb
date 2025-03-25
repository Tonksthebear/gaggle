module Gaggle
  class Board < ApplicationRecord
    self.table_name = "gaggle_boards"

    has_many :columns, class_name: "Gaggle::Column", dependent: :destroy

    validates :name, presence: true
  end
end
