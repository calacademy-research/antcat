# frozen_string_literal: true

require Rails.root.join('lib/read_end_data')

module DatabaseScripts
  class EndDataAttributes
    attr_private_initialize :script_path

    def title
      end_data[:title]&.html_safe
    end

    def section
      end_data[:section] || DatabaseScript::UNGROUPED_SECTION
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
      (end_data[:related_scripts] || []).map do |class_name|
        DatabaseScript.safe_new_from_filename_without_extension class_name
      end
    end

    private

      def end_data
        @_end_data ||= ReadEndData.new(script_path).call.deep_symbolize_keys
      end
  end
end
