# frozen_string_literal: true

module EditorsPanels
  class RestartAndReindexSolrsController < ApplicationController
    before_action :ensure_user_is_superadmin

    def create
      RestartAndReindexSolr[]

      redirect_to editors_panel_path,
        notice: 'Solr is being restarted and reindexed in the background. It may take a minute or two.'
    end
  end
end
