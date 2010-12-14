require 'net/http'
require 'nokogiri'

class MapQuestDirections
  class Failure < StandardError; end

  attr_accessor :location_1, :location_2, :xml_call, :doc
  
  def initialize(location_1, location_2, api_key)
    @base_url = "http://www.mapquestapi.com/directions/v1/route?key=#{api_key}&outFormat=xml&"    
    @location_1 = location_1
    @location_2 = location_2
    options = "from=#{transcribe(@location_1)}&to=#{transcribe(@location_2)}"
    @xml_call = @base_url + options
  end
  
  def doc
    @doc ||= begin
      xml = get_url(xml_call)
      noko = Nokogiri::XML(xml)
      status = noko.css("statusCode").text
      unless status == '0'
        errors = noko.css("message").map(&:text).join(', ')
        raise Failure, "Could not calculate directions between #{location_1} and #{location_2}: #{errors}"
      end
      noko
    end
  end

  def drive_time_in_minutes
    drive_time = doc.css("time").first.text
    convert_to_minutes(drive_time)
  end

  def distance_in_miles
    distance_in_miles = doc.css("distance").first.text.to_i
  end
    
private
  def convert_to_minutes(text)
    (text.to_i / 60).ceil
  end

  def transcribe(location)
    location.gsub(" ", "+")
  end

  def get_url(url)
    Net::HTTP.get(::URI.parse(url))
  end
end
