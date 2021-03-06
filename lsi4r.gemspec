# -*- encoding: utf-8 -*-
# stub: lsi4r 0.0.3 ruby lib

Gem::Specification.new do |s|
  s.name = "lsi4r"
  s.version = "0.0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Jens Wille"]
  s.date = "2015-08-14"
  s.description = "LSI processing for Ruby."
  s.email = "jens.wille@gmail.com"
  s.extra_rdoc_files = ["README", "COPYING", "ChangeLog"]
  s.files = ["COPYING", "ChangeLog", "README", "Rakefile", "lib/lsi4r.rb", "lib/lsi4r/doc.rb", "lib/lsi4r/version.rb"]
  s.homepage = "http://github.com/blackwinter/lsi4r"
  s.licenses = ["AGPL-3.0"]
  s.post_install_message = "\nlsi4r-0.0.3 [2015-08-14]:\n\n* Refactored Lsi4R#each_vector and Lsi4R::Doc#initialize.\n\n"
  s.rdoc_options = ["--title", "lsi4r Application documentation (v0.0.3)", "--charset", "UTF-8", "--line-numbers", "--all", "--main", "README"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.3")
  s.rubygems_version = "2.4.8"
  s.summary = "Latent semantic indexing for Ruby."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rb-gsl>, [">= 0"])
      s.add_development_dependency(%q<hen>, [">= 0.8.3", "~> 0.8"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<rb-gsl>, [">= 0"])
      s.add_dependency(%q<hen>, [">= 0.8.3", "~> 0.8"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<rb-gsl>, [">= 0"])
    s.add_dependency(%q<hen>, [">= 0.8.3", "~> 0.8"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
