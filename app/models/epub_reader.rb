class EpubReader
  attr_reader :file, :book, :xhtml_xml_resources
  attr_accessor :xml_document, :text_array, :chapter_node

  def initialize(file)
    @file = file
    @book = EPUB::Parser.parse(file)
    @xhtml_xml_resources = @book.resources.select { |resource| resource.media_type.include?("xhtml+xml") }
    @text_array = [ ]
  end

  def search_for_chapter_heading
    @xml_document = Nokogiri::XML(@xhtml_xml_resources[0].read)
    i = 1
    until i == 5 || @chapter_node
      set_chapter_node_with_chapter_text("h" + i.to_s)
      i += 1
    end
    populate_text_array
  end

  def populate_text_array
    until @chapter_node.previous_sibling.text.include?('.')
      @text_array << @chapter_node.text
      @chapter_node = @chapter_node.next_sibling
    end
  end

  def set_chapter_node_with_chapter_text(element)
    @chapter_node = @xml_document.css(element).find { |node| node.text.include?('CHAPTER') }
  end



end