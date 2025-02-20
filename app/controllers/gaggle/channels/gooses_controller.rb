module Gaggle
  class Channels::GoosesController < Gaggle::ChannelsController
    before_action :set_goose, except: [ :index ]
    def index
      @gooses = @thread.gooses
    end

    def create
      @goose.channels << @channel
      redirect_to @channel, notice: "Goose was successfully added to channel."
    end

    def destroy
      @goose.channels.delete(@channel)
      redirect_to @channel, notice: "Goose was successfully removed from channel."
    end

    private

    def set_goose
      @goose = Gaggle::Goose.find(goose_params[:id])
    end

    def goose_params
      params.require(:goose).permit(:id)
    end
  end
end
