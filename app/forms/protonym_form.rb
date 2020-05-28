# frozen_string_literal: true

class ProtonymForm
  include ActiveModel::Model

  ATTRIBUTES = %w[
    biogeographic_region
    fossil
    locality
    sic
    uncertain_locality

    primary_type_information_taxt
    secondary_type_information_taxt
    type_notes_taxt
  ]

  attr_accessor(*ATTRIBUTES)
  attr_reader :protonym

  delegate :id, :persisted?, :authorship, :type_name, to: :protonym

  validate :validate_children

  def self.model_name
    Protonym.model_name
  end

  def initialize protonym, params = {}, form_params = {}
    @protonym = protonym
    @params = params
    @form_params = form_params

    if (protonym_name_string = form_params[:protonym_name_string])
      @protonym.name = build_name protonym_name_string
    end

    super params
  end

  def authorship_attributes= attributes
    protonym.authorship.attributes = attributes
  end

  def type_name_attributes= attributes
    return if protonym.type_name.nil? && type_name_attributes_blank?(attributes)

    protonym.build_type_name unless protonym.type_name
    protonym.type_name.attributes = attributes
  end

  def save
    if valid?
      save!
      true
    else
      false
    end
  end

  def save!
    persist!
  end

  private

    attr_reader :params, :form_params

    def persist!
      ActiveRecord::Base.transaction do
        if destroy_type_name?
          protonym.type_name.destroy!
        elsif protonym.type_name
          protonym.type_name.save!
        end

        protonym.authorship.save!
        protonym.attributes = params.slice(*ATTRIBUTES)
        protonym.save!
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
      if protonym.name.errors.present?
        promote_errors(protonym.name.errors, "Protonym name: ")
      end

      if protonym.name.invalid?
        promote_errors(protonym.name.errors)
      end

      if protonym.authorship.invalid?
        promote_errors(protonym.authorship.errors, "Authorship: ")
      end

      unless destroy_type_name?
        if protonym.type_name&.invalid?
          promote_errors(protonym.type_name.errors, "Type name: ")
        end
      end
    end

    def build_name name_string
      Names::BuildNameFromString[name_string]
    rescue Names::BuildNameFromString::UnparsableName => e
      name = Name.new(name: name_string)
      name.errors.add :base, "Could not parse name #{e.message}"
      name
    end

    def destroy_type_name?
      ActiveModel::Type::Boolean.new.cast(form_params[:destroy_type_name])
    end

    def type_name_attributes_blank? attributes
      attributes.with_indifferent_access.slice(:taxon_id, :fixation_method, :reference_id, :pages).values.reject(&:blank?).blank?
    end
end
