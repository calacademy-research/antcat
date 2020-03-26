# frozen_string_literal: true

module Taxa
  class ChildrenController < ApplicationController
    ALLOW_DELETE_CHILDREN_TYPES = %w[Genus Species]

    before_action :ensure_user_is_editor, only: :destroy

    def show
      @taxon = find_taxon

      @children = @taxon.children.with_common_includes.
        order(status: :desc, name_cache: :asc).
        paginate(per_page: 100, page: params[:page])
      @check_what_links_heres = params[:check_what_links_heres]
    end

    def destroy
      taxon = find_taxon

      unless taxon.type.in?(ALLOW_DELETE_CHILDREN_TYPES)
        redirect_to taxa_children_path(taxon), alert: "Deleting children is only supported for #{ALLOW_DELETE_CHILDREN_TYPES}"
        return
      end

      if taxon.children.any? { |child| child.what_links_here.any? }
        redirect_to taxa_children_path(taxon, check_what_links_heres: 'yes'),
          alert: "Cannot delete children since at least one of them has 'What Links Here's."
        return
      end

      if delete_all_children(taxon)
        redirect_to catalog_path(taxon), notice: "Successfully deleted all children."
      else
        redirect_to catalog_path(taxon.parent), alert: taxon.errors.full_messages.to_sentence
      end
    end

    private

      def find_taxon
        Taxon.find(params[:taxa_id])
      end

      def delete_all_children taxon
        Taxon.transaction do
          taxon.children.each do |child|
            if child.destroy!
              child.create_activity :destroy, current_user, edit_summary: "[automatic]: Deleted child of #{taxon.name.name_html}."
            end
          end
        end
      end
  end
end
