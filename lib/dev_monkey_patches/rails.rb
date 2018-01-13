module DevMonkeyPatches::Rails
  def self.patch!
    ActiveRecord::Relation.include ActiveRecord_Relation
  end

  module ActiveRecord_Relation
    def v
      valid
    end

    def c
      count
    end

    def dev_dev_puts_each
      $stdout.puts "Total: #{count} of types #{distinct.pluck(:type).join(", ")}.".yellow
      each do |taxon|
        $stdout.print "#{taxon.id.to_s.bold} "
        $stdout.print "(#{taxon.status[0..4]}) "
        $stdout.print "#{taxon.rank} ".blue
        $stdout.puts "#{taxon.name_cache.bold}\t\t".green
      end
    end
    alias_method :peach, :dev_dev_puts_each
  end
end
