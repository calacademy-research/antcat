# frozen_string_literal: true

module Operations
  class CreateNewCombinationRecord
    include Operation

    def initialize current_valid_taxon:, new_genus:, target_name_string:
      @current_valid_taxon = current_valid_taxon
      @new_genus = new_genus
      @target_name_string = target_name_string
    end

    def self.description current_valid_taxon:, new_genus:, target_name_string:
      <<~TEXT
        * Create a new species record: #{target_name_string}
          * Status: #{Status::VALID}
          * Parent: #{new_genus}
          * Protonym: #{current_valid_taxon.protonym.decorate.link_to_protonym}
      TEXT
    end

    def execute
      raise unless current_valid_taxon.policy.allow_create_combination?

      new_combination = build_new_combination

      if Taxon.name_clash?(new_combination.name.name)
        fail! "#{new_combination.name.name} - This name is in use by another taxon"
      end

      results.new_combination = new_combination

      unless new_combination.save
        fail! new_combination.errors.full_messages.to_sentence
      end
    end

    private

      attr_reader :current_valid_taxon, :new_genus, :target_name_string

      def build_new_combination
        new_combination = Species.new
        new_combination.name = Names::BuildNameFromString[target_name_string]
        new_combination.protonym = current_valid_taxon.protonym
        new_combination.parent = new_genus
        new_combination.status = Status::VALID

        new_combination
      end
  end
end
