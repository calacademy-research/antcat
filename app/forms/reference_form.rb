# frozen_string_literal: true

class ReferenceForm
  include ActiveModel::Model

  POSSIBLE_DUPLICATE_ERROR_KEY = :possible_duplicate # HACK: To get rid of other hack.
  VIRTUAL_ATTRIBUTES = [:journal_name, :publisher_string]

  attr_private_initialize :reference, :params, [ignore_duplicates: false]

  def save
    save_reference
  end

  private

    def save_reference
      Reference.transaction do
        clear_document_params_if_necessary
        parse_author_names_string
        set_journal if reference.is_a? ::ArticleReference
        set_publisher if reference.is_a? ::BookReference

        reference.attributes = params.except(*VIRTUAL_ATTRIBUTES)

        # Raise if there are errors, since `#save!` clears errors before validating.
        raise ActiveRecord::Rollback if errors.present?

        unless ignore_duplicates
          if check_for_duplicates!
            raise ActiveRecord::Rollback
          end
        end

        reference.save!

        return true
      end
    rescue ActiveRecord::RecordInvalid
      false
    end

    def clear_document_params_if_necessary
      return unless params[:document_attributes]

      # TODO: Make sure documents have either a `file_file_name` or a `url`.
      # We cannot conditionally clear them before fixing current `ReferenceDocument`s.
      if params[:document_attributes][:file].present?
        params[:document_attributes][:url] = "" # Probably nil, but most are blank string right now.
      end
    end

    def parse_author_names_string
      string = params.delete(:author_names_string)
      return if string.strip == reference.author_names_string

      author_names = Authors::FindOrInitializeNamesFromString[string.dup]

      if author_names.empty? && string.present?
        errors.add :author_names_string, "couldn't be parsed."
        reference.author_names_string_cache = string
        raise ActiveRecord::RecordInvalid, reference
      end

      # TODO: Clearing author names creates more `PaperTrail::Version` than needed, but
      # `reference_author_names.position` was not being reset when this was removed. See specs.
      reference.author_names.clear
      params[:author_names] = author_names
    end

    def set_journal
      journal = Journal.find_or_initialize_by(name: params[:journal_name])
      reference.journal = journal

      if journal.invalid?
        errors.add "Journal:", journal.errors.full_messages.to_sentence
      end
    end

    def set_publisher
      place_and_name = Publisher.place_and_name_from_string(params[:publisher_string])
      publisher = Publisher.find_or_initialize_by(place_and_name)
      reference.publisher = publisher

      if publisher.invalid?
        errors.add :publisher_string, "couldn't be parsed. In general, use the format 'Place: Publisher'."
      end
    end

    def check_for_duplicates!
      return if (duplicates = References::FindDuplicates[reference]).empty?

      duplicate = Reference.find(duplicates.first[:match].id)
      errors.add POSSIBLE_DUPLICATE_ERROR_KEY, <<~MSG.html_safe
        This may be a duplicate of #{duplicate.keey} (##{duplicate.id}).<br>
        To save, click "Save".
      MSG
      true
    end
end
