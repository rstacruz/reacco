module Reacco
  module Filters
    module Hgroup
      # Puts everything before the first <hr> into an <hgroup>.
      def wrap_hgroup(html)
        nodes = Array.new
        html.css('body>*').each { |node|
          if node.name == 'hr'
            node.before("<hgroup class='header'>#{nodes.join('')}</hgroup>")
            node.remove
            break
          else
            nodes << node.to_s
            node.remove
          end
        }

        html
      end
    end
  end
end
