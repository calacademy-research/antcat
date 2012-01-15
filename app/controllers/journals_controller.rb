# coding: UTF-8
class JournalsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_journal, only: [:edit, :update]

  def index
    respond_to do |format|
      format.html {@journals = Journal.list}
      format.json {render json: Journal.search(params[:term]).to_json}
    end
  end

  def new
    @journal = Journal.new
  end

  def create
    @journal = Journal.new(params[:journal])
    if @journal.save
      flash[:notice] = "Successfully created journal."
      render :edit
    else
      render :new
    end
  end

  def update
    if @journal.update_attributes(params[:journal])
      flash[:notice] = "Successfully updated journal."
    end
    render :edit, journal: @journal
  end

  private
  def find_journal
    @journal = Journal.find(params[:id])
  end

end
