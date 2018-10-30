module Taxa
  class InheritAttributesForNewCombination
    include Service

    def initialize new_comb, old_comb, new_comb_parent
      @new_comb = new_comb
      @old_comb = old_comb
      @new_comb_parent = new_comb_parent
    end

    def call
      inherit_attributes_for_new_combination!
      new_comb
    end

    private

      attr_reader :new_comb, :old_comb, :new_comb_parent

      def inherit_attributes_for_new_combination!
        raise "rank mismatch" unless can_inherit_for_new_combination_from?

        new_comb.name = Taxa::NameForNewCombination[old_comb, new_comb_parent]

        new_comb.protonym = old_comb.protonym
        new_comb.biogeographic_region = old_comb.biogeographic_region
      end

      def can_inherit_for_new_combination_from?
        new_comb.rank == old_comb.rank
      end
  end
end
