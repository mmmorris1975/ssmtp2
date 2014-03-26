cb_dir  = ::File.dirname(__FILE__)
cb_name = ::File.basename(cb_dir)

task :clean do |t|
  ::Dir.chdir(cb_dir)

  ::File.unlink("metadata.json") if ::File.exists?("metadata.json")

  ::Dir.glob("*.lock").each do |f|
    ::File.unlink(f)
  end
end

task :distclean => [:clean] do |t|
  ::Dir.chdir(cb_dir)
  ::File.unlink(::File.join("..", "#{cb_name}.tar"))
end

task :test do |t|
  sh "bundle exec strainer test" if ::File.exists?(::File.join(cb_dir, "Strainerfile"))
end

task :bundle => [:test] do |t|
  sh "bundle exec knife cookbook metadata #{cb_name}"

  ::Dir.chdir(::File.join(cb_dir, ".."))
  sh "tar --exclude-backups --exclude-vcs -cvf #{cb_name}.tar #{cb_name}"
end
