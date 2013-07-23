class ChangesController < ApplicationController

  def index
    @changes = Change.creations.paginate page: params[:page]
  end

end
