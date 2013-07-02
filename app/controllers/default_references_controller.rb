# coding: UTF-8
class DefaultReferencesController < ApplicationController

  def update
    DefaultReference.set session, Reference.find(params[:id])
    render nothing: true
  end

end
