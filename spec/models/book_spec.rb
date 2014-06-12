require 'spec_helper'

describe Book do
  
  describe "self.create_and_set_attributes(reader, google_data)" do

    before(:each) do
      @reader = EpubReader.new('public/gutenberg/pg58.epub')
    end

    it "takes some data and a reader and produces a book wth an introduction, other lines and first lines" do 

      @book = Book.create_and_set_attributes(@reader, ["fake google description", "fake google image url"])

      expect(@book).to be_a Book
      expect(@book.introductory_content).to be_a IntroductoryContent
      expect(@book.first_lines).to be_a Array
      expect(@book.other_lines).to be_a Array
      expect(@book.first_lines.empty?).to eq false
      expect(@book.first_lines.empty?).to eq false
      @book.first_lines.each { |output_element| expect(output_element).to be_a FirstLine}
      @book.other_lines.each { |output_element| expect(output_element).to be_a OtherLine}
    end
  end

  describe "Book.last_names_match?(array_of_last_names, array_of_potential_author_last_names)" do
    it "takes two arrays of names and determines if they have the same last names" do
      
      array1 = ["Harris", "Kennedy", "Laden", "Sulemanji"]
      array2 = ["Kennedy", "Laden", "Sulemanji", "Harris"]
      result = Book.last_names_match?(array1, array2)
      expect(result).to eq true
    end
  end

  describe "Book.correct_description_and_image(correct_index_array, descriptions_array, images_url_array)" do

    it "finds the first occurance in the google data which has both an image_url and a description" do
      correct_index_array = [1, 2]
      descriptions_array = [nil, nil, "valid description1", nil ]
      images_url_array = ["valid image_url1", "valid image_url2", "valid image_url3", "valid image_url4"]

      result = Book.correct_description_and_image(correct_index_array, descriptions_array, images_url_array)

      expect(result).to be_a Array
      expect(result).to eq ["valid description1", "valid image_url3"]

    end
  end

  describe "Book.match_epub_to_google_data(epub_reader, authors_array, descriptions_array, images_url_array)" do 

    it "returns an array of two items: the first is a description and the second is an image_url" do


    end
  end



  describe "Book.find_index_of_authors_array(epub_reader, authors_array)" do
    it "it returns an index of the reader.author in the authors_array" do 

      @reader = EpubReader.new('public/gutenberg/snowy.arsc.alaska.edu/gutenberg/cache/generated/7865/pg7865.epub')
      authors_array = ["Juliana Horatia Ewing",
                       "Juliana Horatia Gatty Ewing, Horatia K. F. Gatty Eden",
                       "Juliana Horatia Gatty Ewing",
                       "Joanne Shattock",
                       "Juliana Horatia Gatty Ewing",
                       "J. H. Ewing",
                       "Homer",
                       "Juliana Horatia Gatty Ewing",
                       "Frederick Wilse Bateson",
                       "Horatio Juliana Ewing",
                       "Terry Seymour",
                       "Walter Scott",
                       "Juliana Horatia Gatty Ewing",
                       "Almira George Plympton",
                       "Juliana Horatia Ewing",
                       "Kay Boardman, Shirley Jones",
                       "Charles Dudley Warner",
                       "Judie Newman",
                       "Juliana Horatia Gatty Ewing",
                       "Library of Congress. Copyright Office",
                       "Florence Nightingale",
                       "Dorothea Flothow",
                       "Juliana Horatia Ewing",
                       "Louisa May Alcott",
                       "Chris McMahen",
                       "Susan Coolidge",
                       "Jean-Pascal Benassy",
                       "W. W. Jacobs",
                       "David Garnett",
                       "Stewart Edward White",
                       "John Ruskin",
                       "Alexander Aaronsohn",
                       "Gustavo Adolfo Bécquer",
                       "Jeanne Warren Lindsay"]
      index = Book.find_index_of_authors_array(@reader, authors_array)
      expect(index).to be_a Array
      expect(index).to eq [0, 2, 4, 5, 7, 9, 12, 14, 18, 22]
    end
  end
end
