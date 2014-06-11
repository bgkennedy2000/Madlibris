class IntroductoryContent < ActiveRecord::Base
  attr_accessible :book_id
  belongs_to :book
  has_many :other_lines, dependent: :destroy
  has_many :first_lines, dependent: :destroy

  def self.create_from_book_and_reader(book, reader)
    intro = IntroductoryContent.new(book_id: book.id)
    true_line = intro.first_lines.build(true_line: true, text: reader.text_array.last)
    intro = OtherLine.create_lines_from_reader_and_intro(intro, reader)
    intro
  end

  def set_other_lines(other_lines_array)
    other_lines_array.each { |other_line| self.other_lines << other_line }
  end


end
