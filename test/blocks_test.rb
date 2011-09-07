require File.expand_path('../test_helper', __FILE__)

class BlocksTest < UnitTest
  setup do
    @ex = Reacco::Extractor.new(Dir[root 'lib/**/*.rb'])
  end

  should "extract comments with parents properly" do
    # From Reacco.root
    block = @ex.blocks.detect { |blk| blk.title == "root" && blk.type == "class method" }
    assert ! block.nil?

    assert block.parent
    assert block.parent.title == "Reacco"
    assert block.parent.type  == "module"
  end

  should "htmlize properly" do
    block = @ex.blocks.detect { |blk| blk.title == "root" && blk.type == "class method" }
    p block.to_html
  end
end
