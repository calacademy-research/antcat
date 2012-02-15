# coding: UTF-8

class ReleaseTypeBase 
  include ActionView::Helpers::TagHelper
  def title; 'AntCat' end
  def user_can_edit?; !!user_signed_in? end
  def user_can_not_edit?; !user_can_edit? end
  def method_missing(*) end
end

class ProductionReleaseType < ReleaseTypeBase; end

class PreviewReleaseType < ReleaseTypeBase
  def banner; content_tag :div, "preview", class: :preview end
  def title; 'Preview of AntCat' end
  def preview?; true end
  def user_can_edit?; true end
end

ReleaseType = (defined?($release_type) && $release_type == :preview ? PreviewReleaseType : ProductionReleaseType).new

