# coding: UTF-8

class ServerBase 
  include ActionView::Helpers::TagHelper
  def method_missing(*)
  end
end

class ProductionServer < ServerBase
  def production?() true end
  def preview?() false end
end

class PreviewServer < ServerBase
  def production?() false end
  def preview?() true end

  def banner
    content_tag :div, "preview", class: :preview
  end
end

Server = (defined?($preview) && $preview ? PreviewServer : ProductionServer).new

