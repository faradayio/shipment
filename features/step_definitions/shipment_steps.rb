Given /^mapquest determines the distance to be "([^\"]*)"$/ do |distance|
  mockquest = mock MapQuestDirections, :distance_in_kilometres => distance
  MapQuestDirections.stub!(:new).and_return mockquest
end

Given /^the geocoder will encode the (.*) as "(.*)"$/ do |component, location|
  @expectations << lambda do
    components = @characteristics ? @characteristics : @activity_hash
    component_value = components[component.to_sym].to_s
    code = mock Object, :ll => location
    Geokit::Geocoders::MultiGeocoder.should_receive(:geocode).
      with(component_value).
      and_return code
  end
end
