require_relative File.join('config', 'application.rb')

# mech.get("http://rwpod.podfm.ru") do |page|
# end

# file = 'http://rwpod.podfm.ru/my/140/file/podfm_rwpod_my_4_140.mp3'
# path, name = File.split file
# path, filename = File.split(file)

# download(file, File.join("out", 'sample3.mp3'), 0.3) do |step, total, speed|
#   bar ||= ProgressBar.new(total>>10, :bar, :percentage)
#   bar.increment! step>>10
# end
# puts "Downloaded #{step>>10}kb / #{total>>10}kb at #{speed/1024}kb/s"
# 
# mech.download(file, name)

# player.load(name)
# player.start_stream
# player.thread.join
Scan.new