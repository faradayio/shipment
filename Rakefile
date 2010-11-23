require 'rubygems'

def require_or_fail(gems, message, failure_results_in_death = false)
  gems = [gems] unless gems.is_a?(Array)

  begin
    gems.each { |gem| require gem }
    yield
  rescue LoadError
    puts message
    exit if failure_results_in_death
  end
end

unless ENV['NOBUNDLE']
  message = <<-MESSAGE
In order to run tests, you must:
  * `gem install bundler`
  * `bundle install`
  MESSAGE
  require_or_fail('bundler',message,true) do
    Bundler.setup
  end
end

require_or_fail('jeweler', 'Jeweler (or a dependency) not available. Install it with: gem install jeweler') do
  Jeweler::Tasks.new do |gem|
    gem.name = "shipment"
    gem.summary = %Q{A carbon model for a shipment}
    gem.description = %Q{A software model in Ruby for the greenhouse gas emissions of a shipment}
    gem.email = "andy@rossmeissl.net"
    gem.homepage = "http://brighterplanet.github.com/shipment"
    gem.authors = ["Andy Rossmeissl", "Seamus Abshere", "Ian Hough", "Matt Kling", 'Derek Kastner']
    gem.files = ['LICENSE', 'README.rdoc'] + 
      Dir.glob(File.join('lib', '**','*.rb'))
    gem.test_files = Dir.glob(File.join('features', '**', '*.rb')) +
      Dir.glob(File.join('features', '**', '*.feature')) +
      Dir.glob(File.join('lib', 'test_support', '**/*.rb'))
    gem.add_development_dependency 'activerecord', '~>3.0.1'
    gem.add_development_dependency 'bundler', '~>1.0.0'
    gem.add_development_dependency 'rake'
    gem.add_development_dependency 'sniff', '~>0.4.3' unless ENV['LOCAL_SNIFF']
    gem.add_dependency 'emitter', '~>0.3.0' unless ENV['LOCAL_EMITTER']
    gem.add_dependency 'earth', '~>0.3.1' unless ENV['LOCAL_EARTH']
  end
  Jeweler::GemcutterTasks.new
end

require_or_fail 'sniff', 'Sniff gem not found, sniff tasks unavailable' do
  require 'sniff/rake_tasks'
  Sniff::RakeTasks.define_tasks
end
