class FileItem
  include DataMapper::Resource

  property :id,         Serial
  property :item_id,    Integer, required: true
  property :url,        String, required: true
  property :path,       FilePath
  property :loaded_at,  DateTime
  property :created_at, DateTime
  property :md5sum,     String, length: 32, default: ->(r, p) { Digest::MD5.hexdigest(r.path.read) if r.path }

  belongs_to :item

end