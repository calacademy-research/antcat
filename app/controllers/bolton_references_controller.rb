# coding: UTF-8
class BoltonReferencesController < ApplicationController

  def index
    @references = Bolton::Reference.do_search params
  end

end
