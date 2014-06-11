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

    # it "if the first line text is nil, returns false" do 

    #   @book = Book.create_and_set_attributes(@reader, ["fake google description", "fake google image url"])

    #   expect(@book).to be_a Book
    #   expect(@book.introductory_content).to be_a IntroductoryContent
    #   expect(@book.first_lines).to be_a Array
    #   expect(@book.other_lines).to be_a Array
    #   expect(@book.first_lines.empty?).to eq false
    #   expect(@book.other_lines.empty?).to eq false
    #   @book.first_lines.each { |output_element| expect(output_element).to be_a FirstLine}
    #   @book.other_lines.each { |output_element| expect(output_element).to be_a OtherLine}
    # end
  end
end



