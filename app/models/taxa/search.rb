class Taxa::Search
  # TODO refactor more.
  def self.quick_search taxon_name, search_type: nil, valid_only: false
    Taxa::QuickSearch.new(taxon_name, search_type: search_type, valid_only: valid_only).call
  end

  def self.advanced_search params
    Taxa::AdvancedSearch.new(params).call
  end
end
