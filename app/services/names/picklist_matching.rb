class Names::PicklistMatching
  include Service

  def initialize letters_in_name, options = {}
    @letters_in_name = letters_in_name
    @options = options
  end

  def call
    [prefix_matches, epithet_matches, first_then_any_letter_matches].
      map { |matches| format matches }.
      flatten.uniq { |item| item[:name] }[0, 100]
  end

  private

    attr_reader :letters_in_name, :options

    def prefix_matches
      search_term = letters_in_name + '%'
      picklist_query("name", search_term).order('taxon_id DESC').order(:name)
    end

    def epithet_matches
      search_term = letters_in_name.split('').join('%') + '%'
      picklist_query("epithet", search_term).order(:epithet)
    end

    def first_then_any_letter_matches
      search_term = letters_in_name.split('').join('%') + '%'
      picklist_query("name", search_term).order(:name)
    end

    def picklist_query name_field, search_term
      Name.select('names.id AS id, name, taxa.id AS taxon_id').
        joins("LEFT OUTER JOIN taxa ON taxa.name_id = names.id").
        where("#{name_field} LIKE ?", search_term)
    end

    def format matches
      matches.map do |e|
        result = { id: e.id.to_i, name: e.name, label: e.name, value: e.name }
        result[:taxon_id] = e.taxon_id.to_i if e.taxon_id
        result
      end
    end
end
