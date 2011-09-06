module Reacco
  module Filters
    module PreLang
      # Adds prettify classes.
      def pre_lang(html)
        html.css('pre').each { |pre| pre['class'] = "#{pre['class']} lang-#{pre['class']} prettyprint" }
        html
      end
    end
  end
end
