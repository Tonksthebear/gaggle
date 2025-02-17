module Gaggle
  class Gooses::SessionsController < SessionsController
    before_action :set_goose

    def index
      @sessions = @goose.sessions
    end

    def create
      session = @goose.sessions.create!
      session.start_executable
      sleep 1.seconds
      session.write_to_executable(@goose.interaction_prompt)# + @goose.begin_prompt)
      redirect_to session
    end

    private

    def set_goose
      @goose = Gaggle::Goose.find(params[:goose_id])
    end
  end
end
