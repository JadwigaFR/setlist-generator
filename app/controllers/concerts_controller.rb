class ConcertsController < ApplicationController
  before_action :current_concert, only: [:show, :edit, :update, :destroy]

  def index
    @concerts = Concert.all
  end

  def show
    @concert = Concert.find(params[:id])
  end

  def new
    @concert = Concert.new
  end

  def create
    @concert = Concert.create(concert_params)

    redirect_to concert_path
  end

  def edit

  end

  def update
    @concert.update(concert_params)

    redirect_to concert_path(@concert)
  end

  def delete
    @concert.destroy

    redirect_to concert_path
  end

  private

  def concert_params
    params.require(:concert).permit(:venue_id, :artist_id, :date)
  end

  def current_concert
    @concert = Concert.find(params[:id])
  end
end
