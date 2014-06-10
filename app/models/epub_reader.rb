class EpubReader

  attr_reader :file, :book, :xhtml_xml_resources, :title, :valid, :authors
  attr_accessor :xml_document, :text_array, :chapter_node, :node_array, :errors

  def initialize(file)

    @file = file
    @book = EPUB::Parser.parse(file)
    

    @xhtml_xml_resources = @book.resources.select { |resource| resource.media_type.include?("xhtml+xml") }
    
    # proc items are invoked in the search for the staring point node
    @search_items = ['CHAPTER', 'BOOK ONE', 'FIRST BOOK']
    @search_for_node = Proc.new { |element, search_term|
      @xml_document.css(element).find { |node| node.text.include?(search_term) }
    }
    
    # These attributes are set at initialization via set_text_and_node_values
    @text_array = [ ]
    @node_array = [ ]

    search_for_chapter_heading
    
    begin
      @valid = true
      raise "unable to identify chapter starting point" unless @chapter_node
      # raise "invalid epub format" unless epub_is_valid?

      populate_text_and_node_arrays

      @title = book.metadata.title
      @authors = book.metadata.creators.map { |creator| creator.content }
    rescue
      @valid = false
    end
  end

  def search_for_chapter_heading
    @xml_document = Nokogiri::XML(@xhtml_xml_resources[0].read)
    i = 1
    # search all the header tags until you find a chapter
    until i == 5 || @chapter_node
      @chapter_node = set_chapter_node_with_chapter_text("h" + i.to_s)
      i += 1
    end
  end

  def populate_text_and_node_arrays
    # from the chapter, look forward in the document and add nodes to the node array until you enter the body of the document
    until @chapter_node.previous_sibling.name == ('p') && @chapter_node.previous_sibling.text.include?("." || "!" || "?")
      @node_array << @chapter_node
      @text_array << @chapter_node.text
      @chapter_node = @chapter_node.next_sibling
    end
    update_text_array_for_only_first_sentence
  end

  def update_text_array_for_only_first_sentence
    first_sentence = identify_first_sentence_in_final_node
    length = @text_array.length
    @text_array[length - 1] = first_sentence
  end

  def identify_first_sentence_in_final_node
    first_sentence = grab_sentence_number(1)
    if add_additional_text?(first_sentence)
      first_sentence = update_first_sentence(first_sentence)
    end
    first_sentence
  end

  def grab_sentence_number(number)
    text = @node_array.last.text
    # setup stanford nlp parser in the pipeline variable
    pipeline =  StanfordCoreNLP.load(:tokenize, :ssplit)
    text = StanfordCoreNLP::Annotation.new(text)
    pipeline.annotate(text)
    # get the first sentence element from the array and transform to the new text
    text.get(:sentences).to_a[number - 1].to_s
  end

  def add_additional_text?(first_sentence)
    if first_sentence.length < 70
      true
    else
      false
    end
  end

  def update_first_sentence(first_sentence)
    i = 2
    while add_additional_text?(first_sentence)
      first_sentence = first_sentence + " " + grab_sentence_number(i)
      i + 1
    end
    first_sentence
  end

  def set_chapter_node_with_chapter_text(element)
    continue_search = 0
    node = nil
    until continue_search == @search_items.length || node != nil
      node = @search_for_node.call(element, @search_items[continue_search])
      continue_search = continue_search + 1
    end
    node
  end

  # def epub_is_valid?
  #   epub = EpubValidator.check(@book)
  #   epub.valid? 
  # end



end