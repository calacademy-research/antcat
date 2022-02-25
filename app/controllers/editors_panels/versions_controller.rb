# frozen_string_literal: true

module EditorsPanels
  class VersionsController < ApplicationController
    FILTER_ITEM_TYPES = %w[
      Activity
      Author
      AuthorName
      Citation
      Comment
      Feedback
      HistoryItem
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
      Taxon
      Tooltip
      TypeName
      WikiPage
    ]

    before_action :ensure_user_is_editor

    def index
      @versions = base_scope
      @versions = @versions.filter_where(filter_params)
      @versions = @versions.search(params[:q], params[:search_type]) if params[:q].present?
      @versions = @versions.order(:id).paginate(page: params[:page], per_page: 50)

      # HACK: Workaround for `WillPaginate::ActiveRecord::RelationMethods#first`,
      # https://github.com/mislav/will_paginate/blob/e8013db0d4394ce4e2b64e817d96824a6109055f/lib/will_paginate/active_record.rb#L43
      @versions.load
      @first_version = @versions[0] # Because `@versions.first` triggers the query an additional time.
      @last_version = @versions.last

      @total_versions_count = base_scope.count
    end

    def show
      @version = base_scope.find(params[:id])
    end

    private

      def filter_params
        params.permit(:event, :item_id, :item_type, :request_uuid, :whodunnit)
      end

      def base_scope
        PaperTrail::Version.base_scope
      end
  end
end
