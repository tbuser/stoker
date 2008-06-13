Gem::Specification.new do |s|
  s.name = "stoker"
  s.version = "0.0.1"
  s.date = "2008-06-11"
  s.summary = "Control a Rock's Bar-B-Que Stoker"
  s.email = "tbuser@gmail.com"
  s.homepage = "http://github.com/tbuser/stoker"
  s.description = "Stoker is a ruby gem that allows you to monitor and control a Rock's Bar-B-Que Stoker"
  # s.has_rdoc = true
  s.authors = ["Tony Buser"]
  s.files = ["lib/stoker.rb", "LICENSE", "README", "test.rb", "tests/telnet.txt", "tests/test1.html"]
  # s.test_files = ["test/test_actor.rb", "test/test_blob.rb", "test/test_commit.rb", "test/test_config.rb", "test/test_diff.rb", "test/test_git.rb", "test/test_head.rb", "test/test_real.rb", "test/test_reality.rb", "test/test_repo.rb", "test/test_tag.rb", "test/test_tree.rb"]
  # s.rdoc_options = ["--main", "README.txt"]
  # s.extra_rdoc_files = ["History.txt", "Manifest.txt", "README.txt"]
  s.add_dependency("hpricot", ["> 0.0.0"])
end