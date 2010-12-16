Given /^mapquest determines the distance to be "([^\"]*)"$/ do |distance|
  mockquest = mock MapQuestDirections, :distance_in_kilometres => distance
  MapQuestDirections.stub!(:new).and_return mockquest
end
