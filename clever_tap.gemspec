$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'clever_tap/version'

Gem::Specification.new do |spec|
  spec.name = 'clever_tap'
  spec.version = CleverTap::VERSION
  spec.authors = ['Kamen Kanev', 'Svetoslav Blyahov']
  spec.email = ['opensource@tradeo.com']
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/tradeo/clevertap-ruby'
  spec.summary = 'CleverTap API client'
  spec.description = 'Gem providing easy access to the CleverTap API'

  spec.files = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.test_files = Dir['spec/**/*']
  spec.require_paths = ['lib']

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.add_dependency 'faraday', '>= 0.8', '<= 0.14.0'
  spec.add_dependency 'json'

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency 'rake', '~> 10.0'
end
