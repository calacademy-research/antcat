# frozen_string_literal: true

module Names
  class CheckNameConflictsController < ApplicationController
    def show
      if params[:qq].blank?
        render json: []
      else
        render json: serialized_names, root: false
      end
    end

    private

      def serialized_names
        names.map do |name|
          {
            id: name.id,
            name: name.name,
            name_html: name.name_html,
            taxon_id: name[:taxon_id],
            protonym_id: name[:protonym_id]
          }
        end
      end

      def names
        Names::FindConflicts[params[:qq], params[:number_of_words], params[:except_name_id]]
      end
  end
end
