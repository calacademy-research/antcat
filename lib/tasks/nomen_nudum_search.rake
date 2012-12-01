# coding: UTF-8
desc "Display nomen nudums"
task nomen_nudums: :environment do

  Taxon.ordered_by_name.where(status: 'nomen nudum').all.each do |taxon|
    havent_shown_name = true
    puts_blank_line = false
    for history in taxon.history_items
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
