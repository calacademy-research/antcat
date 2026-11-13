# frozen_string_literal: true

# Restart Solr and reindex the search.
#
# Routes: POST /panel/restart_and_reindex_solrs (superadmins). Purpose, rights and tests of each:
# docs/catalog/routes.tsv.
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
