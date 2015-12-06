class ReferenceDecorator < Draper::Decorator
  include Formatters::LinkFormatter # link method

  delegate_all

  private def get_current_user # to make the tests not blow up TODO remove
    helpers.current_user
    rescue NoMethodError
      nil
  end

  def format_reference_document_link
    doi = format_doi_link

    if reference.downloadable_by? get_current_user
      pdf = link 'PDF', reference.url, class: 'document_link'
    end

    if doi
      return doi + " " + pdf #pdf may not be defined at this poit TODO fix
    else
      return pdf
    end
  end

  private
    def format_doi_link
      unless reference.doi.nil? or reference.doi.length == 0
        link reference.doi, create_link_from_doi(reference.doi), class: 'document_link'
      end
    end

    # transform "10.11646/zootaxa.4029.1.1"
    # http://dx.doi.org/10.11646/zootaxa.4029.1.1
    def create_link_from_doi doi
      #"<a href=\"http://dx.doi.org/" + doi + "\">#{doi}</a>"
      "http://dx.doi.org/" + doi
    end
end
