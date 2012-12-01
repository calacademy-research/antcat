class FixNomenNudumsInBrackets < ActiveRecord::Migration
  def up
    Taxon.where(status: 'nomen nudum').all.each do |taxon|
      for history in taxon.history_items
        if history.taxt =~ /\[.*Nomen nudum.*\]/
          taxon.update_attribute :status, 'valid'
          next
        end
      end
    end
  end
end
