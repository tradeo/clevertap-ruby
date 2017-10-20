require 'rubocop'

gem_root = File.expand_path('../', __FILE__)
CONFIG_FILE_PATH = File.join(gem_root, 'config', 'rubocop_spec.yml')

describe 'rubocop' do
  let(:args) { ['--format', 'simple', '-D', gem_root] }

  it 'passes all cops' do
    expect { RuboCop::CLI.new.run(args) }.to output(/no offenses detected/).to_stdout
  end
end
