# TODO namespace under `References`.

class DefaultReferencesController < ApplicationController
  before_action :authenticate_editor

  def update
    DefaultReference.set session, Reference.find(params[:id])
    if request.xhr?
      render nothing: true
    else
      redirect_to :back
    end
  end
end
