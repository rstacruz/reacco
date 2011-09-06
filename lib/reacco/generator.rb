module Reacco
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
