module Gaggle
  class SessionsController < ApplicationController
    before_action :set_session, only: [ :show, :update, :destroy ]

    def show; end

    def update
      @session.write_to_executable(session_params[:input])
      redirect_to @session
    end

    def destroy
      @session.stop_executable
      redirect_to @session
    end

    private

    def set_session
      @session = Gaggle::Session.find(params[:id])
    end

    def session_params
      params.require(:session).permit(:input)
    end
  end
end
