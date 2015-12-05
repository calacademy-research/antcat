class ReferenceDecorator < Draper::Decorator
  include Formatters::LinkFormatter # link

  delegate_all

  def format_reference_document_link reference, user
    doi = format_doi_link(reference)
    pdf = link 'PDF', reference.url, class: 'document_link' if reference.downloadable_by? user
    if (doi)
      return doi + " " + pdf
    else
      return pdf
    end
  end

  def format_doi_link reference
    unless reference.doi.nil? or reference.doi.length == 0
      link reference.doi, create_link_from_doi(reference.doi), class: 'document_link'
    end
  end

  # transform "10.11646/zootaxa.4029.1.1"
  # http://dx.doi.org/10.11646/zootaxa.4029.1.1
  # <a href="http://www.w3schools.com">Visit W3Schools</a>
  def create_link_from_doi doi
    #"<a href=\"http://dx.doi.org/" + doi + "\">#{doi}</a>"
    "http://dx.doi.org/" + doi
  end
end
