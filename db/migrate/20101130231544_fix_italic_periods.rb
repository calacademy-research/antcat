class FixItalicPeriods < ActiveRecord::Migration
  def self.up
    references = Reference.all(:conditions => 'title like "%.*"')
    puts "Unitalicizing periods in #{references.size} titles"
    references.each do |reference|
      reference.update_attribute :title, reference.title.gsub(/\.\*/, '*.')
    end

    references = Reference.all(:conditions => 'citation like "%.*"')
    puts "Unitalicizing periods in #{references.size} citations"
    references.each do |reference|
      reference.update_attribute :citation, reference.citation.gsub(/\.\*/, '*.')
    end
  end

  def self.down
  end
end
