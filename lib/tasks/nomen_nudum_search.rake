desc "Display nomina nuda"
task nomina_nuda: :environment do

  Taxon.ordered_by_name.where(status: 'nomen nudum').all.each do |taxon|
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
