# ## Reacco::Readme [class]
# A readme file.
#
# #### Instanciating
# This is often instanciated by the `reacco` executable, but you can instantiate
# it yourself like so. It's assumed the the base dir will be the current working
# directory.
#
#     readme = Reacco::Readme.new
#     readme = Reacco::Readme.new [OPTIONS HASH]
#
# #### Options
# Avaiable options are *(all are optional)*:
#
#  * `file` - String *(the filename of the README file)*
#  * `literate` - Boolean
#  * `toc` - Boolean
#
module Reacco
  class Readme
    def initialize(options={})
      @file    = options.delete(:file)  if options[:file]
      @options = options
    end
    
    # ### file [method]
    # The path to the README file. Returns `nil` if not available.
    #
    #     readme.file      #=> "README.md"
    #     
    def file
      @file ||= (Dir['README.*'].first || Dir['readme.*'].first || Dir['README'].first)
    end

    def file=(file)
      @file = file
    end

    # ### switches [method]
    # The switches, like *literate* and *toc*. Returns an array of strings.
    #
    #     readme.switches  #=> [ 'literate' ]
    def switches
      @options.keys.map { |k| k.to_s }
    end

    # ### exists? [method]
    # Returns true if the file (given in the constructor) exists.
    #
    #     readme = Readme.new :file => 'non-existent-file.txt'
    #     readme.exists?
    #     #=> false (maybe)
    #
    def exists?
      file && File.exists?(file)
    end

    # ### raw [method]
    # Returns raw Markdown markup.
    #
    #     readme.raw
    #     #=> "# My project\n#### This is my project\n\n..."
    #
    def raw
      @raw ||= File.read(file)
    end

    # ### title [method]
    # Returns a string of the title of the document. Often, this is the first
    # H1, but if that's not available, then it is inferred from the current
    # directory's name.
    #
    #     readme.title
    #     #=> "My project"
    #
    def title
      @title ||= begin
        h1 = (h1 = doc.at_css('h1')) && h1.text
        h1 || File.basename(Dir.pwd)
      end
    end

    def title?
      title.to_s.size > 0
    end

    # ### raw_html [method]
    # Returns a string of the raw HTML data built from the markdown source.
    # This does not have the transformations applied to it yet.
    #
    #     readme.raw_html
    #     #=> "<h1>My project</h1>..."
    #
    def raw_html
      @raw_html ||= markdown.render(raw)
    end

    def raw_html=(str)
      @raw_html = str
    end

    # ### inject_api_block [method]
    # Adds an API block. Takes an `html` argument.
    #
    def inject_api_block(html)
      @api_blocks = "#{api_blocks}\n#{html}\n"
    end

    def api_blocks
      @api_blocks ||= ""
    end

    # ### doc([options]) [method]
    # Returns HTML as a Nokogiri document with all the transformations applied.
    #
    #     readme.doc
    #     #=> #<Nokogiri::HTML ...>
    #
    def doc(options={})
      @doc ||= begin
        add_api(api_blocks)
        html = Nokogiri::HTML(raw_html)

        html = pre_lang(html)
        html = heading_id(html)
        html = wrap_hgroup(html)
        html = move_pre(html)       if @options[:literate]
        html = brief_first_p(html)
        html = section_wrap(html)
        html = make_toc(html)       if @options[:toc]

        html
      end
    end

    # ### html [method]
    # Returns body's inner HTML *with* transformatinos.
    #
    #     readme.raw_html
    #     #=> "<h1>My project</h1>..."
    #
    def html
      doc.at_css('body').inner_html
    end

    # ### github [method]
    # Returns the GitHub URL, or nil if not applicable.
    #
    #     readme.github
    #     #=> "https://github.com/rstacruz/reacco"
    #
    def github
      "https://github.com/#{@options[:github]}"  if @options[:github]
    end

    # ### locals [method]
    # Returns a hash with the local variables to be used for the ERB template.
    #
    #     readme.locals
    #     #=> { :title => 'My project', ... }
    #
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
    include Filters::TOC

    # Puts `blocks` inside `raw_html`.
    def add_api(blocks)
      re1 = %r{^.*api reference goes here.*$}i
      re2 = %r{^.*href=['"]#api_reference['"].*$}i

      if raw_html =~ re1
        raw_html.gsub! re1, blocks
      elsif raw_html =~ re2
        raw_html.gsub! re2, blocks
      else
        self.raw_html = "#{raw_html}\n#{blocks}"
      end
    end

    # ### markdown [private method]
    # Returns the Markdown processor.
    #
    #     markdown.render(md)
    #
    def markdown
      Reacco.markdown
    end

    # ### slugify [private method]
    # Turns text into a slug.
    #
    #     "Install instructions" => "install_instructions"
    #
    def slugify(str)
      str.downcase.scan(/[a-z0-9\-]+/).join('_')
    end
  end
end
