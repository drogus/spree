require 'rake'
require 'rake/gempackagetask'
require 'thor/group'

PROJECTS = %w(core api auth dash sample)  #TODO - spree_promotions

spec = eval(File.read('spree.gemspec'))
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Release all gems to gemcutter. Package rails, package & push components, then push spree"
task :release => :release_projects do
  require 'rake/gemcutter'
  Rake::Gemcutter::Tasks.new(spec).define
  Rake::Task['gem:push'].invoke
end

desc "Creates a sandbox application for testing your Spree code"
task :sandbox do

  class SandboxGenerator < Thor::Group
    include Thor::Actions

    def generate_app
      remove_directory_if_exists("sandbox")
      run "rails new sandbox -GJT"
    end

    def append_gemfile
      inside "sandbox" do
        append_file "Gemfile" do
<<-gems
          gem 'spree', :path => '../' \n
          gem 'devise', :git => 'git://github.com/plataformatec/devise.git'\n
gems
        end
      end
    end

    def install_generators
      inside "sandbox" do
        run 'bundle install'
        run 'rails g spree:site -f'
        run 'rake spree:install'
        run 'rake spree_sample:install'
      end
    end

    def run_bootstrap
      inside "sandbox" do
        run 'rake db:bootstrap AUTO_ACCEPT=true'
      end
    end

    private
    def remove_directory_if_exists(path)
      run "rm -r #{path}" if File.directory?(path)
    end
  end

  SandboxGenerator.start
end

require 'rspec/core/rake_task'

# TODO: this is copied directly from steak, it would be nice to patch steak to
# do something like Steak::RakeTask.new
namespace :spec do
  desc "Run the code examples in spec/acceptance"
  RSpec::Core::RakeTask.new(:acceptance) do |t|
    t.pattern = "spec/acceptance/**/*_spec.rb"
  end

  task :statsetup do
    require 'rails/code_statistics'
    ::STATS_DIRECTORIES << %w(Acceptance\ specs spec/acceptance) if File.exist?('spec/acceptance')
    ::CodeStatistics::TEST_TYPES << "Acceptance specs" if File.exist?('spec/acceptance')
  end
end

task :spec => :"spec:acceptance"

desc "Regenerates a rails 3 app for testing"
task :test_app do
  require 'lib/generators/spree/test_app_generator'
  class CoreTestAppGenerator < Spree::Generators::TestAppGenerator
    def tweak_gemfile
      append_file 'Gemfile' do
        <<-GEMFILE
gem 'spree_core',   :path => '#{File.expand_path(File.join(File.dirname(__FILE__), 'core'))}'
gem 'spree_promo',  :path => '#{File.expand_path(File.join(File.dirname(__FILE__), 'promo'))}'
gem 'spree_auth',   :path => '#{File.expand_path(File.join(File.dirname(__FILE__), 'auth'))}'
        GEMFILE
      end
    end

    def install_spree_core
      inside "test_app" do
        run 'rake spree_core:install'
        run 'rake spree_promo:install'
        run 'rake spree_auth:install'
      end
    end

    def migrate_db
      run_migrations
    end
  end
  CoreTestAppGenerator.start
end

namespace :test_app do
  desc 'Rebuild test and cucumber databases'
  task :rebuild_dbs do
    system("cd spec/test_app && rake db:drop db:migrate RAILS_ENV=test && rake db:drop db:migrate RAILS_ENV=cucumber")
  end
end


# desc "Release all components to gemcutter."
# task :release_projects => :package do
#   errors = []
#   PROJECTS.each do |project|
#     system(%(cd #{project} && #{$0} release)) || errors << project
#   end
#   fail("Errors in #{errors.join(', ')}") unless errors.empty?
# end
