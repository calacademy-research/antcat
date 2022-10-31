# frozen_string_literal: true

namespace :antcat do
  namespace :tooltips do
    desc "Find db tooltips referenced in the code but are not in the database"
    task missing: [:environment] do
      results = `grep -rh 'db_tooltip_icon' app/`
      lines = results.split("\n")

      keys_and_scope = lines.map do |line|
        next if line.include?('def db_tooltip_icon')

        key, scope = line.scan(/db_tooltip_icon[ (]["':](.*?)["']?, scope: ["':](.*)/).flatten

        [key, scope]
      end.compact.uniq

      keys_and_scope.each do |key, scope|
        if Tooltip.where(key: key, scope: scope).exists?
          puts "[OK]       In database       #{scope} #{key}".green
        else
          puts "[NOT OK]   Not in database   #{scope} #{key}".red
        end
      end
    end

    desc "Find db tooltips in the database but are not referenced in the code"
    task unused: [:environment] do
      results = `grep -rh 'db_tooltip_icon' app/`
      lines = results.split("\n")

      tooltips_in_source_code = lines.map do |line|
        next if line.include?('def db_tooltip_icon')

        key, scope = line.scan(/db_tooltip_icon[ (]["':](.*?)["']?, scope: ["':](.*)/).flatten

        { key: key, scope: scope }.stringify_keys
      end.compact.uniq

      Tooltip.all.each do |tooltip|
        in_source_code = tooltip.slice(:key, :scope).in?(tooltips_in_source_code)

        message = "#{tooltip.id.to_s.ljust(3)} #{tooltip.scope} #{tooltip.key}"
        if in_source_code
          puts "[OK]       In source code      #{message}".green
        else
          puts "[NOT OK]   Not in source code  #{message}".red
        end
      end
    end
  end
end
