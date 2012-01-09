# coding: UTF-8
module HasDocument

  def url
    document && document.url
  end

  def downloadable_by? user
    document && document.downloadable_by?(user)
  end

  def document_host= host
    document && document.host = host
  end

end
