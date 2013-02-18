# coding: UTF-8
Before do
  Family.destroy_all
  FactoryGirl.create :family, protonym: nil
  $Environment = ProductionEnvironment.new
end

Before('@preview') do
  $Environment = PreviewEnvironment.new
end

After('@preview') do
  $Environment = ProductionEnvironment.new
end

After {Sunspot.remove_all!}
