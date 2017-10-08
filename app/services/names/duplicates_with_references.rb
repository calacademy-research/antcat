module Names
  class DuplicatesWithReferences
    include Service

    def initialize options = {}
      @options = options
    end

    def call
      results = {}
      dupes = duplicates
      progress = Progress.create total: dupes.count

      dupes.each do |duplicate|
        puts duplicate.name
        progress.increment
        results[duplicate.name] ||= {}
        results[duplicate.name][duplicate.id] = duplicate.what_links_here
      end

      results
    end

    private
      attr_reader :options

      def duplicates
        Name.where(name: name_strings).order(:name)
      end

      def name_strings
        Name.find_by_sql(<<-SQL).map(&:name)
          SELECT * FROM names GROUP BY name HAVING COUNT(*) > 1
        SQL
      end
  end
end
