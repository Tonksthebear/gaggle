module Gaggle
  class Channels::GoosesController < Gaggle::ChannelsController
    def edit
      @gooses = Goose.all
    end

    # def update
    #   super
    # end
  end
end
