class Taxa::Utility

  def initialize taxon
    @taxon = taxon
  end

  def delete_impact_list
    get_taxon_children_recur(@taxon).concat([@taxon])
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

end
