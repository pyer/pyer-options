require "minitest/autorun"
require 'pyer/options.rb'

class TestOptions < Minitest::Test

    def test_run
      args = ['-v']
      dbg = false
      opts = Pyer::Options.parse(args) do
        run do
          dbg = true
        end
        flag   'verbose', 'Enable verbose mode'
      end
      assert( opts.verbose )
      assert( dbg )
    end

    def test_command
      args = ['get']
      opts = Pyer::Options.parse(args) do
        command 'get', 'Get value'
        command 'set', 'Set value'
        command :put,  'Put value'
        flag    'verbose', 'Enable verbose mode'
        value   'name', 'Name of the value'
      end
      assert_equal( opts.command, 'get' )
    end

    def test_command_with_block
      args = ['get']
      opts = Pyer::Options.parse(args) do
        command 'get', 'Get value' do
          "GET callback"
        end
        command 'set', 'Set value' do
          "SET callback"
        end
        flag   'verbose', 'Enable verbose mode'
      end
      assert_equal( opts.callback, "GET callback" )
    end

    def test_invalid_command
      args = ['get']
      assert_raises(Pyer::Options::InvalidCommandError) {
        opts = Pyer::Options.parse(args) do
          command '-get', 'Get value'
          flag    'verbose', 'Enable verbose mode'
        end
      }
    end

    def test_unknown_command
      args = ['-v']
      assert_raises(Pyer::Options::UnknownCommandError) {
        opts = Pyer::Options.parse(args) do
          command 'get', 'Get value'
          command 'set', 'Set value'
          flag    'verbose', 'Enable verbose mode'
        end
      }
    end

    def test_invalid_command_order
      # command must be the first argument
      args = ['-v', 'get']
      assert_raises(Pyer::Options::UnknownCommandError) {
        opts = Pyer::Options.parse(args) do
          command 'get', 'Get value'
          command 'set', 'Set value'
          flag    'verbose', 'Enable verbose mode'
        end
      }
    end

    def test_unknown_command
      args = ['other']
      assert_raises(Pyer::Options::UnknownCommandError) {
        opts = Pyer::Options.parse(args) do
          command 'get', 'Get value'
          command 'set', 'Set value'
          flag    'verbose', 'Enable verbose mode'
        end
      }
    end

    def test_command_and_option
      args = ['get', '-v']
      opts = Pyer::Options.parse(args) do
        command 'get', 'Get value'
        command 'set', 'Set value'
        flag    'verbose', 'Enable verbose mode'
        value   'id', 'Identification'
      end
      assert( opts.verbose? )
    end

    def test_simple_option1
      args = ['-i']
      opts = Pyer::Options.parse(args) do
        flag 'id', 'Identification'
      end
      assert( opts.id? )
    end

    def test_simple_option2
      args = ['--id']
      opts = Pyer::Options.parse(args) do
        flag 'id', 'Identification'
      end
      assert( opts.id? )
    end

    def test_simple_option3
      args = ['-i']
      opts = Pyer::Options.parse(args) do
        flag '--id', 'Identification'
      end
      assert( opts.id? )
    end

    def test_simple_value1
      args = ['-i', '123']
      opts = Pyer::Options.parse(args) do
        value 'id', 'Identification'
      end
      assert_equal( opts.id, "123" )
    end

    def test_simple_value2
      args = ['--id', '123']
      opts = Pyer::Options.parse(args) do
        value 'id', 'Identification'
      end
      assert_equal( opts.id, "123" )
    end

    def test_simple_good_short_option
      args = ['-i', '123']
      opts = Pyer::Options.parse(args) do
        value 'id=ID', 'Identification'
      end
      assert_equal( opts['id=ID'], "123" )
    end

    def test_simple_bad_long_option
      args = ['--id', '123']
      assert_raises(Pyer::Options::UnknownOptionError) {
        opts = Pyer::Options.parse(args) do
          value 'id=ID', 'Identification'
        end
      }
    end

    def test_simple_bad_value2
      args = ['--id=123', '-v']
      assert_raises(Pyer::Options::UnknownOptionError) {
        opts = Pyer::Options.parse(args) do
          value 'id=ID', 'Identification'
          flag  'verbose', 'Enable verbose mode'
        end
      }
    end

    def test_option_with_block
      args = ['-d']
      dbg = false
      opts = Pyer::Options.parse(args) do
        flag 'debug', 'Enable debug mode' do
          dbg = true
        end
      end
      assert( opts.debug )
      assert( dbg )
    end

    def test_banner
      args = ['-v']
      opts = Pyer::Options.parse(args) do
        banner 'Banner'
        flag   'verbose', 'Enable verbose mode'
      end
      assert_equal( opts.banner, "Banner\n" )
    end

    def test_banner2
      args = ['-v']
      opts = Pyer::Options.parse(args) do
        banner 'Line1'
        banner 'Line2'
        flag   'verbose', 'Enable verbose mode'
      end
      assert_equal( opts.banner, "Line1\nLine2\n" )
    end

    def test_help
      args = ['-v']
      opts = Pyer::Options.parse(args) do
        flag 'verbose', 'Enable verbose mode'
      end
      assert( opts.help.is_a? String )
      #puts ""
      #puts opts.help
    end

    def test_true_flag1
      args = ['-v']
      opts = Pyer::Options.parse(args) do
        flag 'verbose', 'Enable verbose mode'
      end
      assert( opts.verbose? )
    end

    def test_true_flag2
      args = ['-v']
      opts = Pyer::Options.parse(args) do
        flag 'verbose', 'Enable verbose mode'
      end
      assert( opts[:verbose] )
    end

    def test_false_flag1
      args = ['-d']
      opts = Pyer::Options.parse(args) do
        flag 'debug', 'Enable debug mode'
        flag 'verbose', 'Enable verbose mode'
      end
      refute( opts.verbose? )
    end

    def test_false_flag2
      args = ['-d']
      opts = Pyer::Options.parse(args) do
        flag 'debug', 'Enable debug mode'
        flag 'verbose', 'Enable verbose mode'
      end
      refute( opts[:verbose] )
    end

    def test_unknown_flag1
      args = ['-v']
      opts = Pyer::Options.parse(args) do
        flag 'verbose', 'Enable verbose mode'
      end
      refute( opts.dummy? )
    end

    def test_unknown_flag2
      args = ['-v']
      opts = Pyer::Options.parse(args) do
        flag 'verbose', 'Enable verbose mode'
      end
      assert( opts[:dummy].nil? )
    end

    def test_wrong_number_of_arguments_of_option1
      # Help string is mandatory
      args = ['-v']
      assert_raises(ArgumentError) {
        opts = Pyer::Options.parse(args) do
          flag 'verbose'
        end
      }
    end

    def test_wrong_number_of_arguments_of_option2
      args = ['-v']
      assert_raises(ArgumentError) {
        opts = Pyer::Options.parse(args) do
          flag 'verbose', 'Enable verbose mode', 'extra'
        end
      }
    end

    def test_unknown_option
      args = ['--option','-v']
      assert_raises(Pyer::Options::UnknownOptionError) {
        opts = Pyer::Options.parse(args) do
          flag 'help', 'Show some help'
          flag 'verbose', 'Enable verbose mode'
        end
      }
    end

    def test_missing_option
      args = ['--name','Pierre']
      opts = Pyer::Options.parse(args) do
        value 'name', 'Enter your name'
        value 'id', 'Enter your ID'
      end
      refute( opts.id? )
    end

    def test_missing_option_is_nil
      args = ['--name','Pierre']
      opts = Pyer::Options.parse(args) do
        value 'name', 'Enter your name'
        value 'id', 'Enter your ID'
      end
      assert_nil( opts[:id] )
    end

    def test_valid_argument
      args = ['--name','Pierre']
      opts = Pyer::Options.parse(args) do
        value 'name', 'Enter your name'
      end
      assert_equal( opts[:name], "Pierre" )
    end

    def test_undefined_argument
      args = ['-v']
      opts = Pyer::Options.parse(args) do
        value 'name', 'Enter your name'
        flag 'verbose', 'Enable verbose mode'
      end
      refute( opts.name? )
    end

    def test_missing_argument
      args = ['--name']
      assert_raises(Pyer::Options::MissingArgumentError) {
        opts = Pyer::Options.parse(args) do
          value 'name', 'Enter your name'
        end
      }
    end

    def test_invalid_argument
      args = ['--name', '-v']
      assert_raises(Pyer::Options::InvalidArgumentError) {
        opts = Pyer::Options.parse(args) do
          value 'name', 'Enter your name'
          flag 'verbose', 'Enable verbose mode'
        end
      }
    end

    def test_mix_option
      args = ['-verbose'] # is not allowed
      assert_raises(Pyer::Options::InvalidOptionError) {
        opts = Pyer::Options.parse(args) do
          flag 'help', 'Show some help'
          flag 'verbose', 'Enable verbose mode'
        end
      }
    end

    def test_short_option
      args = ['-v']
      opts = Pyer::Options.parse(args) do
        flag 'help', 'Show some help'
        flag 'verbose', 'Enable verbose mode'
      end
      assert( opts.verbose? )
    end

    def test_long_option
      args = ['--verbose']
      opts = Pyer::Options.parse(args) do
        flag 'help', 'Show some help'
        flag 'verbose', 'Enable verbose mode'
      end
      assert( opts.verbose? )
    end

    def test_missing_short_option
      args = ['-v']
      opts = Pyer::Options.parse(args) do
        flag 'dummy', 'Dummy option'
        flag 'help', 'Show some help'
        flag 'verbose', 'Enable verbose mode'
        flag 'zzz', 'Z as Zero'
      end
#      p opts.missing
      assert( opts.missing == ['dummy', 'help', 'zzz'] )
    end

    def test_missing_long_option
      args = ['--verbose']
      opts = Pyer::Options.parse(args) do
        flag 'dummy', 'Dummy option'
        flag 'help', 'Show some help'
        flag 'verbose', 'Enable verbose mode'
        flag 'zzz', 'Z as Zero'
      end
#      p opts.missing
      assert( opts.missing == ['dummy', 'help', 'zzz'] )
    end

end
