require 'open-uri'
require 'progress_bar'

class CustomDownload
  def self.download(file, filename = nil, timeout = 0.5, &block)
    _path, filename = File.split(file) if filename.nil?
    total = last = 0
    stream = open(
      file,
      content_length_proc: proc do |length|
        total = length
        block.call(0, total) if block_given?
        _last = Time.now.to_f
      end,
      progress_proc: proc do |step|
        curr = Time.now.to_f
        if block_given? && ((curr - last) >= timeout)
          block.call(step, total)
          last = curr
        end
      end
    )
    block.call(total, total, 0) if block_given?
    IO.copy_stream(stream, filename)
    filename
  end

  def self.load(url, out_path, target_name = nil)
    FileUtils.mkdir_p out_path
    path = nil
    if target_name.nil?
      _path, name = File.split(url)
      path = File.join(out_path, File.basename(name))
      while File.exist?(path)
        ext = File.extname(name)
        base = File.basename(name, ext)
        salt = name.crypt Time.now.hash.to_s
        name = "#{base}_#{salt}#{ext}"
        path = File.join(out_path, name)
      end
    else
      path = File.join(out_path, File.basename(target_name))
    end

    download(url, path, 0.3) do |step, total|
      bar ||= ProgressBar.new(total >> 10, :bar, :percentage)
      bar.increment! step >> 10
    end
  end
end
