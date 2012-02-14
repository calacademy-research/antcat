# coding: UTF-8
module ReferenceHelper
  def format_reference reference
    Formatters::ReferenceFormatter.format reference
  end

  def format_reference_document_link reference
    Formatters::CatalogFormatter.format_reference_document_link reference, current_user
  end

  def format_reference_document_link reference
    Formatters::CatalogFormatter.format_reference_document_link reference, current_user
  end

  def italicize string
    Formatters::ReferenceFormatter.italicize string
  end

  def format_timestamp timestamp
    Formatters::ReferenceFormatter.format_timestamp timestamp
  end
end
