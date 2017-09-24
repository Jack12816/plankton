# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "plankton/version"

Gem::Specification.new do |spec|
  spec.name        = 'plankton'
  spec.version     = Plankton::VERSION
  spec.authors     = ['Hermann Mayer']
  spec.email       = ['hermann.mayer92@gmail.com']

  spec.summary     = %q{A commandline interface to private Docker Registries}
  spec.description = %q{A commandline interface to private Docker Registries}
  spec.homepage    = 'https://github.com/Jack12816/plankton'
  spec.license     = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this
  # section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'

  spec.add_runtime_dependency 'recursive-open-struct', '~> 1.0'
  spec.add_runtime_dependency 'docker_registry2', '~> 1.0'
  spec.add_runtime_dependency 'thor', '~> 0.20'
  spec.add_runtime_dependency 'tty-table', '~> 0.8'
  spec.add_runtime_dependency 'filesize', '~> 0.1'
end
