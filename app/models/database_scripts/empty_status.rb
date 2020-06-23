# frozen_string_literal: true

module DatabaseScripts
  class EmptyStatus
    include Service

    NOT_APPLICABLE = 'N/A'

    attr_private_initialize :database_script

    def call
      return database_script.empty_status if database_script.respond_to?(:empty_status)
      return empty_status_string(database_script.empty?) if database_script.respond_to?(:empty?)
      return '??' unless database_script.respond_to?(:results)
      return 'Excluded (slow/list)' if list? || slow?

      empty_status_string database_script.results.empty?
    end

    private

      def empty_status_string is_empty
        if is_empty
          'Empty'
        else
          'Not empty'
        end
      end

      def list?
        database_script.tags.include?('list') ||
          database_script.section == DatabaseScripts::Tagging::LIST_SECTION
      end

      def slow?
        database_script.decorate.slow?
      end
  end
end
