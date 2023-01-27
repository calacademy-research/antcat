# frozen_string_literal: true

module Operations
  class CreateNewCombination
    include Operation

    attr_private_initialize [:current_taxon, :new_genus, :target_name_string]

    def self.description current_taxon:, new_combination_name:, new_genus:
      preview_new_taxon = PreviewString.new(new_combination_name + ' **[NEW TAXON]**')
      preview_existing_taxon = PreviewTaxon.new(current_taxon)
      preview_new_genus = PreviewTaxon.new(new_genus)

      [
        "##### Operation: `CreateNewCombinationRecord`",
        CreateNewCombinationRecord.description(
          current_taxon: preview_existing_taxon,
          new_genus: preview_new_genus,
          target_name_string: preview_new_taxon
        ),

        "##### Operation: `ConvertToObsoleteCombination`",
        ConvertToObsoleteCombination.description(
          current_taxon: preview_existing_taxon,
          new_combination: preview_new_taxon
        )
      ].join("\n")
    end

    def execute
      new_combination = Operations::CreateNewCombinationRecord.new(
        current_taxon: current_taxon,
        new_genus: new_genus,
        target_name_string: target_name_string
      ).run(context).results.new_combination
      results.new_combination = new_combination

      Operations::ConvertToObsoleteCombination.new(
        current_taxon: current_taxon,
        new_combination: new_combination
      ).run(context)
    end

    class PreviewTaxon < SimpleDelegator
      def to_s
        CatalogFormatter.link_to_taxon(__getobj__)
      end
    end

    class PreviewString
      attr_private_initialize :string

      def to_s
        string
      end

      def method_missing name, *_args, &_block
        "missing - #{name}" || super
      end

      def respond_to_missing? _name, *_args
        super
      end
    end
  end
end
