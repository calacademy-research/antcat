# coding: UTF-8

class ReleaseType 
  include ActionView::Helpers::TagHelper
  def title; 'AntCat' end
  def user_can_edit?(user) user || preview? end
  def user_can_not_edit?(user); !user_can_edit user end
  def method_missing(*) end
end

class ProductionReleaseType < ReleaseType
  def production?; true end
end

class PreviewReleaseType < ReleaseType
  def title; 'Preview of AntCat' end
  def preview?; true end
  def user_can_edit?(_); true end
end

# The preview-or-production environment detection mechanism detects the
# presence of any preview file with 'preview' in its name in
# config/initializers/release_type. The reason for this crude approach
# is that sunspot.yml needs to know what the release type is, and that's
# loaded before initializers

# With this approach, each branch can have its own release type, simply 
# by including or not including a file with 'preview' in its name.
# If each branch has its own 'branch.preview' file (or not), then they
# won't be affected by each others' presence.

preview_files = Rails.root + 'config/initializers/release_type/*preview*'
is_preview = Dir.glob(preview_files).present?
$ReleaseType = (is_preview ? PreviewReleaseType : ProductionReleaseType).new

