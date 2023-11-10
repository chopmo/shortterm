class Cache
  def self.read_through(key, bypass_cache: false)
    filename = "tmp/#{key}"
    if File.exists?(filename) && !bypass_cache
      content = File.read(filename)
    else
      content = yield
      File.write(filename, content)
    end
    content
  end
end
