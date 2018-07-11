module Taxa
  class DeleteImpactList
    include Service

    def initialize taxon
      @taxon = taxon
    end

    def call
      get_taxon_children_recur(taxon).concat([taxon])
    end

    private
      attr_reader :taxon

      # TODO see `Subfamily#children` for a known bug.
      def get_taxon_children_recur taxon
        ret_val = []
        taxon.children.each do |child|
          ret_val.concat [child]
          ret_val.concat get_taxon_children_recur child
        end
        ret_val
      end
  end
end
