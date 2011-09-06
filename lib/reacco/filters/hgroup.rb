module Reacco
  module Filters
    module Hgroup
      # Wraps the first headings into an <hgroup>.
      def wrap_hgroup(html)
        nodes = Array.new
        html.css('body>*').each { |node|
          # Consume all headings.
          if %w(h1 h2 h3 h4 h5 h6).include?(node.name)
            nodes << node.to_s
            node.remove

          # Once the headings stop, dump them into an <hgroup>.
          # Ah, and eat an <hr> if there is one.
          else
            node.before("<hgroup class='header'>#{nodes.join('')}</hgroup>")  if nodes.any?
            node.remove  if node.name == 'hr'
            break
          end
        }

        html
      end
    end
  end
end
