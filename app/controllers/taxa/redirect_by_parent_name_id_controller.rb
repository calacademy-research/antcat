module Taxa
  class RedirectByParentNameIdController < ApplicationController
    def index
      if parent
        redirect_to new_taxa_path(
          parent_id: parent.id,
          rank_to_create: params[:rank_to_create],
          previous_combination_id: params[:previous_combination_id],
          collision_resolution: params[:collision_resolution]
        )
      else
        render plain: <<~MESSAGE
          Something went wrong.

          params: #{params}
        MESSAGE
      end
    end

    private

      def parent
        @parent ||= Taxon.find_by(name_id: params[:parent_name_id])
      end
  end
end
