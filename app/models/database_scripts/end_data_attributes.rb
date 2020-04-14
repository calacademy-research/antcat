# frozen_string_literal: true

require Rails.root.join('lib/read_end_data')

module DatabaseScripts
  class EndDataAttributes
    attr_private_initialize :filename_without_extension

    def title
      end_data[:title]&.html_safe || filename_without_extension.humanize(keep_id_suffix: true)
    end

    def section
      end_data[:section] || DatabaseScripts::Tagging::UNGROUPED_SECTION
    end

    def category
      end_data[:category] || ""
    end

    def tags
      end_data[:tags] || []
    end

    def issue_description
      end_data[:issue_description]
    end

    def description
      end_data[:description] || ""
    end

    def related_scripts
      (end_data[:related_scripts] || []).
        map { |class_name| DatabaseScript.safe_new_from_filename(class_name) }.
        reject { |database_script| database_script.filename_without_extension == filename_without_extension }
    end

    private

      def end_data
        @_end_data ||= ReadEndData.new(script_path).call.deep_symbolize_keys
      end

      def script_path
        "#{DatabaseScript::SCRIPTS_DIR}/#{filename_without_extension}.rb"
      end
  end
end
