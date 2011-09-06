module Reacco
  class Readme
    def initialize(options={})
      @file    = options.delete(:file)  if options[:file]
      @options = options
    end
    
    # The path to the README file.
    def file
      @file ||= (Dir['README.*'].first || Dir['readme.*'].first || Dir['README'].first)
    end

    def file=(file)
      @file = file
    end

    # The switches, like 'literate' and 'hgroup'. Returns an array of strings.
    def switches
      @options.keys.map { |k| k.to_s }
    end

    def exists?
      file && File.exists?(file)
    end

    # Returns raw Markdown markup.
    def raw
      @raw ||= File.read(file)
    end

    # Returns a string of the title of the document (the first h1).
    def title
      @title ||= begin
        h1 = (h1 = raw_html.at_css('h1')) && h1.text
        h1 || File.basename(Dir.pwd)
      end
    end

    # Returns HTML as a Nokogiri document.
    def raw_html(options={})
      @raw_html ||= begin
        md   = markdown.render(raw)
        html = Nokogiri::HTML(md)

        html = pre_lang(html)
        html = heading_id(html)
        html = wrap_hgroup(html)
        html = move_pre(html)       if @options[:literate]
        html = brief_first_p(html)
        html = section_wrap(html)   if @options[:sections]

        html
      end
    end

    # Returns body's inner HTML.
    def html
      raw_html.at_css('body').inner_html
    end

    # Returns the GitHub URL, or nil if not applicable.
    def github
      "https://github.com/#{@options[:github]}"  if @options[:github]
    end

    # Returns locals for the template.
    def locals
      { :title      => title,
        :body_class => switches.join(' '), 
        :github     => github }
    end

  private
    include Filters::Brief
    include Filters::Sections
    include Filters::Hgroup
    include Filters::Literate
    include Filters::PreLang
    include Filters::HeadingID

    # Returns the Markdown processor.
    def markdown
      Redcarpet::Markdown.new(Redcarpet::Render::HTML,
        :fenced_code_blocks => true)
    end

    # Turns text into a slug.
    # "Install instructions" => "install_instructions"
    def slugify(str)
      str.downcase.scan(/[a-z0-9\-]+/).join('_')
    end
  end
end
