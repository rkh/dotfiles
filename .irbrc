%w[myirb engine color rails commands].each do |lib|
  require File.join(ENV["HOME"], ".config", "irb", lib)
end

MyIRB.start