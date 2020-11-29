lib = File.expand_path(File.join(__dir__, '..', 'files', 'default', 'vendor'))
$LOAD_PATH.unshift lib if !$LOAD_PATH.include?(lib) && File.directory?(lib)

require 'bundler/setup'

Bundler.require(:test)
CookbookUtils::TestHelper.new(__dir__)
