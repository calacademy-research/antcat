# TODO namespace under `References`.

class DefaultReferencesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reference, only: :update

  def update
    DefaultReference.set session, @reference

    redirect_back fallback_location: references_path,
      notice: "#{@reference.keey} was successfully set as the default reference."
  end

  private

    def set_reference
      @reference = Reference.find(params[:id])
    end
end
