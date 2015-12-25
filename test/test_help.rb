# encoding: UTF-8
require 'minitest/autorun'
require './lib/pyer/options.rb'

class TestHelp < Minitest::Test

  def test_help
    args = ['-v']
    opts = Options.parse(args) do
      flag 'verbose', 'Enable verbose mode'
    end
    assert(opts.help.is_a? String)
  end
end
