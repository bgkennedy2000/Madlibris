require 'spec_helper'

describe OtherLine do
  
  describe "self.create_lines_from_reader_and_intro(intro, reader)" do
    it "takes an IntroductoryContent and a EpubReader and returns an intro with other lines" do 
      reader = EpubReader.new('public/gutenberg/pg58.epub')
      intro = IntroductoryContent.new(book_id: 2)
      output = OtherLine.create_lines_from_reader_and_intro(intro, reader)

    expect(output).to be_a IntroductoryContent
    expect(output.other_lines).to be_a Array
    output.other_lines { |output_element| expect(output_element).to be_a OtherLine}
    
    end
  end
end
