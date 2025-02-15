module Gaggle
  module Threads
    class MessagesController < ApplicationController
      def new
        render plain: "New message for thread ##{params[:thread_id]}"
      end

      def create
        render plain: "Create message for thread ##{params[:thread_id]}"
      end
    end
  end
end
