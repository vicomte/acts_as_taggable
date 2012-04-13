$:.push File.dirname(__FILE__) + '/lib'
require 'acts_as_taggable/extra/version'

Gem::Specification.new do |gem|
  gem.name = %q{acts_as_taggable}
  gem.authors = ["Michael Bleigh"]
  gem.date = %q{2012-01-06}
  gem.description = %q{With ActsAsTaggable, you can tag a single model on several contexts, such as skills, interests, and awards. It also provides other advanced functionality.}
  gem.summary = "Advanced tagging for Rails."
  gem.email = %q{michael@intridea.com}
  gem.homepage      = ''

  gem.add_runtime_dependency 'rails'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'sqlite3'

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "acts_as_taggable"
  gem.require_paths = ['lib']
  gem.version       = ActsAsTaggable::Extra::VERSION
end
