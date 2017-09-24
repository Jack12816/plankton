module Plankton
  module EnvVars
    def hostname
      host = (ENV.fetch('REGISTRY_CLI_HOSTNAME', nil) || opts.hostname)
      if host.nil? || host == 'hostname'
        raise EnvVarNotFoundError, 'Docker Registry hostname'
      end
      host = host.dup.prepend('https://') unless %r{^https?://} =~ host
      host.gsub(%r{/*$}, '').strip
    end

    def username
      user = (ENV.fetch('REGISTRY_CLI_USERNAME', nil) || opts.username)
      return nil if user.nil?
      user.gsub(%r{/*$}, '').strip
    end

    def username?
      !username.nil?
    end

    def password
      pass = (ENV.fetch('REGISTRY_CLI_PASSWORD', nil) || opts.password)
      return nil if pass.nil?
      pass.gsub(%r{/*$}, '').strip
    end

    def password?
      !password.nil?
    end

    def verbose?
      opts.verbose
    end

    def confirm?
      opts.confirm
    end
  end
end
