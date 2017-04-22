desc "Build the site"
task :build do
  system 'jekyll build'
end

desc "Build and deploy the site"
task :deploy do
  system 'scp -r _site/* mentalized.net@linux78.unoeuro.com:public_html/'
end
