# coding: UTF-8
Before do
  Family.destroy_all
  FactoryGirl.create :family
  $Milieu = RestrictedMilieu.new
end

Before('@preview') do
  $Milieu = SandboxMilieu.new :preview
end

After('@preview') do
  $Milieu = RestrictedMilieu.new
end
