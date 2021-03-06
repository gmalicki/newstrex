Gem::Specification.new do |s|
  s.name = %q{uuidtools}
  s.version = "1.0.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bob Aman"]
  s.date = %q{2008-09-28}
  s.description = %q{A simple universally unique ID generation library.}
  s.email = %q{bob@sporkmonger.com}
  s.extra_rdoc_files = ["README"]
  s.files = ["lib/uuidtools", "lib/uuidtools/version.rb", "lib/uuidtools.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/uuidtools", "spec/uuidtools/mac_address_spec.rb", "spec/uuidtools/uuid_creation_spec.rb", "spec/uuidtools/uuid_parsing_spec.rb", "tasks/benchmark.rake", "tasks/clobber.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/metrics.rake", "tasks/rdoc.rake", "tasks/rubyforge.rake", "tasks/spec.rake", "website/index.html", "CHANGELOG", "LICENSE", "Rakefile", "README"]
  s.has_rdoc = true
  s.homepage = %q{http://uuidtools.rubyforge.org/}
  s.rdoc_options = ["--main", "README"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{uuidtools}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{UUID generator}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<rake>, [">= 0.7.3"])
      s.add_runtime_dependency(%q<rspec>, [">= 1.0.8"])
    else
      s.add_dependency(%q<rake>, [">= 0.7.3"])
      s.add_dependency(%q<rspec>, [">= 1.0.8"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.7.3"])
    s.add_dependency(%q<rspec>, [">= 1.0.8"])
  end
end
