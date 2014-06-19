class Book < ActiveRecord::Base
  
  attr_accessible :image_url, :synopsis, :title, :source, :pre_first_line_content

  validates :synopsis, presence: true
  validates :title, presence: true
  validates :image_url, presence: true
  validates :source, presence: true
  validates :source, uniqueness: true
  validates :title, uniqueness: true
  validates :title, length: { in: 0..255 }
  # validate :description_is_not_first_line
# create call back to prevent this situation from occuring
  
  
  has_many :rounds
  has_many :book_choices
  has_one :introductory_content, dependent: :destroy
  has_many :first_lines, through: :introductory_content
  has_many :other_lines, through: :introductory_content
  has_and_belongs_to_many :authors

  def description_is_not_first_line
    # if self.introductory_content
    # errors.add(:base, "first line and description are the same") 
  end

  def self.game_view(game, user)
    if game.needs_to_choose_book?(user)
      Book.all.sample(10)
    else 
      game.latest_round.try(:book)
    end
  end

  def self.build_from_gutenberg(source_file_of_paths)
    line_count = `wc -l #{source_file_of_paths}`.to_i
    i = 1
    while i < line_count
      path = `awk 'NR==#{i}  {print; exit}' public/gutenberg/epub_list.txt`
      path = path.chomp
      if self.no_book_has_path?(path)
        File.open("public/gutenberg/error_log", "w") { |file| file.write path + " is being put into a Book object next" }
        self.build_book_from_epub(path)
      end
      i = i + 1
    end
  end

  def self.no_book_has_path?(path)
    Book.find_by_source(path).nil?
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
    begin
      if book.save && book.still_valid?
        book
      else
        book.destroy
      end
    rescue
      book.destroy
    end
  end

  def still_valid?
    not_webster? && not_tredition? && not_millions? && not_pre_1923? && not_world_first? && long_enough?
  end

  def not_pre_1923?
    if self.synopsis.include?("This is a pre-1923 historical reproduction")
      false
    else
      true
    end
  end

  def not_tredition?
    if self.synopsis.include?("TREDITION CLASSICS")
      false
    else
      true
    end
  end

  def not_webster?
    if self.synopsis.include?("Webster's edition of this classic.")
      false
    else
      true
    end
  end

  def long_enough?
    if self.synopsis.length <= 200
      false
    else
      true
    end
  end

  def not_world_first?
    if self.synopsis.include?("Visit us online at www.1stWorldLibrary.ORG")
      false
    else
      true
    end
  end

  def not_millions?
    if self.synopsis.include?("www.million-books.com.")
      false
    else
      true
    end
  end

  def self.create_dependent_models(book, reader, google_data)
    authors = reader.authors.map { |author| book.authors.build(name: author) }
    intro = IntroductoryContent.create_from_book_and_reader(book, reader)
    book.introductory_content = intro
    book
  end

end
