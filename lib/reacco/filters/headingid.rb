module Reacco
  module Filters
    module HeadingID
      def heading_id(html)
        html.css('h1, h2, h3').each do |h|
          h['id'] = slugify(h.content)
        end

        html
      end
    end
  end
end
