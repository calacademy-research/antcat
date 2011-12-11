# coding: UTF-8
class BoltonReferencesController < ApplicationController

  def index
    params[:match_status_none] = params[:match_status_auto] = true unless
      params[:match_status_none].present? or params[:match_status_auto].present?

    match_statuses = []
    match_statuses << nil if params[:match_status_none].present?
    match_statuses << 'auto' if params[:match_status_auto].present?

    @references = Bolton::Reference.do_search params.merge :match_statuses => match_statuses
  end

  def update
    @bolton_reference = Bolton::Reference.find params[:id]
    @bolton_reference.set_match_manually ::Reference.find(params[:match])
    respond_to {|format| format.js}
  end

end
