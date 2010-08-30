class BoltonImporter
  def get_subfamilies filename, show_progress = false
    $stderr.print "Importing #{filename}" if @show_progress
    doc = Nokogiri::HTML(File.read(filename))
  end
end
