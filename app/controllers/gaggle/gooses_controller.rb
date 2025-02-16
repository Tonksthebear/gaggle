module Gaggle
  class GoosesController < ApplicationController
    before_action :set_goose

    def show; end

    def new; end

    def create
      @goose.assign_attributes(goose_params)
      if @goose.save
        redirect_to @goose, notice: "Goose was successfully created."
      else
        render :new
      end
    end

    def edit; end

    def update
      if @goose.update(goose_params)
        redirect_to @goose, notice: "Goose was successfully updated."
      else
        render :edit
      end
    end

    def destroy
      @goose.destroy
      redirect_to root_url, notice: "Goose was successfully destroyed."
    end

    private

    def set_goose
      @goose = Goose.find_by(id: params[:id]) || Goose.new
    end

    def goose_params
      params.require(:goose).permit(:name, :prompt)
    end
  end
end
