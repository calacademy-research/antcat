module EditorsPanels
  class VersionsController < ApplicationController
    include HasWhereFilters

    before_action :authenticate_superadmin

    has_filters(
      whodunnit: {
        tag: :select_tag,
        options: -> { User.order(:name).pluck(:name, :id) }
      },
      item_type: {
        tag: :select_tag,
        options: -> { PaperTrail::Version.uniq.pluck(:item_type) }
      },
      item_id: {
        tag: :number_field_tag
      },
      event: {
        tag: :select_tag,
        options: -> { PaperTrail::Version.uniq.pluck(:event) }
      }
    )

    def index
      @versions = PaperTrail::Version.filter(filter_params)
      @versions = @versions.paginate(page: params[:page], per_page: 50)

      @version_count = PaperTrail::Version.count
    end

    def show
      @version = PaperTrail::Version.find params[:id]
    end
  end
end
