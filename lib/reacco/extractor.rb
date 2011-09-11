#!/usr/bin/env ruby

require 'ostruct'
require 'fileutils'
module Reacco
  # Reacco::Extractor [class]
  # Extracts comments from list of files.
  #
  # #### Instantiating
  # Call the constructor with a list of files.
  #
  #     ex = Extractor.new(Dir['./**/*.rb'])
  #
  class Extractor
    autoload :Block, 'reacco/extractor/block'

    def initialize(files, root=nil, options={})
      @files = files.sort
      @root  = File.realpath(root || Dir.pwd)
    end

    # blocks [method]
    # Returns an array of `Block` instances.
    #
    #     ex.blocks
    #     ex.blocks.map { |b| puts "file: #{b.file}" }
    #
    def blocks
      @blocks ||= begin
        @files.map do |file|
          if File.file?(file)
            input = File.read(file)
            get_blocks(input, unroot(file))
          end
        end.compact.flatten
      end
    end

  private
    def unroot(fn)
      (File.realpath(fn))[@root.size..-1]
    end

    # get_blocks(str, [filename]) [private method]
    # Returns the documentation blocks in a given `str`ing.
    # If `filename` is given, it will be set as the *source_file*.
    #
    def get_blocks(str, filename=nil)
      arr    = get_comment_blocks(str)

      arr.map do |hash|
        block = hash[:block]

        # Ensure the first line matches.
        # This matches:
        #   "### name [type]"
        #   "## name(args) [type]"
        re = /^(\#{1,6}) (.*?) ?(\(.*?\))? ?(?:\[([a-z ]+)\])?$/
        block.first =~ re  or next

        blk = Extractor::Block.new \
          :type        => $4,
          :tag         => "h#{$1.strip.size}",
          :title       => $2,
          :args        => $3,
          :source_line => hash[:line] + block.size + 1,
          :source_file => filename,
          :body        => (block[1..-1].join("\n") + "\n")

        blk
    end.compact
    end

    # get_comment_blocks (private method)
    # Returns contiguous comment blocks.
    #
    # Returns an array of hashes that look like
    # `{ :block => [line1, line2...], :line => (line number) }`
    #
    def get_comment_blocks(str)
      chunks = Array.new
      i = 0

      str.split("\n").each_with_index { |s, line|
        if s =~ /^\s*(?:\/\/\/?|##?) ?(.*)$/
          chunks[i] ||= { :block => Array.new, :line => line }
          chunks[i][:block] << $1
        else
          i += 1  if chunks[i]
        end
      }

      chunks.compact
    end
  end
end
