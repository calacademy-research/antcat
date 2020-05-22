# frozen_string_literal: true

class TaxonForm
  include ActiveModel::Model

  attr_private_initialize :taxon, :params, [:taxon_name_string, :protonym_name_string]

  validate :validate_children

  def save
    protonym_attributes = params.delete(:protonym_attributes)

    if taxon.new_record?
      taxon.name = build_name taxon_name_string

      if params[:protonym_id].blank?
        self.protonym_form = ProtonymForm.new(taxon.protonym, protonym_attributes, protonym_name_string: protonym_name_string)
      end
    end

    taxon.attributes = params

    return false if invalid?
    persist!
  end

  private

    attr_accessor :protonym_form

    def persist!
      ActiveRecord::Base.transaction do
        protonym_form&.save!
        taxon.save!
      end
    end

    def promote_errors child_errors, error_prefix = ''
      child_errors.full_messages.each do |full_message|
        errors.add(:base, "#{error_prefix}#{full_message}")
      end
    end

    def validate_children
      # TODO: Fix.
      # HACK: Promote before getting cleared in `#invalid?`.
      if taxon.name.errors.present?
        promote_errors(taxon.name.errors, "Name: ")
      end

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

    def build_name name_string
      Names::BuildNameFromString[name_string]
    rescue Names::BuildNameFromString::UnparsableName => e
      name = Name.new(name: name_string)
      name.errors.add :base, "Could not parse name #{e.message}"
      name
    end
end
