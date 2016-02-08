#!/usr/bin/env ruby

require 'mechanize'
require_relative 'yaml_data'

sources = YamlData.get_hash_file('sources.yml')

puts sources
