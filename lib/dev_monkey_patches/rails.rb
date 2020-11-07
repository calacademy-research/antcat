# frozen_string_literal: true

module DevMonkeyPatches
  module Rails
    def self.patch!
      ::ActiveRecord::Relation.include ActiveRecord::Relation
    end

    module ActiveRecord
      module Relation
        # Example with block:
        #   tt = Species.limit(3)
        #   tt.peach do |tb| tb.add_column("Type name of") { |tx| Taxon.find_by(type_taxon: tx).l } end
        def dev_dev_puts_each
          $stdout.puts "Total: #{count} of types: #{distinct.pluck(:type).join(', ')}.\n".yellow

          table = Tabulo::Table.new(to_a, border: :markdown) do |tb|
            tb.add_column("ID", &:id)
            tb.add_column("Rank", &:type)
            tb.add_column("Status", &:status)
            tb.add_column("Name", &:name_cache)
            tb.add_column("Link") { |tx| tx.l(include_name: false) }
            yield tb if block_given?
          end
          $stdout.puts table.pack
          nil # Suppress echo in console.
        end
        alias_method :peach, :dev_dev_puts_each

        def dev_dev_localhost_link_open
          each do |object|
            object.ll.open
          end
          nil # Suppress echo in console.
        end
        alias_method :llo, :dev_dev_localhost_link_open
      end
    end
  end
end
