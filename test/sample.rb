#!/usr/bin/ruby
# encoding: UTF-8

# require 'pyer/options'
require './lib/pyer/options.rb'

begin
  opts = Options.parse do
    banner 'Some help text'
    value  'name',     'Your name'
    value  'password', 'Your password'
    flag   'verbose',  'Enable verbose mode'
  end
rescue => e
  puts "Error: #{e.message}"
  exit
end

# if ARGV is `--name Lee -v`
puts "verbose enabled:  #{opts.verbose?}"  #=> true
puts "password defined: #{opts.password?}" #=> false
puts "other defined:    #{opts.other?}"    #=> false
puts "name defined:     #{opts.name?}"     #=> true
puts "name:             #{opts.name}"      #=> 'Lee'
puts "name from array:  #{opts[:name]}"    #=> 'Lee'
puts "options hash:     #{opts.to_hash}"   #=> {:name=>"Lee", :password=>nil, :verbose=>true}
