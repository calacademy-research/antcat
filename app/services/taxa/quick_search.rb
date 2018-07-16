# TODO cleanup after extracting into service object.

module Taxa
  class QuickSearch
    include Service

    def initialize search_query, search_type: nil, valid_only: false
      @search_query = search_query.dup.strip
      @search_type = search_type || "beginning_with"
      @valid_only = valid_only
    end

    def call
      return Taxon.none if search_query.blank?

      query = Taxon.joins(:name).order_by_name_cache
      query = query.valid if valid_only.present?
      query = case search_type
              when 'matching'
                query.where("names.#{column} = ?", search_query)
              when 'beginning_with'
                query.where("names.#{column} LIKE ?", search_query + '%')
              when 'containing'
                query.where("names.#{column} LIKE ?", '%' + search_query + '%')
              end
      query.includes(:name, protonym: { authorship: :reference })
    end

    private

      attr_reader :search_query, :search_type, :valid_only

      def column
        @_column ||= search_query.split(' ').size > 1 ? 'name' : 'epithet'
      end
  end
end
