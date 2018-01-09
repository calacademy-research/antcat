module EditorsPanels
  class VersionsController < ApplicationController
    include HasWhereFilters

    before_action :authenticate_editor

    has_filters(
      whodunnit: {
        tag: :select_tag,
        options: -> { User.order(:name).pluck(:name, :id) }
      },
      item_type: {
        tag: :select_tag,
        options: -> { PaperTrail::Version.distinct.pluck(:item_type) - ["User"] }
      },
      item_id: {
        tag: :number_field_tag
      },
      event: {
        tag: :select_tag,
        options: -> { PaperTrail::Version.distinct.pluck(:event) }
      },
      change_id: {
        tag: :number_field_tag
      }
    )

    def index
      @versions = PaperTrail::Version.without_user_versions
      @versions = @versions.filter(filter_params)
      @versions = @versions.search_objects(search_params) if params[:q].present?
      @versions = @versions.order(:id).paginate(page: params[:page], per_page: 50)

      @version_count = PaperTrail::Version.count
    end

    def show
      @version = PaperTrail::Version.without_user_versions.find params[:id]
    end

    private
      def search_params
        params.slice :search_type, :q
      end
  end
end
