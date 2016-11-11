# TODO move most code to somewhere else and call it from here.

desc "Display nomina nuda"
task nomina_nuda: :environment do

  Taxon.order_by_name_cache.where(status: 'nomen nudum').all.each do |taxon|
    havent_shown_name = true
    puts_blank_line = false
    taxon.history_items.each do |history|
      if history.taxt =~ /\[.*Nomen nudum.*\]/
        puts_blank_line = true
        if havent_shown_name
          puts taxon.name.name
          havent_shown_name = false
        end
        puts history.taxt
      end
      puts if puts_blank_line
    end
  end

end
