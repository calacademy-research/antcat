class MoveDataToDocument < ActiveRecord::Migration
  def self.up
    PaperTrail.enabled = false
    Document.delete_all
    Progress.init true, Reference.count
    Reference.all.each do |reference|
      Progress.tally_and_show_progress 1000
      next unless reference.source_url.present?
      reference.build_document
      reference.document.update_attribute :url, reference.source_url
    end
    Progress.show_results
  end

  def self.down
  end
end
