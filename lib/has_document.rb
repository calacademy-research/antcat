# coding: UTF-8
module HasDocument

  def url
    document.try :url
  end

  def downloadable_by? user
    document.try :downloadable_by?, user
  end

  def document_host= host
    document.host = host if document
  end

end
