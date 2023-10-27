class Cache
  def self.read_through(filename)
    if File.exists?(filename)
      content = File.read(filename)
    else
      puts "Caching content in #{filename}"
      content = yield
      File.write(filename, content)
    end
    content
  end
end
