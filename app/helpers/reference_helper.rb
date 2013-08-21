# coding: UTF-8
module ReferenceHelper
  def format_reference reference
    Formatters::ReferenceFormatter.format reference
  end

  def format_reference_document_link reference
    Formatters::CatalogFormatter.format_reference_document_link reference, current_user
  end

  def format_italics string
    Formatters::ReferenceFormatter.format_italics string
  end

  def format_timestamp timestamp
    Formatters::ReferenceFormatter.format_timestamp timestamp
  end

  def format_review_state review_state
    Formatters::ReferenceFormatter.format_review_state review_state
  end
end
