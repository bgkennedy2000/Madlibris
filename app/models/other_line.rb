class OtherLine < ActiveRecord::Base
  attr_accessible :kind, :text, :introductory_content_id
  validates :text, presence: true
  # validates :introductory_content_id, presence: true
  validates :kind, inclusion: { in: ["heading", "sub-heading"] }

  belongs_to :introductory_content

  def self.create_lines_from_reader_and_intro(intro, reader)
    nodes_to_look_at = reader.node_array[0..(reader.node_array.length - 2)]
    nodes_to_look_at.each do |node|
      if self.text_not_eq_to?(node.text, ["", "\n", "\n\n"])
        heading_tag = heading_tag || node.name
        other_line = intro.other_lines.build(text: node.text)
        other_line.set_kind(node, heading_tag)
      end
    end
    intro
  end

  def set_kind(xml_node, heading_tag)
    if xml_node.name == heading_tag
      self.kind = "heading"
    else
      self.kind = "sub-heading"
    end
  end

  def self.text_not_eq_to?(text, array)
    truth_array = array.map { |text_to_compare| text_to_compare == text }
    if truth_array.include?(true)
      false
    else
      true
    end
  end

end
