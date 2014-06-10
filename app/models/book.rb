class Book < ActiveRecord::Base
  attr_accessible :author, :image_url, :synopsis, :pre_first_line_content, :title, :source

  validates :author, presence: true
  validates :synopsis, presence: true
  validates :title, presence: true
  validates :image_url, presence: true
  validates :pre_first_line_content, presence: true
  validates :source, presence: true
  validate :author_and_title_unique?
  
  has_many :rounds
  has_many :first_lines, dependent: :destroy

#allows the storing of content as arrays, note first sentence is removed in the setter method
  def pre_first_line_content
    @pre_first_line_content.split('!@£$')
  end

  def pre_first_line_content=(text_array)
    #save all but the last element in the array
    @pre_first_line_content = text_array[0..-2].join('!@£$')
  end

  def author
    @author.split('!@£$')
  end

  def author=(authors_array)
    @author = authors_array.join('!@£$')
  end

#########

  def author_and_title_unique? 
    book_to_compare = Book.find_by_title(self.title)
    if book_to_compare
      if book_to_compare.author == self.author
        errors.add(:base, "a book already exists with this title and author")
      end 
    end
  end

  def self.build_from_gutenberg
    # file_list = self.find_epub_file('public/gutenberg')
    # for each item in file list, build_book_from_epub
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
    books = GoogleBooks.search(epub_reader.title)
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
    if correct_index = epub_reader.authors.index(authors_array[0])
      [descriptions_array[correct_index], images_url_array[correct_index]]
    else
      false
    end
  end

  def self.google_data_valid?(google_data)
    if google_data == false || google_data == nil 
      false
    elsif google_data[0].gsub(/\s+/, "") == "" || google_data[0].gsub(/\s+/, "") == nil || google_data[1].gsub(/\s+/, "") == "" || google_data[1].gsub(/\s+/, "") == nil
      false
    else 
      true
    end
  end

  def self.create_and_set_attributes(reader, google_data)
    book = self.new(title: reader.title, synopsis: google_data[0], image_url: google_data[1], source: reader.file )
    book.pre_first_line_content = reader.text_array
    book.author = reader.authors
    binding.pry
    book.save
    true_line = book.first_lines.build(true_line: true, text: reader.text_array.last)
    if book.id && true_line.save
      book
    else
      true_line.destroy
      book.destroy
      [book, true_line]
    end
  end

end
