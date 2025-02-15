module Gaggle
  class OverviewsController < ApplicationController
    def show
      @threads = Gaggle::Thread.all
    end
  end
end
