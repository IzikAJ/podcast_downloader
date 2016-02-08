#!/usr/bin/env ruby

require 'mechanize'
require_relative 'yaml_data'

puts YamlData.get_hash_file('config.yml')