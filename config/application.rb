require 'rubygems'
require 'data_mapper'
require 'mechanize'
require 'require_all'
require_relative 'yaml_data'

class App
  @@root = File.expand_path(File.dirname(File.dirname(__FILE__)))
  def self.root
    @@root
  end

end

require_all File.join(App.root, 'lib/**/*.rb')
require_all File.join(App.root, 'models/**/*.rb')
require_rel 'initializers/**/*.rb'
DataMapper.finalize
