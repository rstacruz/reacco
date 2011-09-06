module Reacco
  module Filters
    module Literate
      # Moves pre's after headers.
      def move_pre(html)
        anchor   = nil
        position = nil

        html.css('body>*').each_cons(2) { |(node, nxt)|
          # Once we find the <pre>, move it.
          if node.name == 'pre' && anchor && anchor != node && !(node['class'].to_s =~ /full/)
            node.after "<br class='post-pre'>"

            nxt['class']    = "#{nxt['class']} after-pre"  if nxt
            node['class']   = "#{node['class']} right"

            anchor.send position, node
            anchor = nil

          # If we find one of these, put the next <pre> after it.
          elsif %w(h1 h2 h3 h4 pre).include?(node.name)
            anchor   = node
            position = :add_next_sibling

          # If we find one of these, put the <pre> before it.
          elsif node['class'].to_s.include?('after-pre')
            anchor   = node
            position = :add_previous_sibling
          end
        }

        html
      end
    end
  end
end
