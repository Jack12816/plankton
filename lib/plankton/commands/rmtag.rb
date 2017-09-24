module Plankton::Command::Rmtag
  def self.included(base)
    base.class_eval do
      desc 'rmtag REPO TAG', 'Delete a given tag'
      def rmtag(repo, tag)
        if confirm?
          answer = ask("Delete #{repo}:#{tag}?", limited_to: ['yes', 'no'])
          exit if answer == 'no'
        end
        registry.rmtag(repo: repo, tag: tag)
        puts "Tag #{tag} was successfully deleted."
      rescue RestClient::NotFound => e
        puts "Tag #{tag} was not found. (#{e.message})"
        exit 1
      end
    end
  end
end
