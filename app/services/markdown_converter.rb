require './lib/kramdown/document_sections'
require './lib/kramdown/converter/odin_html'

class MarkdownConverter
  def initialize(document)
    @document = FrontMatterParser::Parser.new(:md).call(document)
  end

  def as_html
    markdown = document.content
    sections = Kramdown::DocumentSections.new(markdown).all_sections

    if sections.any?
      sections.map { |section| parse_with_github_flavored_markdown(section.content) }.join
    else
      parse_with_github_flavored_markdown(markdown)
    end
  end

  private


end
