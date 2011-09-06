module Reacco
  module Filters
    module Sections
      # Wraps in sections.
      def section_wrap(html)
        %w(h1 h2 h3 h4 h5).each do |h|
          nodes = html.css(h)
          nodes.each do |alpha|
            # For those affected by --hgroup, don't bother.
            next  if alpha.ancestors.any? { |tag| tag.name == 'hgroup' }
            next  unless alpha.parent

            # Find the boundary, and get the nodes until that one.
            omega         = from_x_until(alpha, alpha.name)
            section_nodes = between(alpha, omega)

            # Create the <section>.
            section = Nokogiri::XML::Node.new('section', html)
            section['class'] = h
            alpha.add_previous_sibling(section)
            section_nodes.each { |tag| section.add_child tag }
          end
        end

        html
      end

    private
      def from_x_until(alpha, name)
        omega = nil
        n = alpha
        while true
          n = n.next_sibling
          break if n.nil? || n.name == name
          omega = n
        end

        omega
      end

      def between(first, last)
        nodes   = Array.new
        started = false

        first.parent.children.each do |node|
          started = true  if node == first
          break  if node == last
          nodes << node  if started
        end

        nodes
      end
    end
  end
end
