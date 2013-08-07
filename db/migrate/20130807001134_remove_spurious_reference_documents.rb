class RemoveSpuriousReferenceDocuments < ActiveRecord::Migration
  def up
    ReferenceDocument.where('url LIKE "%source%"').delete_all
  end
end
