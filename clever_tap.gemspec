# coding: utf-8
$LOAD_PATH.push File.expand_path('../lib', __FILE__)

require 'clever_tap/version'

Gem::Specification.new do |spec|
  spec.name = 'clever_tap'
  spec.version = CleverTap::VERSION
  spec.authors = ['Tradeo team']
  spec.email = ['opensource@tradeo.com']
  spec.license = 'MIT'
  spec.homepage = 'https://github.com/tradeo/clevertap-ruby'
  spec.summary = 'CleverTap API client'
  spec.description = 'Gem providing easy access to the CleverTap API'
  spec.files = Dir['lib/**/*', 'LICENSE.txt', 'Rakefile', 'README.md', 'Gemfile']
  spec.test_files = Dir['spec/**/*']
  spec.executables = Dir['bin/**/*']
  spec.bindir = 'bin'
  spec.require_paths = ['lib']

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end
end
