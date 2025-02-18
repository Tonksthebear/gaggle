module Gaggle
  class Threads::MessagesController < Gaggle::ThreadsController
    skip_before_action :verify_authenticity_token

    def create
      @message = @thread.messages.new(message_params)
      if @message.save
        redirect_to @thread, notice: "Message sent."
      else
        raise "HIT:::#{@message.errors.full_messages}:::#{@message.attributes}"
        render :new, notice: "Message was not sent."
      end
    end

    private

    def message_params
      params.require(:message).permit(:content, :goose_id)
    end
  end
end
