class TestTask
  def self.create_file(ext="")
    file = File.new Rails.root.join("log","test#{Time.now.to_i}.#{ext}" ), "w"
    file.puts "hello"
  end

end