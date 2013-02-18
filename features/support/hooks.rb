# coding: UTF-8
Before do
  Family.destroy_all
  FactoryGirl.create :family, protonym: nil
  $Environment = RestrictedEnvironment.new
end

Before('@preview') do
  $Environment = SandboxEnvironment.new :preview
end

After('@preview') do
  $Environment = RestrictedEnvironment.new
end

After {Sunspot.remove_all!}
