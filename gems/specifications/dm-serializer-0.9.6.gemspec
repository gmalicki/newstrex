Gem::Specification.new do |s|
  s.name = %q{dm-serializer}
  s.version = "0.9.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Guy van den Berg"]
  s.date = %q{2008-10-11}
  s.description = %q{DataMapper plugin for serializing DataMapper objects}
  s.email = ["vandenberg.guy@gmail.com"]
  s.extra_rdoc_files = ["README.txt", "LICENSE", "TODO"]
  s.files = ["History.txt", "LICENSE", "Manifest.txt", "README.txt", "Rakefile", "TODO", "autotest/discover.rb", "autotest/dmserializer_rspec.rb", "lib/dm-serializer.rb", "lib/dm-serializer/version.rb", "spec/fixtures/cow.rb", "spec/fixtures/planet.rb", "spec/fixtures/quatum_cat.rb", "spec/spec.opts", "spec/spec_helper.rb", "spec/unit/serializer_spec.rb", "spec/unit/to_csv_spec.rb", "spec/unit/to_json_spec.rb", "spec/unit/to_xml_spec.rb", "spec/unit/to_yaml_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/sam/dm-more/tree/master/dm-serializer}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{datamapper}
  s.rubygems_version = %q{1.2.0}
  s.summary = %q{DataMapper plugin for serializing DataMapper objects}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if current_version >= 3 then
      s.add_runtime_dependency(%q<dm-core>, ["= 0.9.6"])
      s.add_development_dependency(%q<hoe>, [">= 1.7.0"])
    else
      s.add_dependency(%q<dm-core>, ["= 0.9.6"])
      s.add_dependency(%q<hoe>, [">= 1.7.0"])
    end
  else
    s.add_dependency(%q<dm-core>, ["= 0.9.6"])
    s.add_dependency(%q<hoe>, [">= 1.7.0"])
  end
end
