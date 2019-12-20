module EditorsPanels
  class VersionsController < ApplicationController
    include HasWhereFilters

    FILTER_ITEM_TYPES = %w[
      Activity
      Author
      AuthorName
      Citation
      Comment
      Feedback
      Institution
      Issue
      Journal
      Name
      Place
      Protonym
      Publisher
      Reference
      ReferenceAuthorName
      ReferenceDocument
      ReferenceSection
      SiteNotice
      Synonym
      Taxon
      TaxonHistoryItem
      TaxonState
      Tooltip
      WikiPage
    ]

    before_action :ensure_user_is_editor

    has_filters(
      whodunnit: {
        tag: :select_tag,
        options: -> { User.order(:name).pluck(:name, :id) }
      },
      item_type: {
        tag: :select_tag,
        options: -> { FILTER_ITEM_TYPES }
      },
      item_id: {
        tag: :number_field_tag
      },
      event: {
        tag: :select_tag,
        options: -> { %w[create destroy update] }
      },
      change_id: {
        tag: :number_field_tag
      }
    )

    def index
      @versions = PaperTrail::Version.without_user_versions
      @versions = @versions.filter(filter_params)
      @versions = @versions.search(params[:q], params[:search_type]) if params[:q].present?
      @versions = @versions.order(:id).paginate(page: params[:page], per_page: 50)

      @version_count = PaperTrail::Version.count
    end

    def show
      @version = PaperTrail::Version.without_user_versions.find(params[:id])
    end
  end
end
