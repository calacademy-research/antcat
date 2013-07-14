class ChangesController < ApplicationController

  def index
    @changes = Change.all
  end

end
