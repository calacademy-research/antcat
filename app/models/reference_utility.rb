# coding: UTF-8

# These are methods used either now or at one time by Rake tasks, not
# by application code, so could well be dead

class Reference < ActiveRecord::Base

  def self.import_hol_document_urls show_progress = false
    Importers::Hol::DocumentUrlImporter.new(show_progress).import
  end

  def replace_author_name old_name, new_author_name
    old_author_name = AuthorName.find_by_name old_name
    reference_author_name = reference_author_names.where(:author_name_id => old_author_name).first
    reference_author_name.author_name = new_author_name
    reference_author_name.save!
    author_names(true)
    refresh_author_names_caches
  end

  def replace_with reference, options = {}
    Taxt.taxt_fields.each do |klass, fields|
      for record in klass.send :all
        for field in fields
          next unless record[field]
          record[field] = record[field].gsub /{ref #{id}}/, "{ref #{reference.id}}"
        end
        record.save!
      end
    end

    self.class.update_fields replace: id, with: reference.id
  end

  def self.replace_with_batch batch
    Taxt.taxt_fields.each do |klass, fields|
      for record in klass.send :all
        for field in fields
          next unless record[field]
          for replacement in batch
            from = "{ref #{replacement[:replace].id}}"
            to = "{ref #{replacement[:with].id}}"
            record[field] = record[field].gsub /#{from}/, to
          end
        end
        record.save!
      end
    end

    for replacement in batch
      update_fields replacement
    end

  end

  def self.update_fields replacement
    for klass in [Citation, Bolton::Match]
      klass.where(reference_id: replacement[:replace]).update_all(reference_id: replacement[:with])
    end
    NestedReference.where(nested_reference_id: replacement[:replace]).update_all(nested_reference_id: replacement[:with])
  end

end
