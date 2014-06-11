require 'spec_helper'

describe IntroductoryContent do
  describe "self.create_from_book_and_reader(book, reader)" do
    it "takes a book and reader and produces an IntroductoryContent with an array of first lines and and array other lines" do
      reader = EpubReader.new('public/gutenberg/pg58.epub')
      book = Book.new(title: reader.title, synopsis: "test synopsis", image_url: "fake image url", source: reader.file )
      book.save
      intro = IntroductoryContent.create_from_book_and_reader(book, reader)
      expect(intro).to be_a IntroductoryContent
      expect(intro.first_lines).to be_a Array
      expect(intro.other_lines).to be_a Array
      expect(intro.first_lines.empty?).to eq false
      expect(intro.other_lines.empty?).to eq false
      intro.first_lines.each { |output_element| expect(output_element).to be_a FirstLine}
      intro.other_lines.each { |output_element| expect(output_element).to be_a OtherLine}
    end
  end
end
