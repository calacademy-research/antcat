module Taxa::Synonyms
  extend ActiveSupport::Concern

  def current_valid_taxon_including_synonyms
    if synonym?
      if senior = find_most_recent_valid_senior_synonym
        return senior
      end
    end
    current_valid_taxon
  end

  def find_most_recent_valid_senior_synonym
    return unless senior_synonyms
    senior_synonyms.order(created_at: :desc).each do |senior_synonym|
      return senior_synonym if !senior_synonym.invalid?
      return nil unless senior_synonym.synonym?
      return senior_synonym.find_most_recent_valid_senior_synonym
    end
    nil
  end

  def junior_synonyms_with_names
    synonyms_with_names :junior
  end

  def senior_synonyms_with_names
    synonyms_with_names :senior
  end

  def become_junior_synonym_of senior
    Synonym.where(junior_synonym: senior, senior_synonym: self).destroy_all
    Synonym.where(senior_synonym: senior, junior_synonym: self).destroy_all
    Synonym.create! junior_synonym: self, senior_synonym: senior
    senior.update_attributes! status: 'valid'
    update_attributes! status: 'synonym'
  end

  def become_not_junior_synonym_of senior
    Synonym.where(junior_synonym: self, senior_synonym: senior).destroy_all
    update_attributes! status: 'valid' if senior_synonyms.empty?
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
        SELECT synonyms.id, taxa.name_html_cache AS name
        FROM synonyms JOIN taxa ON synonyms.#{join_column} = taxa.id
        JOIN names ON taxa.name_id = names.id
        WHERE #{where_column} = #{id}
        ORDER BY name
      SQL
    end

end
