module EditorsPanels
  class VersionsController < ApplicationController
    before_action :authenticate_superadmin

    def index
      @versions = PaperTrail::Version.paginate(page: params[:page], per_page: 50)
      @version_count = PaperTrail::Version.count
    end

    def show
      @version = PaperTrail::Version.find params[:id]
    end
  end
end