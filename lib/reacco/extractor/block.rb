# Reacco::Extractor::Block [class]
# An extractor block.
#
module Reacco
  class Extractor
    class Block
      # body [method]
      # Returns the body text as a raw string.
      attr_reader :body

      # title [method]
      # Returns the title of the block.
      attr_reader :title
      attr_reader :type
      attr_reader :parent
      attr_reader :args

      def initialize(options)
        @body        = options[:body]
        @type        = options[:type] && options[:type].downcase
        @args        = options[:args]
        @title       = options[:title]
        @parent      = options[:parent]
        @tag         = options[:tag]
        @source_line = options[:source_line]
        @source_path = options[:source_path]
      end

      # children [method]
      # Returns an array of child blocks.
      def children
        @children ||= Array.new
      end

      # << [method]
      # Adds a block to it's children.
      def <<(blk)
        children << blk
      end

      def raw_html
        Reacco.markdown.render(@body)
      end

      # Nokogiri node.
      def doc
        @doc ||= Nokogiri::HTML(raw_html)
      end

      def transform!
        # Create heading.
        name = @tag
        node = Nokogiri::XML::Node.new(name, doc)
        node['class'] = 'api'
        node.content  = title

        # Add '(args)'.
        if args
          span = Nokogiri::XML::Node.new("span", doc)
          span['class'] = 'args'
          span.content = args
          node.add_child span
        end

        # Add '(class method)'.
        span = Nokogiri::XML::Node.new("span", doc)
        span['class'] = 'type'
        span.content = type
        node.add_child Nokogiri::XML::Text.new(' ', doc)
        node.add_child span

        # Add heading.
        doc.at_css('body>*:first-child').add_previous_sibling node
        doc
      end

      # to_html [method]
      # Returns the raw HTML to be included in the documentation.
      def to_html
        @to_html ||= transform!.at_css('body').inner_html
      end
    end
  end
end
