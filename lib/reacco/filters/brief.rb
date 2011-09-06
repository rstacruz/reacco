module Reacco
  module Filters
    module Brief
      # Makes the first <p> a brief.
      def brief_first_p(html)
        p = html.at_css('body>p')
        p['class'] = "#{p['class']} brief"  if p
        html
      end
    end
  end
end
