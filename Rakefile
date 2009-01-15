desc "installs everything"
task :install => "install:all"
namespace :install do

  def install name, *files
    desc "installs #{name} configuration"
    task(name) { sh Dir[*files].collect { |f| "ln -s #{f} ~/#{f}" }.join(" && ") }
    task :all => :name
  end

  install :irb, ".irbrc", ".config/irb/*.rb"
  install :vim, ".vimrc", ".vim"

end