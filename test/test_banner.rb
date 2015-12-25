# encoding: UTF-8
require 'minitest/autorun'
require './lib/pyer/options.rb'

class TestBanner < Minitest::Test
  def test_one_banner
    args = ['-v']
    opts = Options.parse(args) do
      banner 'Banner'
      flag   'verbose', 'Enable verbose mode'
    end
    assert_equal(opts.banner, "Banner\n")
  end

  def test_two_banner
    args = ['-v']
    opts = Options.parse(args) do
      banner 'Line1'
      banner 'Line2'
      flag   'verbose', 'Enable verbose mode'
    end
    assert_equal(opts.banner, "Line1\nLine2\n")
  end
end
