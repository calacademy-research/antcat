class Exporters::TaxonList::Exporter
  def export directory = 'data/output'
    File.open "#{directory}/antcat_taxon_list.txt", 'w' do |file|
      write_rows file, get_rows
    end
  end

  private
    def get_rows
      Taxon.find_by_sql <<-SQL.squish
        SELECT name, year, COUNT(*) count FROM taxa
        JOIN protonyms ON protonym_id = protonyms.id
        JOIN citations ON authorship_id = citations.id
        JOIN `references` ON reference_id = `references`.id
        JOIN reference_author_names ran ON ran.reference_id = references.id AND position = 1
        JOIN author_names an ON ran.author_name_id = an.id
        WHERE taxa.type = 'Species'
          AND status = 'valid'
          OR status = 'synonym'
          OR status = 'homonym'
        GROUP BY name, year ORDER BY name, year
      SQL
    end

    def write_rows file, rows
      rows.each do |row|
        write file, join(row['name'], row['year'], row['count'])
      end
    end

    def write file, line
      file.puts line
    end

    def join *values
      values.join "\t"
    end
end
