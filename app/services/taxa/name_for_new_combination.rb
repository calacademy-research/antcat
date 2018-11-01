module Taxa
  class NameForNewCombination
    include Service

    def initialize old_comb, new_comb_parent
      @old_comb = old_comb
      @new_comb_parent = new_comb_parent
    end

    def call
      raise "uncombinable ranks" unless valid_rank_combination?
      name_for_new_comb
    end

    private

      attr_reader :old_comb, :new_comb_parent

      def name_for_new_comb
        name_parts = [new_comb_parent.name.genus_epithet]
        case new_comb_parent
        when Species then name_parts << new_comb_parent.name.species_epithet <<
          old_comb.name.epithet
        when Genus   then name_parts << old_comb.name.species_epithet
        else                            raise "we should never get here"
        end

        Names::CreateNameFromString[name_parts.join(' ')]
      end

      def valid_rank_combination?
        old_comb.is_a?(Species) && new_comb_parent.is_a?(Genus) ||
          old_comb.is_a?(Subspecies) && new_comb_parent.is_a?(Species)
      end
  end
end
