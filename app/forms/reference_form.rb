# frozen_string_literal: true

class ReferenceForm
  POSSIBLE_DUPLICATE_ERROR_KEY = :possible_duplicate # HACK: To get rid of other hack.

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

        # Set attributes to make sure they're persisted in the form.
        reference.attributes = params

        # Raise if there are errors -- #save! clears the errors
        # before validating, so we need to manually raise here.
        raise ActiveRecord::Rollback if reference.errors.present?

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
        reference.errors.add :author_names_string, "couldn't be parsed."
        reference.author_names_string_cache = string
        raise ActiveRecord::RecordInvalid, reference
      end

      # TODO: Clearing author names creates more `PaperTrail::Version` than needed, but
      # `reference_author_names.position` was not being reset when this was removed. See specs.
      reference.author_names.clear
      params[:author_names] = author_names
    end

    def set_journal
      journal_name = params[:journal_name]

      # Set journal_name for the form.
      reference.journal_name = journal_name

      # Set nil or valid publisher in the params.
      journal = Journal.find_or_initialize_by(name: journal_name)
      params[:journal] = journal.valid? ? journal : nil
    end

    def set_publisher
      publisher_string = params[:publisher_string]

      # Set publisher_string for the form.
      reference.publisher_string = publisher_string

      # Add error or set valid publisher in the params.
      publisher = Publisher.find_or_initialize_from_string(publisher_string)
      if publisher.nil? && publisher_string.present?
        reference.errors.add :publisher_string,
          "couldn't be parsed. In general, use the format 'Place: Publisher'."
      else
        params[:publisher] = publisher
      end
    end

    def check_for_duplicates!
      duplicates = References::FindDuplicates[reference, min_similarity: 0.5]
      return if duplicates.blank?

      duplicate = Reference.find(duplicates.first[:match].id)
      reference.errors.add POSSIBLE_DUPLICATE_ERROR_KEY, <<~MSG.html_safe
        This may be a duplicate of #{duplicate.keey} (##{duplicate.id}).<br>
        To save, click "Save".
      MSG
      true
    end
end
