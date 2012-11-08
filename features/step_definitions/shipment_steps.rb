require 'rspec/mocks'
RSpec::Mocks.setup self
include RSpec::Mocks::ExampleMethods

Given /^mapquest determines the distance in miles to be "([^\"]*)"$/ do |distance|
  if distance.present?
    mockquest = mock MapQuestDirections, :status => 0, :distance_in_miles => distance.to_f
  else
    mockquest = mock MapQuestDirections, :status => 400, :distance_in_miles => 0.0
  end
  MapQuestDirections.stub!(:new).and_return mockquest
end

Given /^the geocoder will encode the (.*) as "([^\"]*)"$/ do |location, lat_lng|
  if lat_lng.present?
    result = mock Geocoder::Result, :coordinates => lat_lng.split(',').map(&:to_f)
  else
    result = nil
  end
  Geocoder.should_receive(:search).with(@characteristics[location.to_sym]).and_return [result]
end

Then /^the conclusion of the committee should be located at "(.*)"$/ do |expected_value|
  compare_values @report.conclusion.coordinates, expected_value.split(',').map(&:to_f)
end
