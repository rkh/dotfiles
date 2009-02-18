#!/usr/bin/ruby

if $0 == __FILE__
  system "export RUBYOPT=#{File.expand_path __FILE__}"
else
  require "rubygems"
  $: += Dir["/home/konstantin/Workspace/ruby/*/lib"]
end