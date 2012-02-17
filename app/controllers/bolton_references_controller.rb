# coding: UTF-8
class BoltonReferencesController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]

  def index
    unless params[:match_status_auto].present? ||
           params[:match_status_manual].present? ||
           params[:match_status_none].present? ||
           params[:match_status_unmatchable].present?
      params[:match_status_auto] =
      params[:match_status_manual] =
      params[:match_status_none] =
      params[:match_status_unmatchable] =
        true
    end

    match_statuses = []
    match_statuses << nil if params[:match_status_none].present?
    match_statuses << 'auto' if params[:match_status_auto].present?
    match_statuses << 'manual' if params[:match_status_manual].present?
    match_statuses << 'unmatchable' if params[:match_status_unmatchable].present?

    @references = Bolton::Reference.do_search params.merge :match_statuses => match_statuses
  end

  def update
    @bolton_reference = Bolton::Reference.find params[:id]
    @bolton_reference.set_match_manually params[:match]
    respond_to {|format| format.js}
  end

end
