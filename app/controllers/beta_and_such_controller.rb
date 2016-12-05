class BetaAndSuchController < ApplicationController
  before_action :authenticate_superadmin

  def all_versions
    @versions = PaperTrail::Version.paginate(page: params[:page], per_page: 50)
    @version_count = PaperTrail::Version.count
  end

  def show_version
    @version = PaperTrail::Version.find params[:id]
  end
end
