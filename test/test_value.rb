# encoding: UTF-8
require 'minitest/autorun'
require './lib/pyer/options.rb'

class TestValue < Minitest::Test
  def test_simple_value1
    args = ['-i', '123']
    opts = Options.parse(args) do
      value 'id', 'Identification'
    end
    assert_equal(opts.id, '123')
  end

  def test_simple_value2
    args = ['--id', '123']
    opts = Options.parse(args) do
      value 'id', 'Identification'
    end
    assert_equal(opts.id, '123')
  end

  def test_simple_good_short_option
    args = ['-i', '123']
    opts = Options.parse(args) do
      value 'id=ID', 'Identification'
    end
    assert_equal(opts['id=ID'], '123')
  end

  def test_simple_bad_long_option
    args = ['--id', '123']
    assert_raises(Pyer::UnknownOptionError) do
      Options.parse(args) do
        value 'id=ID', 'Identification'
      end
    end
  end

  def test_simple_bad_value2
    args = ['--id=123', '-v']
    assert_raises(Pyer::UnknownOptionError) do
      Options.parse(args) do
        value 'id=ID', 'Identification'
        flag  'verbose', 'Enable verbose mode'
      end
    end
  end

  def test_missing_option
    args = ['--name', 'Pierre']
    opts = Options.parse(args) do
      value 'name', 'Enter your name'
      value 'id', 'Enter your ID'
    end
    refute(opts.id?)
  end

  def test_missing_option_is_nil
    args = ['--name', 'Pierre']
    opts = Options.parse(args) do
      value 'name', 'Enter your name'
      value 'id', 'Enter your ID'
    end
    assert_nil(opts[:id])
  end

  def test_valid_argument
    args = ['--name', 'Pierre']
    opts = Options.parse(args) do
      value 'name', 'Enter your name'
    end
    assert_equal(opts[:name], 'Pierre')
  end

  def test_undefined_argument
    args = ['-v']
    opts = Options.parse(args) do
      value 'name', 'Enter your name'
      flag 'verbose', 'Enable verbose mode'
    end
    refute(opts.name?)
  end

  def test_missing_argument
    args = ['--name']
    assert_raises(Pyer::MissingArgumentError) do
      Options.parse(args) do
        value 'name', 'Enter your name'
      end
    end
  end

  def test_invalid_argument
    args = ['--name', '-v']
    assert_raises(Pyer::InvalidArgumentError) do
      Options.parse(args) do
        value 'name', 'Enter your name'
        flag 'verbose', 'Enable verbose mode'
      end
    end
  end
end
