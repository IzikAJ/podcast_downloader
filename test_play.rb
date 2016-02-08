require 'open-uri'
require 'audite'
require 'mechanize'

# player = Audite.new
# player.events.on(:complete) do
#   puts "COMPLETE"
# end
# player.events.on(:position_change) do |pos|
#   puts "POSITION: #{pos} seconds  level #{player.level}"
# end

mech = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

def download file_url, filename=nil, chunk=1<<12, &block
  path, filename = File.split(file_url) if filename.nil?
  total = 0
  last = -1
  stream = open( file_url,
    content_length_proc: proc { |length| total = length },
    progress_proc: proc do |step|
      if block_given? && (last < 0) || ((step - last)>1024000)
        block.call(step, total)
        last = step
      end
    end
  )
  IO.copy_stream(stream, filename)
end

mech.get("http://rwpod.podfm.ru") do |page|
end

# file = 'http://rwpod.podfm.ru/my/140/file/podfm_rwpod_my_4_140.mp3'
# path, name = File.split file

# download(file) do |step, total|
#   puts "Downloaded #{step>>10}kb / #{total>>10}kb"
# end
# 
# mech.download(file, name)

# player.load(name)
# player.start_stream
# player.thread.join
