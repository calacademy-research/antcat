# coding: UTF-8
require 'release_type'

Before do
  Family.delete_all
  Factory :family, protonym: nil
end

Before('@preview') do
  $ReleaseType = PreviewReleaseType.new
end

After('@preview') do
  $ReleaseType = ProductionReleaseType.new
end

After {Sunspot.remove_all!}
