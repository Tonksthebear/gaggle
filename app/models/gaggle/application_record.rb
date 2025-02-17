module Gaggle
  class ApplicationRecord < ActiveRecord::Base
    include ActionView::RecordIdentifier
    self.abstract_class =true
    connects_to database: { writing: :gaggle, reading: :gaggle }
  end
end
