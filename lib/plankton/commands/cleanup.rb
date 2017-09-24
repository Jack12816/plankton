module Plankton::Command::Cleanup
  def self.included(base)
    base.class_eval do
      option :keep,
             desc: 'How many tags to keep',
             default: 3,
             aliases: '-k',
             type: :numeric
      desc 'cleanup REPO', 'Cleanup a given repository'
      def cleanup(repo)
        tags = registry.tags(repo: repo, limit: 200, details: true)
        tags = tags.sort_by { |t| t.created_at }.reverse

        if tags.size.zero?
          puts 'No tags found. Nothing to do.'
          exit
        end

        tags_to_delete = tags.drop(opts.keep)
        tags_to_keep = tags.first(opts.keep)

        puts ["\n", "Tags to keep:", opts.keep,
              "(#{total_size(tags_to_keep)})"].join(' ')
        detailed_tags_table(tags_to_keep)
        puts ["\n", "Tags to delete:", tags_to_delete.size,
              "(#{total_size(tags_to_delete)})"].join(' ')
        detailed_tags_table(tags_to_delete)

        if tags_to_delete.size.zero?
          puts 'No tags need to cleaned.'
          exit
        end

        if confirm?
          puts
          puts "     Registry: #{hostname}"
          puts "   Repository: #{repo}"
          puts " Tags to keep: #{opts.keep}"
          puts
          answer = ask("Cleanup #{repo} (#{tags_to_delete.size} tags)?",
                       limited_to: ['yes', 'no'])
          exit if answer == 'no'
        end
        puts

        tags_to_delete.each do |tag|
          registry.rmtag(repo: repo, tag: tag.tag)
          puts "Deleted #{tag.tag} (freed #{pretty_size(tag.layer_size)})"
        end
      end
    end
  end
end
