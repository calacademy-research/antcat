class Taxa::Utility
  include UndoTracker

  def initialize taxon
    @taxon = taxon
  end

  def delete_impact_list
    get_taxon_children_recur(@taxon).concat([@taxon])
  end

  def delete_taxon_and_children
    Taxon.transaction do
      change = setup_change :delete
      delete_taxon_children @taxon

      @taxon.delete_with_state!
      change.user_changed_taxon_id = @taxon.id
    end
  end

  private
    def get_taxon_children_recur taxon
      ret_val = []
      taxon.children.each do |c|
        ret_val.concat [c]
        ret_val.concat get_taxon_children_recur c
      end
      ret_val
    end

    def delete_taxon_children taxon
      taxon.children.each do |c|
        c.delete_with_state!
        delete_taxon_children c
      end
    end
end
