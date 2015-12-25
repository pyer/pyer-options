# encoding: UTF-8
module Pyer
  # Raised when the command starts whith '-', or is not given
  class InvalidCommandError < StandardError
  end

  # Raised when the command is not defined
  class UnknownCommandError < StandardError
  end

  # Raised when an invalid option is found.
  class InvalidOptionError < StandardError
  end

  # Raised when an unknown option is found.
  class UnknownOptionError < StandardError
  end

  # Raised when an option argument is expected but none are given.
  class MissingArgumentError < StandardError
  end

  # Raised when an option argument starts whith '-'
  class InvalidArgumentError < StandardError
  end

  # Options class
  class Options
    include Enumerable

    # items  - The Array of items to extract options from (default: ARGV).
    # block  - An optional block used to add options.
    #
    # Examples:
    #
    #   Options.parse(ARGV) do
    #     value 'name', 'Your username'
    #     flag  'verbose', 'Enable verbose mode'
    #   end
    #
    # short option is the first letter of long option
    # Returns a new instance of Options.
    def self.parse(items = ARGV, &block)
      new(&block).parse items
    end

    attr_reader :commands
    attr_reader :options

    # Create a new instance of Options and optionally build options via a block.
    #
    # block  - An optional block used to specify options.
    def initialize(&block)
      @banner = ''
      @commands = []
      @command_name = nil
      @command_callback = nil
      @options = []
      @triggered_options = []
      @longest_cmd = 0
      @longest_flag = 0
      instance_eval(&block) if block_given?
    end

    # Parse a list of items, executing and gathering options along the way.
    #
    # items - The Array of items to extract options from (default: ARGV).
    # block - An optional block which when used will yield non options.
    #
    # Returns an Array of original items with options removed.
    def parse(items = ARGV)
      item = items.shift
      # need some help ?
      show_help if item == '?' || item == '-h' || item == '--help' || item == 'help' || item.nil?
      # parsing command
      unless commands.empty?
        parse_command(item)
        item = items.shift
      end
      # parsing options
      until item.nil?
        option = parse_option(item)
        if option.expects_argument
          option.value = items.shift
          fail MissingArgumentError, "missing #{item} argument" if option.value.nil?
          fail InvalidArgumentError, "(#{item}=#{option.value}) argument can't start with '-'" if option.value.start_with?('-')
        else
          option.value = true
        end
        item = items.shift
      end
      # return the Options instance
      self
    end

    def parse_command(command)
      cmd = commands.find { |c| c.name == command }
      fail UnknownCommandError if cmd.nil?
      @command_name = cmd.name
      @command_call = cmd.callback
    end

    def parse_option(option)
      if option.match(/^--[^-]+$/).nil? && option.match(/^-[^-]$/).nil?
        fail InvalidOptionError, "invalid #{option} option"
      end
      key = option.sub(/\A--?/, '')
      triggered_option = options.find { |opt| opt.name == key || opt.short == key }
      fail UnknownOptionError, "unknown #{option} option" if triggered_option.nil?
      @triggered_options << triggered_option
      triggered_option
    end

    private :parse_command, :parse_option

    # Print a handy Options help string and exit.
    def help
      helpstr = "Usage: #{File.basename($PROGRAM_NAME)} "
      helpstr << 'command ' unless commands.empty?
      helpstr << "[options]\n"
      helpstr << banner unless banner.empty?
      helpstr << help_commands unless commands.empty?
      helpstr << help_options
      helpstr
    end

    def help_commands
      helpstr = "Commands:\n"
      @commands.each do |cmd|
        tab = ' ' * (@longest_cmd + 1 - cmd.name.size)
        helpstr << '    ' + cmd.name + tab + ': ' + cmd.description + "\n"
      end
      helpstr
    end

    def help_options
      helpstr = "Options:\n"
      @options.each do |opt|
        tab = ' ' * (@longest_flag + 1 - opt.name.size)
        arg = opt.expects_argument ? ' <arg>' : '      '
        helpstr << '    -' + opt.short + '|--' + opt.name + arg + tab + ': ' + opt.description + "\n"
      end
      helpstr
    end

    def show_help
      puts help
      exit
    end

    private :help_commands, :help_options, :show_help

    # Banner
    #
    # Example:
    #   banner 'This is the banner'
    #
    def banner(desc = nil)
      @banner += desc + "\n" unless desc.nil?
      @banner
    end

    # Command
    #
    # Examples:
    #   command 'run', 'Running'
    #   command :test, 'Testing'
    #
    # Returns the created instance of Command.
    # or returns the command given in argument
    #
    def command(name = nil, desc = nil, &block)
      unless name.nil?
        @longest_cmd = name.size if name.size > @longest_cmd
        cmd = Command.new(name, desc, &block)
        @commands << cmd
      end
      @command_name
    end
    alias_method :cmd, :command

    # Call the command callback of the command given in ARGV
    #
    # Example:
    #   # show message when command is executed (not during parsing)
    #   command 'run', 'Running' do
    #     puts "run in progress"
    #   end
    #
    def callback
      @command_call.call if @command_call.respond_to?(:call)
    end

    # Add a value to options
    #
    # Examples:
    #   value 'user', 'Your username'
    #   value :pass,  'Your password'
    #
    # Returns the created instance of Value.
    #
    def value(name, desc, &block)
      @longest_flag = name.size if name.size > @longest_flag
      option = Value.new(name, desc, &block)
      @options << option
      option
    end

    # Add an flag to options
    #
    # Examples:
    #   flag :verbose, 'Enable verbose mode'
    #   flag 'debug',  'Enable debug mode'
    #
    # Returns the created instance of Flag.
    #
    def flag(name, desc, &block)
      @longest_flag = name.size if name.size > @longest_flag
      option = Flag.new(name, desc, &block)
      @options << option
      option
    end

    # Fetch an options argument value.
    #
    # key - The Symbol or String option short or long flag.
    #
    # Returns the Object value for this option, or nil.
    def [](key)
      key = key.to_s
      option = options.find { |opt| opt.name == key || opt.short == key }
      option.value if option
    end

    # Enumerable interface. Yields each Option.
    def each(&block)
      options.each(&block)
    end

    # Returns a new Hash with option flags as keys and option values as values.
    #
    # include_commands - If true, merge options from all sub-commands.
    def to_hash
      Hash[options.map { |opt| [opt.name.to_sym, opt.value] }]
    end

    alias_method :to_h, :to_hash

    private

    # Returns an Array of Strings representing missing options.
    def find_option(name)
      @triggered_options.find { |opt| opt.name == name }
    end

    # Returns true if this option is present.
    # If this method does not end with a ? character it will instead
    # return the value of the option or nil
    #
    # Examples:
    #   opts.parse %(--verbose)
    #   opts.verbose? #=> true
    #   opts.other?   #=> false
    #
    def method_missing(method)
      meth = method.to_s
      if meth.end_with?('?')
        !find_option(meth.chop!).nil?
      else
        o = find_option(meth)
        o.callback.call if !o.nil? && o.callback.respond_to?(:call)
        o.nil? ? nil : o.value
      end
    end
  end

  # Command class
  class Command
    attr_reader :name, :description, :callback

    # Incapsulate internal command.
    #
    # name        - The String or Symbol command name.
    # description - The String description text.
    # block       - An optional block.
    def initialize(name, description, &block)
      @name = name.to_s
      fail InvalidCommandError, "Command #{@name} is invalid" if @name.start_with?('-')
      @description = description
      @callback = (block_given? ? block : nil)
    end
  end

  # Option class
  class Option
    attr_reader :short, :name, :description, :callback
    attr_reader :expects_argument
    attr_accessor :value

    # Incapsulate internal option information, mainly used to store
    # option specific configuration data.
    #
    # name        - The String or Symbol option name.
    # description - The String description text.
    # block       - An optional block.
    def initialize(name, description, &block)
      # Remove leading '-' from name if any
      @name = name.to_s.gsub(/^--?/, '')
      fail InvalidOptionError, "Option #{@name} is invalid" if @name.size < 2
      @expects_argument = false
      @value = nil
      @short = @name[0]
      @description = description
      @callback = (block_given? ? block : nil)
    end
  end

  # Flag class
  class Flag < Option
    def initialize(name, description, &block)
      super
      @value = false
    end
  end

  # Value class
  class Value < Option
    def initialize(name, description, &block)
      super
      @expects_argument = true
    end
  end
end

# Backward-compatible alias
Options = Pyer::Options
