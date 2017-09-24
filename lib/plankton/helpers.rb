module Plankton
  module Helpers
    def opts
      @opts_struct ||= RecursiveOpenStruct.new(options)
    end

    def registry
      unless username? || password?
        return @registry ||= DockerRegistry2.connect(hostname,
                                                     verbose: verbose?)
      end
      @registry ||= DockerRegistry2.connect(hostname,
                                            verbose: verbose?,
                                            user: username,
                                            password: password)
    end

    def pretty_size(bytes)
      Filesize.from("#{bytes} B").pretty
    end

    def detailed_tags_table(tags)
      return if tags.size.zero?
      headers = ['Image tag', 'Created at', 'Size']
      tags = tags.sort_by { |t| t.created_at }.reverse
      rows = tags.map do |tag|
        [
          tag.tag,
          tag.created_at.to_s,
          pretty_size(tag.layer_size)
        ]
      end
      puts TTY::Table.new(headers, rows).render(:basic)
    end

    def total_size(tags)
      pretty_size(tags.reduce(0) { |sum, t| sum + t.layer_size })
    end
  end
end
