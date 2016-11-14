Given(/^there is a Lasius subspecies without a species$/) do
  subspecies = create_subspecies "Lasius specius subspecius", species: nil
  expect(subspecies.species).to be nil
end
