class ReferencePickersController < ApplicationController
  def show
    reference = Reference.find params[:id] if params[:id].present?

    if params[:q].present?
      params[:q].strip!
      references = Reference.do_search params
    end

    render partial: "reference_#{picker_type}s/show",
      locals: { references: references, reference: reference }
  end
end
