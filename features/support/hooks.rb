Before do
  include Milieu
  Family.destroy_all
  family = FactoryGirl.build :family
  family.save(validate: false)
  FactoryGirl.create :taxon_state, taxon_id: family.id
  # TODO joe remove this
  family.save
  $Milieu = RestrictedMilieu.new
end

# from http://makandracards.com/makandra/1709-single-step-and-slow-motion-for-cucumber-scenarios-using-javascript-selenium
Before '@slow_motion' do
  @slow_motion = true
end

After '@slow_motion' do
  @slow_motion = false
end

Transform /.*/ do |match|
  if @slow_motion
    sleep 1.5
  end
  match
end

AfterStep '@single_step' do
  print "Single Stepping. Hit enter to continue."
  STDIN.getc
end
