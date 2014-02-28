module VagrantPlugins
  module VagrantFlow
    class Plugin < Vagrant.plugin(2)

      name 'vagrant-flow'
      description 'Plugin allows to generate a ansible inventory file.'

      # config :exec do
      #   require_relative 'config'
      #   Config
      # end

      command("ansible-inventory") do
        require_relative 'command'
        Command
      end

    end # Plugin
  end # Exec
end # VagrantPlugins
