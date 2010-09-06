class BoltonImporter
  def get_subfamilies filename, show_progress = false
    $stderr.print "Importing #{filename}" if @show_progress
    doc = Nokogiri::HTML(File.read(filename))

    doc.css('p').inject([]) do |genera, p|
      span = p.css('b i span')
      if span.present?
        genus = span.inner_html.titleize
        genera << { :genus => genus }
      end
      genera
    end
  end
end
