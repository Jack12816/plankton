![Plankton](doc/assets/project.png)

Plankton is a commandline interface for private Docker Registries (v2). It
supports the anonymous usage as well as the HTTP Basic and Token
Authentication. With the help of Plankton you can interact with tags (list, get
details, remove, cleanup with keep n latest). It is great for automating CI/CD
deployments and save memory at the end.

- [Installation](#installation)
  - [Local](#local)
  - [Docker](#docker)
- [Usage](#usage)
  - [Environment](#environment)
  - [Listing tags](#listing-tags)
  - [Tag details](#tag-details)
  - [Delete a tag](#delete-a-tag)
  - [Cleanup tags](#cleanup-tags)
  - [Gitlab CI](#gitlab-ci)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Installation

### Local

Install it yourself as:

```bash
$ gem install plankton
```

### Docker

There is a Docker image available as
[jack12816/plankton](https://hub.docker.com/r/jack12816/plankton/).  Just pull
it and use it like that:

```bash
# Pull the latest Plankton version
$ docker pull jack12816/plankton
# Ask Plankton for help
$ docker run --rm jack12816/plankton help
# Use Plankton even with environment variables
$ docker run --rm \
    -e REGISTRY_CLI_HOSTNAME=your.registry.tld \
    jack12816/plankton tags
```

## Usage

### Environment

You can pass `--hostname`, `--username` and  `--password` commandline options
to Plankton or use the following environment variables:

```bash
export REGISTRY_CLI_HOSTNAME=
export REGISTRY_CLI_USERNAME=
export REGISTRY_CLI_PASSWORD=
```

The commandline options take precedence over the environment variables.

### Listing tags

You can list all tags of a given repository at your Docker Registry. By default
it will print some handy details (created at date (ISO 8601), layer size). If
you do not care about these additional information or you want to speed up the
command, just disable them by passing the `--no-details` option.

```bash
Usage:
  plankton tags REPO

Options:
  -l, [--limit=N]                  # How many tags to fetch (maximum)
                                   # Default: 20
  -d, [--details], [--no-details]  # Display details (created at date, full layer size)
                                   # Default: true
```

A common output looks like this:

```bash
$ plankton tags apps/fancy

Image tag Created at                Size
1.3.0     2017-09-24T16:36:00+00:00 273.27 MiB
1.2.1     2017-09-24T16:32:56+00:00 273.27 MiB
1.2.0     2017-09-24T16:31:53+00:00 273.27 MiB
1.1.0     2017-09-24T16:31:12+00:00 273.27 MiB
```

The tags are ordered to show the latest created first.

### Tag details

With the help of Plankton it is easy to retreive some details about a tag. Just
specify the repository and the tag name and you will get something like this:

```bash
Usage:
  plankton tag REPO TAG
```

```bash
$ plankton tag apps/fancy 1.0.0

Tag: 1.0.0
Digest: sha256:4fdcb19e157a55eaf1254ef9923216127cb95560b9c0a6e94ae48ac2cefb6674
Created at: 2017-09-24T16:36:00+00:00
Layers: 8
 sha256:d93a2d7cc901177e87182b2003d50fb3ffd5be3eb698f39f5c862264efe6ee99 (50.16 MiB)
 sha256:15a33158a1367c7c4103c89ae66e8f4fdec4ada6a39d4648cf254b32296d6668 (18.37 MiB)
 sha256:f67323742a64d3540e24632f6d77dfb02e72301c00d1e9a3c28e0ef15478fff9 (41.23 MiB)
 sha256:c4b45e832c38de44fbab83d5fcf9cbf66d069a51e6462d89ccc050051f25926d (128.45 MiB)
 sha256:c1d1736737e7ea666709bec11741051fbba7c8f896d17570c82c978413cb3312 (205.00 B)
 sha256:f3fd5681b6bafafd7d45041c29f1df202777ca906f7f01db58556feb177e6dfc (34.42 MiB)
 sha256:ac9eb90ae6f5320100f26741b82ae30d40c407b1f6d0a4974da70bd67da9ab74 (661.22 KiB)
 sha256:aa1e7b8285a7a366476ba71fdfb27b13712415310a063a0c41283326f5aecdbf (164.00 B)
Total layer size: 273.27 MiB
Image:
 Author: Hermann Mayer <hermann.mayer92@gmail.com>
 Operating system: linux
 Architecture: amd64
 Docker version: 17.07.0-ce
Dockerfile:
 Steps: 22
```

### Delete a tag

The `rmtag` operation takes care of deleting a specific tag. This requires a
Docker Registry with the [enabled delete storage
option](https://docs.docker.com/registry/configuration/#delete).  By default
Plankton will ask you for interactive feedback to confirm the operation. You
can make use of the `--no-confirm` option to overcome this on automated usage.

```bash
Usage:
  plankton rmtag REPO TAG

Options:
      [--confirm], [--no-confirm]  # User interaction is required
                                   # Default: true
```

```bash
$ plankton rmtag apps/fancy 1.1.0

Delete apps/fancy:1.1.0? [yes, no] yes
Tag 1.1.0 was successfully deleted.
```

### Cleanup tags

The `cleanup` operation will delete all "old" tags from a repository. You can
configure it to delete all the tags, or keep the last n tags.  This requires a
Docker Registry with the [enabled delete storage
option](https://docs.docker.com/registry/configuration/#delete). By default
Plankton will ask you for interactive feedback to confirm the operation. You
can make use of the `--no-confirm` option to overcome this on automated usage.
You can specify how many tags should stay by passing the `--keep` options. It
defaults to 3.

```bash
Usage:
  plankton cleanup REPO

Options:
  -k, [--keep=N]                   # How many tags to keep
                                   # Default: 3
      [--confirm], [--no-confirm]  # User interaction is required
                                   # Default: true
```

A common output looks like this:

```bash
$ plankton cleanup apps/fancy

 Tags to keep: 3 (819.81 MiB)
Image tag Created at                Size
1.3.0     2017-09-24T16:36:00+00:00 273.27 MiB
1.2.1     2017-09-24T16:32:56+00:00 273.27 MiB
1.2.0     2017-09-24T16:31:53+00:00 273.27 MiB
1.1.0     2017-09-24T16:31:12+00:00 273.27 MiB

 Tags to delete: 1 (273.27 MiB)
Image tag Created at                Size
1.1.0     2017-09-24T16:31:12+00:00 273.27 MiB

     Registry: https://your.registry.tld
   Repository: apps/fancy
 Tags to keep: 3

Cleanup apps/fancy (1 tags)? [yes, no] yes

Deleted 1.1.0 (freed 273.27 MiB)
```

### Gitlab CI

If you are interested in the usage of Plankton ontop of your Gitlab CI system,
here comes a ready to use solution:

```yaml
cleanup:
  image:
    name: jack12816/plankton
    entrypoint: ["/bin/sh", "-c"]
  variables:
    REGISTRY_CLI_HOSTNAME: your.registry.tld
    REGISTRY_CLI_USERNAME: gitlab-ci-token
    REGISTRY_CLI_PASSWORD: ${CI_JOB_TOKEN}
  script: plankton cleanup --keep 3 --no-confirm apps/fancy
```

Just use the Plankton operations as normal. Just setup some Gitlab CI stages to
perform your operations in the correct order. (Something like build, test,
publish, cleanup) The `REGISTRY_CLI_USERNAME` and `REGISTRY_CLI_PASSWORD`
environment variables are correctly set if you use a Docker Registry which is
authenticated by Gitlab. If you use a HTTP Basic Authentication, just set them
accordingly.

**Heads up!** Unfortunately the cleanup actions are not permitted by Gitlab for
the `CI_JOB_TOKEN` at the moment.  You can work around this by following [the
instructions on the
issue](https://github.com/Jack12816/plankton/issues/1#issuecomment-333797086).

## Development

After checking out the repo, run `make install` to install dependencies. Then,
run `make test` to run the tests. You can also run `make shell` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/Jack12816/plankton. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT
License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Plankton project’s codebases, issue trackers, chat
rooms and mailing lists is expected to follow the [code of
conduct](https://github.com/Jack12816/plankton/blob/master/CODE_OF_CONDUCT.md).
