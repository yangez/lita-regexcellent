Gem::Specification.new do |spec|
  spec.name          = "lita-regexcellent"
  spec.version       = "0.1.0"
  spec.authors       = ["Eric Yang"]
  spec.email         = ["eyang232@gmail.com"]
  spec.description   = "Parse through channel history with regex"
  spec.summary       = "Parse through channel history with regex"
  spec.homepage      = "https://github.com/yangez/lita-regexcellent"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.6"
  spec.add_runtime_dependency "chronic"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
end
