class FileItem
  include DataMapper::Resource

  property :id,         Serial
  property :item_id,    Integer, required: true
  property :url,        URI, required: true
  property :path,       String, length: 500
  property :loaded_at,  DateTime
  property :created_at, DateTime
  property :md5sum,     String, length: 32

  belongs_to :item

  def load!
    unless @path && @md5sum == Digest::MD5.hexdigest(File.read(@path))
      name = "item_#{item.published_at.strftime('%Y.%m.%d')}_#{@id}#{@url.extname}"
      path = CustomDownload.load(@url, File.join(App.root, 'out'), name)
      if path
        update(
          path: path,
          md5sum: Digest::MD5.hexdigest(File.read(path)),
          loaded_at: DateTime.now
        )
      end
    else
      date = item.published_at.strftime('%Y.%m.%d')
      name = File.relative_path(App.root, @path)
      puts "Already loaded at #{date} to file: #{name}"
    end
  end
end