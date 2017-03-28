# frozen_string_literal: true

require 'yaml'

module GitSnip
  class Config
    def initialize(repo_path = '.')
      @repo_path = repo_path
    end

    def options
      @options ||= read_file || {}
    end

    private

    def read_file
      YAML.load_file(config_path) if File.exist?(config_path)
    end

    def config_path
      "#{@repo_path.chomp('/')}/.git_snip.yml"
    end
  end
end
