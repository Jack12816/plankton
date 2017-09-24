module Plankton::Command::Tag
  def self.included(base)
    base.class_eval do
      desc 'tag REPO TAG', 'All the details of of a given tag'
      def tag(repo, tag)
        tag = registry.tag(repo: repo, tag: tag)
        puts "Tag: #{tag.tag}"
        puts "Digest: #{tag.digest}"
        puts "Created at: #{tag.created_at}"
        puts "Layers: #{tag.manifest.layers.size}"
        tag.manifest.layers.each do |layer|
          puts " #{layer.digest} (#{pretty_size(layer.size)})"
        end
        puts "Total layer size: #{pretty_size(tag.layer_size)}"
        puts "Image:"
        puts " Author: #{tag.config.author}"
        puts " Operating system: #{tag.config.os}"
        puts " Architecture: #{tag.config.architecture}"
        puts " Docker version: #{tag.config.docker_version}"
        puts "Dockerfile:"
        puts " Steps: #{tag.config.history.size}"
      rescue RestClient::NotFound => e
        puts "Tag #{tag} was not found. (#{e.message})"
        exit 1
      end
    end
  end
end
