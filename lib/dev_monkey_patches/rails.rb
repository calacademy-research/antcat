module DevMonkeyPatches
  module Rails
    def self.patch!
      ::ActiveRecord::Relation.include ActiveRecord::Relation
    end

    module ActiveRecord
      module Relation
        def dev_dev_puts_each
          $stdout.puts "Total: #{count} of types #{distinct.pluck(:type).join(', ')}.".yellow
          each do |taxon|
            $stdout.print "#{taxon.id.to_s.bold} "
            $stdout.print "(#{taxon.status[0..4]}) "
            $stdout.print "#{taxon.rank[0..10]} ".ljust(11).blue
            $stdout.print "#{taxon.name_cache.bold}\t\t".green
            yield taxon if block_given?
            $stdout.puts
          end
          nil # Suppress echo in console.
        end
        alias_method :peach, :dev_dev_puts_each
      end
    end
  end
end
