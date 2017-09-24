module Plankton::Command::Tags
  def self.included(base)
    base.class_eval do
      option :limit,
             desc: 'How many tags to fetch (maximum)',
             default: 20,
             aliases: '-l',
             type: :numeric
      option :details,
             desc: 'Display details (created at date, full layer size)',
             default: true,
             aliases: '-d',
             type: :boolean
      desc 'tags REPO', 'List all tags of a given repository'
      def tags(repo)
        if opts.details
          tags = registry.tags(repo: repo,
                               details: true,
                               limit: opts.limit)
          detailed_tags_table(tags)
        else
          tags = registry.tags(repo: repo, limit: opts.limit)
          tags.each do |tag|
            puts tag
          end
        end
        puts 'No tags found.' if tags.size.zero?
      end
    end
  end
end
