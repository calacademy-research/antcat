class BetaAndSuchController < ApplicationController
  # Dev only.
  def attempt_to_find_record_by_id
    if Taxon.exists?(params[:id].to_i)
      redirect_to catalog_path(params[:id])
      return
    end

    if Reference.exists?(params[:id].to_i)
      redirect_to reference_path(params[:id])
      return
    end

    render plain: "nope :( did not match any taxon or reference with this id"
  end
end
