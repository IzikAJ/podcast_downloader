#!/usr/bin/env ruby
require 'readline'
# require_relative File.join('..', 'config', 'application.rb')
# require_relative 'crawler.rb'

class SPagination
  attr_reader :page
  def initialize(items, per_page=10)
    @items = items
    @per_page = per_page
    @current=0
    @page = items[0...per_page]
  end
  def first_index
    @current * @per_page
  end
  def last_index
    (@current+1)*@per_page-1
  end
  def next
    @current += 1
    @page = @items[first_index..last_index]
  end
end

class Scan
  @@LIST = [
    'search', 'download', 'info', 'url',
    'play', 'stop', 'forvard', 'back',
    'update', 'list',
    'sources', 'items', 'files',

    'help', 'exit', 'quit',
    'next', 'prev',
    # 'history', 
  ].sort

  def initialize
    comp = proc { |s| @@LIST.grep(/^#{Regexp.escape(s)}/) }
    Readline.completion_append_character = " "
    Readline.completion_proc = comp

    @pagination = nil

    main_loop
  end

  def parse command
    # puts command
  end

  def cmd_list cmds
    items = case cmds[1]
    when 'sources' then Source.all.map(&:slug)
    when 'items' then Item.all.map(&:title)
    when 'files' then FileItem.all.map(&:url)
    else [
        '  Available arguments: ',
        '    "sources", "items", "files".'
      ]
    end
    @pagination = SPagination.new(items)
    puts @pagination.page
  end

  def cmd_update cmds
    slugs = Source.all.map(&:slug)
    if cmds[1]=='all'
      slugs.each do |slug|
        Crawler.new(slug.to_sym).update_items
      end
    elsif slugs.include?(cmds[1])
      Crawler.new(cmds[1].to_sym).update_items
    else
      puts '  Available arguments: '
      puts "    \"all\", #{slugs.map{|s| "\"#{s}\""}.join(', ')}"
    end

  end

  def main_loop
    while line = Readline.readline('> ', false)
      cmds = line.strip.split(/\s+/)

      if cmds.size > 0
        if Readline::HISTORY.entries.last != line
          Readline::HISTORY.push(line)
        end

        # clear pagination
        @pagination = nil if @pagination
      end

      case cmds[0]
      when 'q', 'quit', 'exit'
        break
      when 'update'
        cmd_update cmds
      when nil
        if @pagination
          page = @pagination.next
          if page
            puts page
          else
            @pagination = nil
          end
        end

      when 'ls', 'list'
        cmd_list cmds
      when 'h', 'help'
        puts "Available commands:"
        LIST.each do |comm|
          puts "  > #{comm}"
        end
      else
        parse line
      end
    end
  end
end

# Scan.new