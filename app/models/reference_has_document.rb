# coding: UTF-8
class Reference < ActiveRecord::Base
  has_one :document, :class_name => 'ReferenceDocument'
  accepts_nested_attributes_for :document, :reject_if => :all_blank

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
