module Taxa::Synonyms
  extend ActiveSupport::Concern

  def current_valid_taxon_including_synonyms
    Taxa::CurrentValidTaxonIncludingSynonyms[self]
  end

  def junior_synonyms_with_own_id
    synonyms_with_names :junior
  end

  def senior_synonyms_with_own_id
    synonyms_with_names :senior
  end

  def junior_synonyms_recursive
    @junior_synonyms_recursive ||= Taxon.where(id: junior_synonym_ids_recursive)
  end

  protected

    # TODO this executes a lot of queries, but let's first clear up some things,
    # see https://github.com/calacademy-research/antcat/issues/279
    def junior_synonym_ids_recursive
      return [] unless junior_synonyms.exists?

      all_juniors = junior_synonyms.pluck(:id)

      junior_synonyms.each do |junior_synonym|
        ids = junior_synonym.junior_synonym_ids_recursive
        all_juniors.push(*ids) unless ids.empty?
      end

      all_juniors
    end

  private

    def synonyms_with_names junior_or_senior
      if junior_or_senior == :junior
        join_column = 'junior_synonym_id'
        where_column = 'senior_synonym_id'
      else
        join_column = 'senior_synonym_id'
        where_column = 'junior_synonym_id'
      end

      self.class.find_by_sql <<-SQL.squish
        SELECT synonyms.id, taxa.name_html_cache AS name, taxa.id AS taxon_id
        FROM synonyms JOIN taxa ON synonyms.#{join_column} = taxa.id
        JOIN names ON taxa.name_id = names.id
        WHERE #{where_column} = #{id}
        ORDER BY name
      SQL
    end
end
