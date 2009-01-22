%w[myirb engine color rails commands gist].each do |lib|
  begin
    require File.join(ENV["HOME"], ".config", "irb", lib)
  rescue LoadError
    puts "\033[0;31mCould not load feature \033[1;31m'#{lib}'\033[0;31m: #{$!.message}.\033[0m"
  end
end

MyIRB.start