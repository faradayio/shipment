require 'bundler'
Bundler.setup

require 'cucumber'
require 'cucumber/formatter/unicode'
require 'rspec'
require 'rspec/expectations'

require 'sniff'
Sniff.init File.join(File.dirname(__FILE__), '..', '..'), :cucumber => true, :earth => [:locality, :fuel]
