module Pyer
  class Options
    include Enumerable

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
      new( &block ).parse items
    end

    # The Array of Options::Command objects tied to this Options instance.
    attr_reader :commands

    # The Array of Options::Option objects tied to this Options instance.
    attr_reader :options

    # Create a new instance of Options and optionally build options via a block.
    #
    # block  - An optional block used to specify options.
    def initialize(&block)
      @banner = ""
      @runner = nil
      @commands = []
      @command_name = nil
      @command_callback = nil
      @options  = []
      @triggered_options = []
      @longest_cmd = 0
      @longest_flag = 0

  #    if block_given?
  #      block.arity == 1 ? yield(self) : instance_eval(&block)
  #    end
      instance_eval(&block) if block_given?
    end

    # Parse a list of items, executing and gathering options along the way.
    #
    # items - The Array of items to extract options from (default: ARGV).
    # block - An optional block which when used will yield non options.
    #
    # Returns an Array of original items with options removed.
    def parse(items = ARGV, &block)
      item=items.shift
      # need some help ?
      if item == '?' || item == '-h' || item == '--help' || item == 'help' || item.nil?
        puts self.help
        exit
      end
      # parsing command
      if !@commands.empty?
        cmd = commands.find { |cmd| cmd.name == item }
        raise UnknownCommandError if cmd.nil?
        @command_name = cmd.name
        @command_call = cmd.callback
        item=items.shift
      end
      # parsing options
      until item.nil?
        #break if item == '--'
        if item.match(/^--[^-]+$/).nil? && item.match(/^-[^-]$/).nil?
          raise InvalidOptionError, "invalid #{item} option"
        end
        key = item.sub(/\A--?/, '')
        option = options.find { |opt| opt.name == key || opt.short == key }
        if option
          @triggered_options << option
          if option.expects_argument?
            option.value = items.shift
            raise MissingArgumentError, "missing #{item} argument" if option.value.nil?
            raise InvalidArgumentError, "(#{item}=#{option.value}) argument can't start with '-'" if option.value.start_with?('-')
          else
            option.value = true
          end
        else
          raise UnknownOptionError, "unknown #{item} option"
        end
        item=items.shift
      end
      if @runner.respond_to?(:call)
        @runner.call(self, items)
      end
      # return the Options instance
      self
    end

    # Print a handy Options help string.
    #
    # Returns the banner followed by available option help strings.
    def help
      if @commands.empty?
        helpstr = "Usage: #{File.basename($0)} [options]\n"
      else
        helpstr = "Usage: #{File.basename($0)} command [options]\n"
      end
      helpstr << @banner if !@banner.empty?
      if !@commands.empty?
        helpstr << "Commands:\n"
        commands.each { |cmd|
          tab = ' ' * ( @longest_cmd + 1 - cmd.name.size )
          helpstr << '    ' + cmd.name + tab + ': ' + cmd.description + "\n"
        }
      end
      helpstr << "Options:\n"
      options.each { |opt|
        tab = ' ' * ( @longest_flag + 1 - opt.name.size )
        if opt.expects_argument?
          arg = ' <arg>'
        else
          arg = '      '
        end
        helpstr << '    -' + opt.short + '|--' + opt.name + arg + tab + ': ' + opt.description + "\n"
      }
      helpstr
    end

    # Banner
    #
    # Example:
    #   banner 'This is the banner'
    #
    def banner( desc = nil )
      if desc.nil?
        @banner
      else
        @banner += desc +"\n"
      end
    end

    # Command
    #
    # Examples:
    #   command 'run', 'Running'
    #   command :test, 'Testing'
    #
    # Returns the created instance of Options::Command.
    # or returns the command given in argument
    #
    def command(name = nil, desc = nil, &block)
      if !name.nil?
        @longest_cmd = name.size if name.size > @longest_cmd
        cmd = Command.new(name, desc, &block)
        @commands << cmd
      end
      @command_name
    end
    alias cmd command

    # Call the command callback of the command given in ARGV
    #
    # Example:
    #   # show messahe when command is executed (not during parsing)
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
    # Returns the created instance of Options::Value.
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
    # Returns the created instance of Options::Flag.
    #
    def flag(name, desc, &block)
      @longest_flag = name.size if name.size > @longest_flag
      option = Flag.new(name, desc, &block)
      @options << option
      option
    end

    # Specify code to be executed when these options are parsed.
    #
    # Example:
    #
    #   opts = Options.parse do
    #     flag :v, :verbose
    #
    #     run do |opts, args|
    #       puts "Arguments: #{args.inspect}" if opts.verbose?
    #     end
    #   end
    #def run(callable = nil, &block)
    def run(&block)
      @runner = block if block_given?
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

    # Enumerable interface. Yields each Options::Option.
    def each(&block)
      options.each(&block)
    end

    # Returns a new Hash with option flags as keys and option values as values.
    #
    # include_commands - If true, merge options from all sub-commands.
    def to_hash
      Hash[options.map { |opt| [opt.name.to_sym, opt.value] }]
    end
    alias to_h to_hash

    # Fetch a list of options which were missing from the parsed list.
    #
    # Examples:
    #
    #   opts = Options.new do
    #     value :n, :name
    #     value :p, :password
    #   end
    #
    #   opts.parse %w[ --name Lee ]
    #   opts.missing #=> ['password']
    #
    # Returns an Array of Strings representing missing options.
    def missing
      (options - @triggered_options).map(&:name)
    end

    private
    # Returns true if this option is present.
    # If this method does not end with a ? character it will instead
    # return the value of the option or nil
    #
    # Examples:
    #   opts.parse %( --verbose )
    #   opts.verbose? #=> true
    #   opts.other?   #=> false
    #
    def method_missing(method)
      meth = method.to_s
      if meth.end_with?('?')
        meth.chop!
        !(@triggered_options.find { |opt| opt.name == meth }).nil?
      else
        o = @triggered_options.find { |opt| opt.name == meth }
  #      o.nil? ? super : o.value
        if o.nil?
          nil
        else
          o.callback.call if o.callback.respond_to?(:call)
          o.nil? ? nil : o.value
        end
      end
    end

    class Command
      attr_reader :name, :description, :callback

      # Incapsulate internal command.
      #
      # name        - The String or Symbol command name.
      # description - The String description text.
      # block       - An optional block.
      def initialize(name, description, &block)
        @name = name.to_s
        raise InvalidCommandError, "Command #{@name} is invalid" if @name.start_with?('-')
        @description = description
        @callback = (block_given? ? block : nil)
      end
    end

    class Flag
      attr_reader :short, :name, :description, :callback
      attr_accessor :value

      # Incapsulate internal option information, mainly used to store
      # option specific configuration data, most of the meat of this
      # class is found in the #value method.
      #
      # name        - The String or Symbol option name.
      # description - The String description text.
      # block       - An optional block.
      def initialize(name, description, &block)
        # Remove leading '-' from name if any
        @name = name.to_s.gsub(/^--?/, '')
        raise InvalidOptionError, "Option #{@name} is invalid" if @name.size < 2
        @expects_argument = false
        @value = false
        @short = @name[0]
        @description = description
        @callback = (block_given? ? block : nil)
      end

      # Returns true if this option expects an argument.
      def expects_argument?
        @expects_argument
      end
    end

    class Value
      attr_reader :short, :name, :description, :callback
      attr_accessor :value

      # Incapsulate internal option information, mainly used to store
      # option specific configuration data, most of the meat of this
      # class is found in the #value method.
      #
      # name        - The String or Symbol option name.
      # description - The String description text.
      # block       - An optional block.
      def initialize(name, description, &block)
        # Remove leading '-' from name if any
        @name = name.to_s.gsub(/^--?/, '')
        raise InvalidOptionError, "Option #{@name} is invalid" if @name.size < 2
        @expects_argument = true
        @value = nil
        @short = @name[0]
        @description = description
        @callback = (block_given? ? block : nil)
      end

      # Returns true if this option expects an argument.
      def expects_argument?
        @expects_argument
      end
    end

  end
end

# Backward-compatible alias
Options = Pyer::Options
