module Gaggle
  class ApplicationController < ActionController::Base
    before_action :set_threads
    before_action :set_geese

    private

    def set_threads
      @threads = Gaggle::Thread.all
    end

    def set_geese
      @geese = Gaggle::Goose.all
    end
  end
end
