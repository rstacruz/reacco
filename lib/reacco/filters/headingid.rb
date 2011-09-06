module Reacco
  module Filters
    module HeadingID
      def heading_id(html)
        html.css('h1, h2, h3').each do |h|
          h['id'] = slugify(h.content)
        end

        html
      end

    private
      # Turns text into a slug.
      # "Install instructions" => "install_instructions"
      def slugify(str)
        str.downcase.scan(/[a-z0-9\-]+/).join('_')
      end
    end
  end
end
