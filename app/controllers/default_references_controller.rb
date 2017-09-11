# TODO namespace under `References`.

class DefaultReferencesController < ApplicationController
  def update
    DefaultReference.set session, Reference.find(params[:id])
    if request.xhr?
      render nothing: true
    else
      redirect_to :back
    end
  end
end
