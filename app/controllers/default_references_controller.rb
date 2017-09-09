class DefaultReferencesController < ApplicationController
  def update
    DefaultReference.set session, Reference.find(params[:id])
    if request.xhr?
      render nothing: true
    else
      redirect_to references_latest_additions_path
    end
  end
end
