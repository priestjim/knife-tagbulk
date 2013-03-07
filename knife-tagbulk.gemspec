# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name          = 'knife-tagbulk'
  gem.authors       = ['Panagiotis Papadomitsos']
  gem.email         = ['pj@ezgr.net']
  gem.description   = %q{Bulk tag creation/deletion for Chef nodes}
  gem.summary       = %q{Bulk create and delete Chef node tags on nodes selected by standard Chef search queries}
  gem.homepage      = 'https://github.com/priestjim/knife-tagbulk'

  gem.add_runtime_dependency 'chef', '>= 10.16.4'

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ['lib']
  gem.version       = File.read(File.expand_path('VERSION', __FILE__)).chomp
end
