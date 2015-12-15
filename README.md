Options
=======

Options is a option parser with a simple syntax and friendly API.

Original idea is taken from Slop option parser (https://github.com/leejarvis/slop). I make a simpler syntax for my needs.
Many thanks to Lee Jarvis.


Usage
-----

Options parses somes words:

* banner  : banner add text to the help message. Help message is displayed with implicit option -h|--help|?|help.
* run     : run block is executed during options parsing.
* flag    : Linux style boolean option. For example [--verbose] sets verbose flag true. Short option is the first letter of the long option name.
* value   : Linux style option. Next argument is the value of the option. For example [--name pyer] means name='pyer'. Short option is the first letter of the long option name, as flag option.
* command : Git style sub-commands, For example [programm status --verbose] means programm executes status command in verbose mode.
* cmd     : alias of command


```ruby
opts = Options.parse do
  banner 'Some help text'
  value  'name',     'Your name'
  value  'password', 'Your password'
  flag   'verbose',   'Enable verbose mode'
end

# if ARGV is `--name Lee -v`
opts.verbose?  #=> true
opts.password? #=> false
opts.other?    #=> false
opts.name?     #=> true
opts[:name]    #=> 'Lee'
opts.to_hash   #=> {:name=>"Lee", :password=>nil, :verbose=>true}

```

Installation
------------
    gem install pyer-options

Build
-----
Building pyer-options gem is a rake task.

    rake build

Test
----
    rake test

Help
----

Options attempts to build a good looking help string to print to your users.
You can get this string by calling `opts.help` method.
The options '-h', '--help' and '?' are available and show this help.

Example:

```ruby
# example.rb
require 'pyer/options'
opts = Options.parse do
  banner 'Hello world'
  flag   :foo, 'Enable foo mode'
end
```

ruby example.rb --help
("ruby example.rb -h" or "ruby example.rb ?" give the same result)
 
```
Usage: example.rb [options]
  Hello world
Options:
    -f|--foo       : Enable foo mode

```

