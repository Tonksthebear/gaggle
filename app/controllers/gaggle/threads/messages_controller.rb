module Gaggle
  class Threads::MessagesController < Gaggle::ThreadsController
    skip_before_action :verify_authenticity_token

    def create
      @message = @thread.messages.new(message_params)
      if @message.save

        respond_to do |format|
          format.html { redirect_to @thread, notice: "Message sent." }
          format.json { response :success }
        end
      else
        respond_to do |format|
          format.html { render :new, notice: "Message was not sent." }
          format.json { response :error }
        end
      end
    end

    private

    def message_params
      params.require(:message).permit(:content, :goose_id)
    end
  end
end
