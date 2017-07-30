# TODO cleanup after extracting into service object.

module Taxa
  class QuickSearch
    def initialize taxon_name, search_type: nil, valid_only: false
      @taxon_name = taxon_name.dup.strip
      @search_type = search_type || "beginning_with"
      @valid_only = valid_only
    end

    def call
      return Taxon.none if taxon_name.blank?

      #valid_only = false if valid_only.blank?
      column = taxon_name.split(' ').size > 1 ? 'name' : 'epithet'

      query = Taxon.joins(:name).order_by_name_cache
      query = query.valid if valid_only.present?
      query = case search_type
              when 'matching'
                query.where("names.#{column} = ?", taxon_name)
              when 'beginning_with'
                query.where("names.#{column} LIKE ?", taxon_name + '%')
              when 'containing'
                query.where("names.#{column} LIKE ?", '%' + taxon_name + '%')
              end
      query.includes(:name, protonym: { authorship: :reference })
    end

    private
      attr_reader :taxon_name, :search_type, :valid_only
  end
end
