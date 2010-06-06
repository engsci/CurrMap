require 'spec/rake/spectask'

namespace :spec do
  desc "Run all specs"
  Spec::Rake::SpecTask.new(:all) do |spec|
    spec.libs << '.' << 'spec'
    spec.spec_files = FileList['spec/**/*_spec.rb']
    spec.spec_opts = ["--colour", "--backtrace", "--format progress"]
  end  
  
  desc "Run specs for just the Tree of Knowledge connection"
  Spec::Rake::SpecTask.new(:tok) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.spec_files = FileList['spec/tok/*_spec.rb']
    spec.spec_opts = ["--colour", "--backtrace", "--format progress"]
  end
end
