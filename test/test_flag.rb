# encoding: UTF-8
require 'minitest/autorun'
require './lib/pyer/options.rb'

class TestFlag < Minitest::Test

  def test_simple_option1
    args = ['-i']
    opts = Options.parse(args) do
      flag 'id', 'Identification'
    end
    assert(opts.id?)
  end

  def test_simple_option2
    args = ['--id']
    opts = Options.parse(args) do
      flag 'id', 'Identification'
    end
    assert(opts.id?)
  end

  def test_simple_option3
    args = ['-i']
    opts = Options.parse(args) do
      flag '--id', 'Identification'
    end
    assert(opts.id?)
  end

  def test_option_with_block
    args = ['-d']
    dbg = false
    opts = Options.parse(args) do
      flag 'debug', 'Enable debug mode' do
        dbg = true
      end
    end
    assert(opts.debug)
    assert(dbg)
  end

  def test_true_flag1
    args = ['-v']
    opts = Options.parse(args) do
      flag 'verbose', 'Enable verbose mode'
    end
    assert(opts.verbose?)
  end

  def test_true_flag2
    args = ['-v']
    opts = Options.parse(args) do
      flag 'verbose', 'Enable verbose mode'
    end
    assert(opts[:verbose])
  end

  def test_false_flag1
    args = ['-d']
    opts = Options.parse(args) do
      flag 'debug', 'Enable debug mode'
      flag 'verbose', 'Enable verbose mode'
    end
    refute(opts.verbose?)
  end

  def test_false_flag2
    args = ['-d']
    opts = Options.parse(args) do
      flag 'debug', 'Enable debug mode'
      flag 'verbose', 'Enable verbose mode'
    end
    refute(opts[:verbose])
  end

  def test_unknown_flag1
    args = ['-v']
    opts = Options.parse(args) do
      flag 'verbose', 'Enable verbose mode'
    end
    refute(opts.dummy?)
  end

  def test_unknown_flag2
    args = ['-v']
    opts = Options.parse(args) do
      flag 'verbose', 'Enable verbose mode'
    end
    assert(opts[:dummy].nil?)
  end

  def test_wrong_number_of_arguments_of_option1
    # Help string is mandatory
    args = ['-v']
    assert_raises(ArgumentError) do
      Options.parse(args) do
        flag 'verbose'
      end
    end
  end

  def test_wrong_number_of_arguments_of_option2
    args = ['-v']
    assert_raises(ArgumentError) do
      Options.parse(args) do
        flag 'verbose', 'Enable verbose mode', 'extra'
      end
    end
  end

  def test_unknown_option
    args = ['--option', '-v']
    assert_raises(Pyer::UnknownOptionError) do
      Options.parse(args) do
        flag 'help', 'Show some help'
        flag 'verbose', 'Enable verbose mode'
      end
    end
  end

  def test_mix_option
    args = ['-verbose'] # is not allowed
    assert_raises(Pyer::InvalidOptionError) do
      Options.parse(args) do
        flag 'help', 'Show some help'
        flag 'verbose', 'Enable verbose mode'
      end
    end
  end

  def test_short_option
    args = ['-v']
    opts = Options.parse(args) do
      flag 'help', 'Show some help'
      flag 'verbose', 'Enable verbose mode'
    end
    assert(opts.verbose?)
  end

  def test_long_option
    args = ['--verbose']
    opts = Options.parse(args) do
      flag 'help', 'Show some help'
      flag 'verbose', 'Enable verbose mode'
    end
    assert(opts.verbose?)
  end
end
