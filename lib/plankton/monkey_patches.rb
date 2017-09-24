# Monkey patch the DockerRegistry2::Registry issues away.
#
# Things that are broken by default:
# * pull
#
# Things that are not ideal:
# * Tons of round trips while auth probing (again, and again, and again..)
# * Tons of round trips to always get a "fresh" JWT token
# * Performance
#
# See: https://docs.docker.com/registry/spec/api
# See: https://github.com/gitlabhq/gitlabhq/tree/v10.0.0/lib/container_registry
class DockerRegistry2::Registry
  # All these methods are useful, but needs some improvements
  # from outer space.
  alias_method :orig_initialize, :initialize
  alias_method :orig_rmtag, :rmtag
  alias_method :orig_authenticate_bearer, :authenticate_bearer
  alias_method :orig_do_basic_req, :do_basic_req
  alias_method :orig_do_bearer_req, :do_bearer_req
  alias_method :orig_doreq, :doreq

  # @param [#to_s] base_uri Docker registry base URI
  # @param [Hash] options Client options
  # @option options [#to_s] :user User name for basic authentication
  # @option options [#to_s] :password Password for basic authentication
  def initialize(uri, options = {})
    @verbose = options.key?(:verbose) ? options[:verbose] : false
    orig_initialize(uri, options)
  end

  # Speed up processing, by memorizing the JWT token
  # for the given header.
  def authenticate_bearer(header)
    @token ||= {}
    @token[header] ||= orig_authenticate_bearer(header)
  end

  # Save the auth type as basic, when the very first (ping)
  # request was successful.
  def do_basic_req(type, url, stream = nil)
    res = orig_do_basic_req(type, url, stream)
    @auth ||= :basic
    res
  end

  # Save the auth type as bearer, when the very first (ping)
  # request was successful.
  def do_bearer_req(type, url, header, stream = nil)
    res = orig_do_bearer_req(type, url, header, stream)
    @auth ||= :bearer
    @header = header
    res
  end

  # # Speed up the system by memorize the probed auth type.
  def doreq(type, url, stream = nil)
    puts "[#{type.upcase}] #{@base_uri}#{url}" if @verbose
    return orig_do_basic_req(type, url, stream) if @auth == :basic
    return orig_do_bearer_req(type, url, @header, stream) if @auth == :bearer
    orig_doreq(type, url, stream)
  rescue DockerRegistry2::RegistryAuthenticationException
    orig_doreq(type, url, stream)
  end

  # Do it the same way as the original, but return a OpenStruct
  # because its easy to work with.
  def manifest(repo:, tag:)
    res = doget("/v2/#{repo}/manifests/#{tag}")
    digest = res.headers[:docker_content_digest]
    res = RecursiveOpenStruct.new(JSON.parse(res), recurse_over_arrays: true)
    res.digest = digest
    res
  end

  # Download a blob to a opened IO handle.
  def blob(repo, digest, file)
    doreq('get', "/v2/#{repo}/blobs/#{digest}", file)
  end

  # Pull all layers of a given tag.
  def pull(repo:, tag:, dir:)
    # make sure the directory exists
    FileUtils::mkdir_p(dir)
    # pull each of the layers
    manifest(repo: repo, tag: tag).layers.each do |layer|
      # make sure the layer does not exist first
      unless File.file? "#{dir}/#{layer.digest}"
        blob(repo, layer.digest, File.new("#{dir}/#{layer.digest}", 'w+'))
      end
    end
  end

  # Fetch details about a tag.
  def tag(repo:, tag:)
    # Create new string IO handle
    config_input = StringIO.new
    # Download the manifest for the tag
    manifest = manifest(repo: repo, tag: tag)
    # Download the config blob for the tag
    blob(repo, manifest.config.digest, config_input)
    # Parse the JSON input
    config = RecursiveOpenStruct.new(JSON.parse(config_input.string))
    created = DateTime.parse(config.created)
    layer_size = manifest.layers.reduce(0) { |sum, l| sum + l.size }
    # Pass back all the detailed information
    OpenStruct.new(tag: tag,
                   digest: manifest.digest,
                   created_at: created,
                   layer_size: layer_size,
                   config: config,
                   manifest: manifest)
  end

  # Fetch all tags of a repository, with the possibility to fetch
  # all their details as well.
  def tags(repo:, details: false, limit: 20)
    unless details
      res = JSON.parse(doget("/v2/#{repo}/tags/list?n=#{limit}"))
      return RecursiveOpenStruct.new(res).tags || []
    end
    tags(repo: repo).map { |tag| tag(repo: repo, tag: tag) }
  end

  # Sometimes it is handy do delete a tag by its name, sometimes it is
  # handy to delete a tag by its digest. The digest variant is faster due
  # no lookup have to be done.
  def rmtag(repo:, tag: nil, digest: nil)
    raise 'No tag or digest was given' if tag.nil? && digest.nil?
    return orig_rmtag(repo, tag) unless tag.nil?
    dodelete("/v2/#{repo}/manifests/#{digest}").code
  end
end
