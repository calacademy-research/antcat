# NOTE: This service mutates `params`, but that's OK for now.

class ReferenceForm
  def initialize reference, reference_params, original_params, request_host
    @reference = reference
    @params = reference_params
    @original_params = original_params
    @request_host = request_host
  end

  def save
    save_reference
  end

  private

    attr_reader :reference, :params, :original_params, :request_host

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

        if original_params[:ignore_possible_duplicate].blank?
          if check_for_duplicates!
            original_params[:ignore_possible_duplicate] = "yes"
            raise ActiveRecord::Rollback
          end
        end

        reference.save!
        set_document_host

        return true
      end
    rescue ActiveRecord::RecordInvalid
      false
    end

    def set_document_host
      return unless reference.document
      reference.document.host = request_host
    end

    def parse_author_names_string
      string = params.delete(:author_names_string)
      return if string.strip == reference.author_names_string

      author_names = Authors::FindOrCreateNamesFromString[string.dup]

      if author_names.empty? && string.present?
        reference.errors.add :author_names_string, "couldn't be parsed."
        reference.author_names_string_cache = string
        raise ActiveRecord::RecordInvalid, reference
      end

      reference.author_names.clear
      params[:author_names] = author_names
    end

    def set_journal
      journal_name = params[:journal_name]

      # Set journal_name for the form.
      reference.journal_name = journal_name

      # Set nil or valid publisher in the params.
      journal = Journal.find_or_create_by(name: journal_name)
      params[:journal] = journal.valid? ? journal : nil
    end

    def set_publisher
      publisher_string = params[:publisher_string]

      # Set publisher_string for the form.
      reference.publisher_string = publisher_string

      # Add error or set valid publisher in the params.
      publisher = Publisher.create_from_string publisher_string
      if publisher.nil? && publisher_string.present?
        reference.errors.add :publisher_string,
          "couldn't be parsed. In general, use the format 'Place: Publisher'."
      else
        params[:publisher] = publisher
      end
    end

    def clear_document_params_if_necessary
      return unless params[:document_attributes]
      return if params[:document_attributes][:url].blank?
      params[:document_attributes][:id] = nil
    end

    def check_for_duplicates!
      duplicates = References::FindDuplicates[reference, min_similarity: 0.5]
      return if duplicates.blank?

      duplicate = Reference.find(duplicates.first[:match].id)
      reference.errors.add :base, <<~MSG.html_safe
        This may be a duplicate of #{duplicate.keey} (##{duplicate.id}).<br>
        To save, click "Save".
      MSG
      true
    end
end
