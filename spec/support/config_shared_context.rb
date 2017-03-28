# frozen_string_literal: true

require 'yaml'

shared_context 'config' do
  def create_config(config_dir, options)
    FileUtils.mkdir_p(config_dir)
    File.open(config_path(config_dir), 'w') { |f| f.write(options.to_yaml) }
  end

  def remove_config(config_dir)
    path = config_path(config_dir)

    FileUtils.rm_f(path)
  end

  def config_path(config_dir)
    "#{config_dir}/.git_snip.yml"
  end
end
