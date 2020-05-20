# frozen_string_literal: true

class TaxonForm
  include ActiveModel::Model

  attr_private_initialize :taxon, :params, [:taxon_name_string, :protonym_name_string]

  validate :validate_children

  def save
    save_taxon
  end

  private

    attr_accessor :protonym_form

    def save_taxon
      protonym_attributes = params.delete(:protonym_attributes)

      if taxon.new_record?
        taxon.name = Names::BuildNameFromString[taxon_name_string]

        if params[:protonym_id].blank?
          self.protonym_form = ProtonymForm.new(taxon.protonym, protonym_attributes, protonym_name_string: protonym_name_string)
          protonym_form.save
        end
      end

      taxon.attributes = params

      return false if invalid?
      taxon.save
    end

    def promote_errors child_errors, error_prefix = ''
      child_errors.full_messages.each do |full_message|
        errors.add(:base, "#{error_prefix}#{full_message}")
      end
    end

    def validate_children
      if taxon.invalid?
        promote_errors(taxon.errors)
      end

      if taxon.name.invalid?
        promote_errors(taxon.name.errors, "Name: ")
      end

      if protonym_form&.invalid?
        promote_errors(protonym_form.errors, "Protonym: ")
      end
    end
end
