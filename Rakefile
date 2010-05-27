require 'spec/rake/spectask'


desc "Run all specs"
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << '.' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts = ["--colour", "--backtrace", "--format progress"]
end

