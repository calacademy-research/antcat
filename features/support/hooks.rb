# coding: UTF-8
Before do
  Family.destroy_all
  FactoryGirl.create :family, protonym: nil
  $Milieu = RestrictedMilieu.new
end

Before('@preview') do
  $Milieu = SandboxMilieu.new :preview
end

After('@preview') do
  $Milieu = RestrictedMilieu.new
end

After {Sunspot.remove_all!}
