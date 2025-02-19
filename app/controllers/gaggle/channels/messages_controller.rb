module Gaggle
  class Channels::MessagesController < Gaggle::ChannelsController
    skip_before_action :verify_authenticity_token

    def create
      @message = @channel.messages.new(message_params)
      if @message.save
        redirect_to @channel, notice: "Message sent."
      else
        render :new, notice: "Message was not sent."
      end
    end

    private

    def message_params
      params.require(:message).permit(:content, :goose_id)
    end
  end
end
