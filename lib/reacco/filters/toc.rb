module Reacco
  module Filters
    module TOC
      def make_toc(contents)
        aside = Nokogiri::XML::Node.new('aside', contents)
        aside['id'] = 'toc'

        # Header
        title = (h1 = contents.at_css('h1')) && h1.text || File.basename(Dir.pwd)
        aside.inner_html = "#{aside.inner_html}<h1>#{title}</h1>"

        contents.xpath('//body/section').each { |tag|
          aside.inner_html = "#{aside.inner_html}#{make_section tag}"
        }

        contents.at_css('body').add_child aside

        contents
      end

      def linkify(h)
        href = slugify(h.content)
        "<a href='##{href}'>#{h.inner_html}</a>"
      end

      def make_section(section)
        h     = section.at_css('h1, h2, h3')
        return ''  unless h
        level = h.name[1]  # 1 | 2 | 3
        return ''  unless %w(1 2 3).include?(level)
        name  = h.content.strip

        out = case level
        when "1"
          [ "<h2>#{linkify h}</h2>",
            section.css('section.h2').map { |s| make_section s }
          ]
        when "2"
          [ "<nav class='level-#{level}'>",
            "<h3>#{linkify h}</h3>",
            "<ul>",
            section.css('section.h3').map { |s| make_section s },
            "</ul>",
            "</nav>"
          ]
        when "3"
          [ "<li>#{linkify h}</li>" ]
        end

        out.flatten.join "\n"
      end
    end
  end
end
