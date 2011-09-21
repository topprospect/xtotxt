# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "xtotxt/version"

Gem::Specification.new do |s|
  s.name        = "xtotxt"
  s.version     = Xtotxt::VERSION
  s.authors     = ["Alexy Khrabrov"]
  s.email       = ["alexy@topprospect.com"]
  s.homepage    = "http://www.topprospect.com"
  s.summary     = %q{Convert pdf, doc and docx to plain text}
  s.description = %q{A simple wrapper calling, for each supported input format, a given command-line tool}

  s.rubyforge_project = "xtotxt"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
