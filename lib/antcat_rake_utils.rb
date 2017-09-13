# Belongs in lib/tasks, but placed here because Rails' autoloading didn't play nice.

module AntCat
  module RakeUtils
    def models_with_taxts
      # model / field(s)
      models = {
        ReferenceSection => ['references_taxt',
                             'title_taxt',
                             'subtitle_taxt'],
        TaxonHistoryItem => ['taxt'],
        Taxon            => ['headline_notes_taxt',
                             'type_taxt',
                             'genus_species_header_notes_taxt'],
        Citation         => ['notes_taxt']
      }
      models.each_item_in_arrays_alias :each_field
      models
    end

    def reject_existing model, ids
      filter_by_existence model, ids, reject_existing: true
    end

    def extract_tagged_ids string, tag
      regex = /(?<={#{Regexp.quote(tag.to_s)} )\d*?(?=})/
      string.scan(regex).map &:to_i
    end

    def find_all_tagged_ids model, column, tag
      ids = []
      tag = tag.to_s
      model.where("#{column} LIKE '%{#{tag} %'").find_each do |matched_obj|
        matched_ids = extract_tagged_ids matched_obj.send(column), tag
        ids += matched_ids if matched_ids
      end
      ids
    end

    private
      def filter_by_existence model, ids, options = {}
        return to_enum(:filter_by_existence, model, ids, options).to_a unless block_given?
        # reject non-existing by default
        reject_existing = options.fetch(:reject_existing) { false }

        if reject_existing
          Array(ids).each { |item| yield item unless model.exists? item }
        else
          Array(ids).each { |item| yield item if model.exists? item }
        end
      end
  end
end
