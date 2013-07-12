# coding: UTF-8
class DefaultReferencesController < ApplicationController

  def update
    DefaultReference.set session, Reference.find(params[:id])
    if request.xhr?
      render nothing: true
    else
      redirect_to '/references?commit=new'
    end
  end

end
