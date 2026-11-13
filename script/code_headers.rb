# frozen_string_literal: true

# Every Ruby file of the app (app/ and lib/) starts with a short comment that says what it does, so a new developer
# can read the header and know what the file is for, who uses it and where it fits.
#
# A header is a run of comment lines at the top of the file, before or between the `module`/`class` lines that open
# it, with at least one line of three or more words (a `rubocop:` line does not count). Also accepted:
# - a rake file with a `desc "..."` of three or more words (rake shows it in `rake -T`);
# - a database script (app/database_scripts/database_scripts/) with its `__END__` block, which the
#   /database_scripts page shows (section, tags, description).
#
# docs/catalog/headers-missing.txt lists the files that have no header yet. spec/catalog/code_headers_spec.rb
# fails when a file not on that list has no header (new files need one) and when a file on the list now has one
# (take its line out, so the list only shrinks).
#
#   ruby script/code_headers.rb            the counts and the files without a header
#   ruby script/code_headers.rb --write    rewrite the list from the files as they are
module CodeHeaders
  ROOT = File.expand_path('..', __dir__)
  BASELINE = 'docs/catalog/headers-missing.txt'
  BASELINE_INTRO = "# Ruby files without a header comment (script/code_headers.rb). Only ever remove lines.\n"
  GLOBS = ['app/**/*.rb', 'lib/**/*.rb', 'lib/**/*.rake'].freeze
  DATABASE_SCRIPTS = 'app/database_scripts/database_scripts/'
  OPENER = /\A\s*(module|class)\s+[A-Z][\w:]*(\s*<\s*[\w:]+)?\s*\z/

  module_function

  def files
    GLOBS.flat_map { |glob| Dir.glob(glob, base: ROOT) }.uniq.sort
  end

  def sentence? line
    text = line.sub(/\A\s*#+/, '').strip
    return false if text.start_with?('rubocop:', 'frozen_string_literal', 'encoding:', 'NOTE: rubocop')
    text.scan(/[A-Za-z][A-Za-z'-]*/).size >= 3
  end

  def header? path
    source = File.read(File.join(ROOT, path))
    return true if path.start_with?(DATABASE_SCRIPTS) && source.match?(/^__END__\s*\n(.*\n)*\s*section:/)
    return true if path.end_with?('.rake') && source.each_line.any? { |l| l =~ /^\s*desc\s+["']/ && sentence?(l.sub(/desc/, '#')) }

    # A comment counts when it comes before the first opener (a file's own header) or right before an opener (the
    # class's doc inside its namespace), not when it is the first comment inside a class (that is about a method).
    seen_opener = false
    pending = false
    source.each_line do |line|
      next if line.strip.empty?
      if line.match?(OPENER)
        return true if pending
        seen_opener = true
      elsif line.lstrip.start_with?('#')
        return true if sentence?(line) && !seen_opener
        pending ||= sentence?(line)
      else
        return false
      end
    end
    false
  end

  def missing
    files.reject { |path| header?(path) }
  end

  def baseline
    path = File.join(ROOT, BASELINE)
    return [] unless File.exist?(path)
    File.readlines(path, chomp: true).reject { |l| l.empty? || l.start_with?('#') }
  end

  def write_baseline
    File.write(File.join(ROOT, BASELINE), BASELINE_INTRO + missing.map { |p| "#{p}\n" }.join)
  end
end

if $PROGRAM_NAME == __FILE__
  if ARGV.include?('--write')
    CodeHeaders.write_baseline
    puts "wrote #{CodeHeaders::BASELINE}: #{CodeHeaders.missing.size} files"
  else
    missing = CodeHeaders.missing
    puts "#{CodeHeaders.files.size} files, #{CodeHeaders.files.size - missing.size} with a header, #{missing.size} without"
    by_dir = missing.group_by { |p| p.split('/').first(2).join('/') }
    by_dir.sort.each { |dir, list| puts "  #{dir}: #{list.size}" }
  end
end
