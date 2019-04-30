module Names
  class CheckNameConflictsController < ApplicationController
    def show
      if params[:qq].blank?
        render json: []
      else
        render json: json_names, root: false
      end
    end

    private

      def names
        Names::FindConflicts[params[:qq], params[:number_of_words], params[:except_name_id]]
      end

      def json_names
        names.map do |n|
          {
            id: n.id,
            name: n.name,
            name_html: n.name_html,
            taxon_id: n[:taxon_id],
            protonym_id: n[:protonym_id]
          }
        end
      end
  end
end
