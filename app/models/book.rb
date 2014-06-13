class Book < ActiveRecord::Base
  
  attr_accessible :image_url, :synopsis, :title, :source

  validates :synopsis, presence: true
  validates :title, presence: true
  validates :image_url, presence: true
  validates :source, presence: true
  validate :author_and_title_unique?
  
  has_many :rounds
  has_one :introductory_content, dependent: :destroy
  has_many :first_lines, through: :introductory_content
  has_many :other_lines, through: :introductory_content
  has_and_belongs_to_many :authors

  def author_and_title_unique? 
    book_to_compare = Book.find_by_title(self.title)

    # don't forget to put some code here
  end

  def self.build_from_gutenberg(source_file_of_paths)
    line_count = `wc -l #{source_file_of_paths}`.to_i
    i = 1
    while i < line_count
      path = `awk 'NR==#{i}  {print; exit}' public/gutenberg/epub_list.txt`
      path = path.chomp
      self.build_book_from_epub(path)
      i = i + 1
    end
  end

  def self.build_book_from_epub(file_path)
    reader = EpubReader.new(file_path)
    if reader.valid
      google_data = self.populate_info_from_google(reader)
      self.create_and_set_attributes(reader, google_data) if self.google_data_valid?(google_data)
    else
      false
    end
  end

  def self.populate_info_from_google(epub_reader)
    books = GoogleBooks.search(epub_reader.title, { count: 40 })
    if books.first
      authors_array = books.map { |book| book.authors }
      descriptions_array = books.map { |book| book.description }
      images_url_array = books.map { |book| book.image_link }
      correct_data_array = self.match_epub_to_google_data(epub_reader, authors_array, descriptions_array, images_url_array)
    else 
      false
    end
  end

  def self.match_epub_to_google_data(epub_reader, authors_array, descriptions_array, images_url_array)
    correct_index_array = self.find_index_of_authors_array(epub_reader, authors_array)
    if correct_index_array
      self.correct_description_and_image(correct_index_array, descriptions_array, images_url_array)
    else
      false
    end
  end

  def self.correct_description_and_image(correct_index_array, descriptions_array, images_url_array)
    tries = correct_index_array.length
    description_and_image_array = [ ]
    i = 0
    until (description_and_image_array[0] && description_and_image_array[1]) || i == tries
      description_and_image_array = [descriptions_array[correct_index_array[i]], images_url_array[correct_index_array[i]]]
      i = i + 1
    end
    description_and_image_array
  end

  def self.find_index_of_authors_array(epub_reader, authors_array)
    array_of_last_names = epub_reader.authors.collect do
      |author| 
      name = Namae.parse(author) 
      name[0].family if name[0]
    end
    authors_array.each_index.select do
      |i|
      potential_authors_array = authors_array[i].split(",")
      if potential_authors_array.length == epub_reader.authors.length
        array_of_potential_author_last_names = potential_authors_array.collect do 
          |author| 
          name = Namae.parse(author) 
          name[0].family if name[0]
        end
        boolean = self.last_names_match?(array_of_last_names, array_of_potential_author_last_names)
      else
        false
      end
    end
  end

  def self.last_names_match?(array_of_last_names, array_of_potential_author_last_names)
    length = array_of_last_names.length
    truth_array = [ ]
    i = 0
    length.times do
      truth_array << array_of_potential_author_last_names.include?(array_of_last_names[i])
      i = i + 1
    end
    if truth_array.include?(false)
      false
    else
      true
    end
  end

  def self.google_data_valid?(google_data)
    if google_data == false || google_data.include?(nil) || google_data.empty? 
      false
    elsif google_data[0].gsub(/\s+/, "") == "" || google_data[0].gsub(/\s+/, "") == nil || google_data[1].gsub(/\s+/, "") == "" || google_data[1].gsub(/\s+/, "") == nil
      false
    else 
      true
    end
  end

  def self.create_and_set_attributes(reader, google_data)
    book = self.new(title: reader.title, synopsis: google_data[0], image_url: google_data[1], source: reader.file )
    book.save
    book = self.create_dependent_models(book, reader, google_data)
    if book.save 
      book
    else
      book.destroy
    end
  end


  def self.create_dependent_models(book, reader, google_data)
    authors = reader.authors.map { |author| book.authors.build(name: author) }
    intro = IntroductoryContent.create_from_book_and_reader(book, reader)
    book.introductory_content = intro
    book
  end

end
