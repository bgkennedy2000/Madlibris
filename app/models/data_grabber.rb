class DataGrabber
  attr_accessor :source
  attr_reader :gutenberg_path, :gutenberg_source_file
  # validate :source, :inclusion => {:in => ["gutenberg, google_books"]}

  def initialize(source) 
    @source = source
    @gutenberg_path = "public/gutenberg/"
    @gutenberg_source_file = @gutenberg_path + "epub_links.txt"
  end

  def find_gutenberg_epub
    url = get_gutenberg_url
    save_gutenberg_epub_file(url) 
  end

  def save_gutenberg_epub_file(url)
    response = get_gutenberg_response(url)
    file_name = gutenberg_file_name(url)
    File.open(@gutenberg_path + file_name, "wb") { |file| file.write response.parsed_response }
    epub_is_valid?(file_name, url)
  end

  def epub_is_valid?(filename, url)
    epub = EpubValidator.check(@gutenberg_path + filename)
    if epub.valid? 
      true
    else
      File.open(@gutenberg_path + "error_log", "w") { |file| file.write url + " fetched an invalid epub file" }
      raise "invalid epub file was fetched."
    end
  end

  def get_gutenberg_response(url)
    response = HTTParty.get(url)
    if response.code == 200
      response
    else
      File.open(@gutenberg_path + "error_log", "w") { |file| file.write url + " was not gotten w/ code 200" }
      raise "Problem fetching gutenberg url.  See #{@gutenberg_path}error_log for more info."
    end
  end

  def gutenberg_file_name(url)
    string_with_ending = "pg" + url.split("/").pop 
    index = string_with_ending.index(".noimages")
    string_with_ending.slice(0.. index - 1 ) # conforms to project gutenberg file naming conventions
  end

  def get_gutenberg_url
    line_count = `wc -l #{@gutenberg_source_file}`.to_i
    line_chosen = 1 + rand(line_count)
    line = `awk 'NR==#{line_chosen} {print; exit}' #{@gutenberg_source_file}`
    start_index = line.index('http://')
    end_index = line.index('.epub.noimages') + '.epub.noimages'.length - 1
    url = line.slice(start_index.. end_index)
    File.open(@gutenberg_path + "error_log", "w") { |file| file.write url + " is next to be fetched" }
    url
  end

  def self.search_for_gutenberg_files(search_location, output_location)
    `find #{search_location} -name '*.epub' >> #{output_location}/epub_list.txt`
  end



end