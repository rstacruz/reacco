require 'nokogiri'
require 'redcarpet'
require 'tilt'
require 'ostruct'
require 'fileutils'

module Reacco
  extend self

  def root(*a)
    File.join File.expand_path('../../', __FILE__), *a
  end

  class Readme
    def file
      @file ||= (Dir['README.*'].first || Dir['readme.*'].first || Dir['README'].first)
    end

    def file=(file)
      @file = file
    end

    def initialize(options={})
      @file    = options.delete(:file)  if options[:file]
      @options = options
    end
    
    # The switches, like 'literate' and 'hgroup'
    def switches
      @options.keys.map { |k| k.to_s }
    end

    def exists?
      file && File.exists?(file)
    end

    # Returns raw Markdown.
    def raw
      @raw ||= File.read(file)
    end

    # The first h1.
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
        html = wrap_hgroup(html)    if @options[:hgroup]
        html = move_pre(html)       if @options[:literate]
        html = brief_first_p(html)  if @options[:brief]
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
    # Returns the Markdown processor.
    def markdown
      Redcarpet::Markdown.new(Redcarpet::Render::HTML,
        :fenced_code_blocks => true)
    end

    # Adds prettify classes.
    def pre_lang(html)
      html.css('pre').each { |pre| pre['class'] = "#{pre['class']} lang-#{pre['class']} prettyprint" }
      html
    end

    # Makes the first <p> a brief.
    def brief_first_p(html)
      p = html.at_css('body>p')
      p['class'] = "#{p['class']} brief"  if p
      html
    end

    # Wraps in sections.
    def section_wrap(html)
      %w(h1 h2 h3 h4 h5).each do |h|
        nodes = html.css(h)
        nodes.each do |alpha|
          # For those affected by --hgroup, don't bother.
          next  if alpha.ancestors.any? { |tag| tag.name == 'hgroup' }
          next  unless alpha.parent

          # Find the boundary, and get the nodes until that one.
          omega         = from_x_until(alpha, alpha.name)
          section_nodes = between(alpha, omega)

          # Create the <section>.
          section = Nokogiri::XML::Node.new('section', html)
          section['class'] = h
          alpha.add_previous_sibling(section)
          section_nodes.each { |tag| section.add_child tag }
        end
      end

      html
    end

    def from_x_until(alpha, name)
      omega = nil
      n = alpha
      while true
        n = n.next_sibling
        break if n.nil? || n.name == name
        omega = n
      end

      omega
    end

    def slugify(str)
      str.downcase.scan(/[a-z0-9\-]+/).join('_')
    end

    def between(first, last)
      nodes   = Array.new
      started = false

      first.parent.children.each do |node|
        started = true  if node == first
        break  if node == last
        nodes << node  if started
      end

      nodes
    end

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

  class Generator
    def initialize(readme, dir, template=nil, css=nil)
      @readme   = readme
      @dir      = dir
      @css      = css
      @template = template || Reacco.root('data')
    end

    # Returns the HTML contents.
    def html
      file = Dir["#{@template}/index.*"].first
      raise "No index file found in template path."  unless file

      tpl  = Tilt.new(file)
      out  = tpl.render({}, @readme.locals) { @readme.html }
    end

    # Writes to the output directory.
    def write!(&blk)
      yield "#{@dir}/index.html"
      write_to "#{@dir}/index.html", html
      copy_files &blk
      append_css   if @css
    end

    def template?
      File.directory?(@template) && Dir["#{@template}/index.*"].first
    end

    # Adds the CSS file to the style.css file.
    def append_css
      contents = File.read(@css)
      File.open("#{@dir}/style.css", 'a+') { |f| f.write "\n/* Custom */\n#{contents}" }
    end

    def copy_files(&blk)
      files = Dir.chdir(@template) { Dir['**/*'] }

      # For each of the template files...
      files.each do |f|
        next  if File.basename(f)[0] == '_'
        next  if File.fnmatch('index.*', f)
        ext = File.extname(f)[1..-1]

        fullpath = File.join @template, f

        # Try to render it with Tilt if possible.
        if Tilt.mappings.keys.include?(ext)
          contents = Tilt.new(fullpath).render
          outfile  = f.match(/^(.*)(\.[^\.]+)$/) && $1
        else
          contents = File.read(fullpath)
          outfile  = f
        end

        yield "#{@dir}/#{outfile}"
        write_to "#{@dir}/#{outfile}", contents
      end
    end

  private
    def write_to(path, data)
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'w') { |f| f.write data }
    end
  end
end

