# coding: UTF-8
# These are methods used either now or at one time by Rake tasks, not
# by application code, so could well be dead

class Reference < ActiveRecord::Base

  def self.import_hol_document_urls show_progress = false
    Importers::Hol::DocumentUrlImporter.new(show_progress).import
  end

  def replace_author_name old_name, new_author_name
    old_author_name = AuthorName.find_by_name old_name
    reference_author_name = reference_author_names.where(author_name_id: old_author_name).first
    reference_author_name.author_name = new_author_name
    reference_author_name.save!
    author_names(true)
    refresh_author_names_caches
  end

  def replace_with reference, options = {}
    Taxt.taxt_fields.each do |klass, fields|
      klass.send(:all).each do |record|
        fields.each do |field|
          next unless record[field]
          record[field] = record[field].gsub /{ref #{id}}/, "{ref #{reference.id}}"
        end
        record.save!
      end
    end
    self.class.update_fields [{ replace: id, with: reference.id }]
  end

  def self.get_total_records_to_update
    total = 0
    Taxt.taxt_fields.each do |klass, fields|
      total += klass.count
    end
    total
  end

  def self.replace_with_batch batch, show_progress = false
    total_records_to_update = get_total_records_to_update
    Progress.init show_progress
    Progress.puts "#{batch.size} replacements to make"
    return unless batch.present?
    Taxt.taxt_fields.each do |klass, fields|
      Progress.init show_progress, klass.send(:count)
      Progress.puts "Updating #{klass}..."
      klass.send(:all).each do |record|
        Progress.tally_and_show_progress 300
        fields.each do |field|
          next unless record[field]
          batch.each do |replacement|
            from = "{ref #{replacement[:replace]}}"
            to = "{ref #{replacement[:with]}}"
            field_contents = record[field]
            was_replaced = field_contents.gsub! /#{from}/, to
            if was_replaced
              sanitized_contents = ActiveRecord::Base::sanitize field_contents
              # unknown why this is necessary
              connection.execute %{UPDATE #{klass.table_name} SET #{field} = #{sanitized_contents} WHERE id = #{record.id}}
            end
          end
        end
      end
      Progress.show_results
    end

    update_fields batch
  end

  def self.update_fields batch
    batch.each do |replacement|
      [Citation, Bolton::Match].each do |klass|
        klass.where(reference_id: replacement[:replace])
          .update_all(reference_id: replacement[:with])
      end
      NestedReference.where(nesting_reference_id: replacement[:replace])
        .update_all(nesting_reference_id: replacement[:with])
    end
  end

end
