class MigrateTypeFields < ActiveRecord::Migration[4.2]
  def self.up
    raise "saftey check since this file is not in `data_schema.rb`" unless Rails.env.test?
    set_user_for_papertrail! unless Rails.env.test?

    taxa_to_migrate.find_each do |taxon|
      taxon.published_type_information = build_published_type_information taxon
      taxon.save!
    end
  end

  def self.down
    # No-op.
  end

  private
    class << self
      def set_user_for_papertrail!
        antcat_bot_user_id = 62
        PaperTrail.whodunnit = antcat_bot_user_id
      end

      def taxa_to_migrate
        ids = Taxon.where.not(verbatim_type_locality: [nil, '']).pluck(:id) +
          Taxon.where.not(type_specimen_code: [nil, '']).pluck(:id) +
          Taxon.where.not(type_specimen_repository: [nil, '']).pluck(:id)
        Taxon.where(id: ids.uniq)
      end

      def build_published_type_information taxon
        [
          taxon.verbatim_type_locality,
          taxon.type_specimen_code,
          type_specimen_repository(taxon)
        ].reject(&:blank?).map(&:strip).join("; ")
      end

      def type_specimen_repository taxon
        repo = taxon.type_specimen_repository
        return repo unless replace_with_abbreviation? repo

        repo.match(institutions_regex)[0].tr('(', '').tr(')', '')
      end

      def replace_with_abbreviation? repo
        return false unless repo.present?
        return false unless contains_single_set_of_parentheses? repo

        repo =~ institutions_regex
      end

      def contains_single_set_of_parentheses? repo
        repo.count('(') == 1 && repo.count(')') == 1
      end

      def institutions_regex
        @_institutions_regex = begin
          abbreviation = Institution.pluck(:abbreviation)
          /\((#{abbreviation.join('|')})\)/
        end
      end
    end
end
