# coding: UTF-8
class BoltonReferencesController < ApplicationController

  def index
    params[:match_type_none] = params[:match_type_auto] = true unless
      params[:match_type_none].present? or params[:match_type_auto].present?

    match_types = []
    match_types << nil if params[:match_type_none].present?
    match_types << 'auto' if params[:match_type_auto].present?

    @references = Bolton::Reference.do_search params.merge :match_types => match_types
  end

end
