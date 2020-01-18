namespace :antcat do
  desc "Find db tooltips referenced in the code but are not in the database"
  task missing_db_tooltips: [:environment] do
    results = `grep -rh 'db_tooltip_icon' app/`
    lines = results.split("\n")

    lines.each do |line|
      next if line.include?('def db_tooltip_icon')

      key, scope = line.scan(/db_tooltip_icon[ (]["':](.*?)["']?, scope: ["':](.*)/).flatten
      if Tooltip.where(key: key, scope: scope).exists?
        puts "OK: #{key} #{scope}".green
      else
        puts "Missing: #{key} #{scope}".red
      end
    end
  end
end
