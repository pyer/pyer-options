# encoding: UTF-8
require 'minitest/autorun'
require './lib/pyer/options.rb'

class TestCommand < Minitest::Test
  def test_command
    args = ['get']
    opts = Options.parse(args) do
      command 'get', 'Get value'
      command 'set', 'Set value'
      command :put,  'Put value'
      flag    'verbose', 'Enable verbose mode'
      value   'name', 'Name of the value'
    end
    assert_equal(opts.command, 'get')
  end

  def test_command_with_block
    args = ['get']
    opts = Options.parse(args) do
      command 'get', 'Get value' do
        'GET callback'
      end
      command 'set', 'Set value' do
        'SET callback'
      end
      flag   'verbose', 'Enable verbose mode'
    end
    assert_equal(opts.callback, 'GET callback')
  end

  def test_invalid_command
    args = ['get']
    assert_raises(Pyer::InvalidCommandError) do
      Options.parse(args) do
        command '-get', 'Get value'
        flag    'verbose', 'Enable verbose mode'
      end
    end
  end

  def test_unknown_command1
    args = ['-v']
    assert_raises(Pyer::UnknownCommandError) do
      Options.parse(args) do
        command 'get', 'Get value'
        command 'set', 'Set value'
        flag    'verbose', 'Enable verbose mode'
      end
    end
  end

  def test_unknown_command2
    args = ['other']
    assert_raises(Pyer::UnknownCommandError) do
      Options.parse(args) do
        command 'get', 'Get value'
        command 'set', 'Set value'
        flag    'verbose', 'Enable verbose mode'
      end
    end
  end

  def test_invalid_command_order
    # command must be the first argument
    args = ['-v', 'get']
    assert_raises(Pyer::UnknownCommandError) do
      Options.parse(args) do
        command 'get', 'Get value'
        command 'set', 'Set value'
        flag    'verbose', 'Enable verbose mode'
      end
    end
  end

  def test_command_and_option
    args = ['get', '-v']
    opts = Options.parse(args) do
      command 'get', 'Get value'
      command 'set', 'Set value'
      flag    'verbose', 'Enable verbose mode'
      value   'id', 'Identification'
    end
    assert(opts.verbose?)
  end
end
