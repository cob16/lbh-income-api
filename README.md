# LBH Income API

The Income API is the backend of the [Income Collection Service][github-ics], and connects to the legacy Universal Housing database and the [Tenancy API][github-tenancy-api].

It is used to store users, prioritise cases, assign cases evenly to users, and retrieve information about those cases.

## Stack

- Rails as a web framework.
- Puma as a web server.
- Delayed Job for running background and scheduled tasks.

## Development practices

We employ a variant of Clean Architecture, borrowing from [Made Tech Flavoured Clean Architecture][mt-ca].

## Contributing

### Setup

1. Get a team member to add you to our AWS organisation, download the CLI tools, and login using them.
2. Install [Docker][docker-download].
3. Clone this repository.
4. Run `make build`.

### Development

To serve the application, run the following and visit [http://localhost:3000](http://localhost:3000).

```sh
$ make serve
```

To run tests:

```sh
$ make test
```

If you're TDDing code, it can sometimes be faster to boot up the app container once, then run tests within it. That way you don't have to start the Docker container every time you run tests:

```sh
# start the Docker container
$ make serve

# in a separate tab, run this to get a shell within the Docker container
$ make shell

# run rspec after every change in the Docker container shell
$ rspec
```

The above is useful because you can TDD your change and manually test through the browser without having to restart anything.

### Release

We use a pull request workflow, where changes are made on a branch and approved by one or more other maintainers before the developer can merge into `master`.

Then we have an automated four step deployment process, which runs in CircleCI.

1. Automated tests (RSpec) and linting (Rubocop) are run to ensure the release is of good quality.
2. The app is deployed to staging automatically, where we check our latest changes work well.
3. We manually confirm a production deployment once we're happy with our changes in staging.
4. The app is deployed to production.

### Connection to Universal Housing

Universal Housing configuration is given through environment variables, for example using development details:

- UH_DATABASE_NAME=StubUH
- UH_DATABASE_USERNAME=sa
- UH_DATABASE_PASSWORD=Rooty-Tooty
- UH_DATABASE_HOST=universal_housing
- UH_DATABASE_PORT=1433

We use a [Universal Housing simulator][github-uh-simulator] to run automated tests against, mirroring the structure of the legacy Universal Housing database. This is distributed as a (currently private) Docker image, hosted on AWS ECR (Elastic Container Registry), which this project's Docker Compose configuration depends on.

## Contacts

- Rashmi Shetty, Development Manager at London Borough of Hackney (rashmi.shetty@hackney.gov.uk)
- Vlad Atamanyuk, Junior Developer at London Borough of Hackney (vladyslav.atamanyuk@hackney.gov.uk)
- Mark Rosel, Lead Engineer at [Made Tech][made-tech] (mark.rosel@madetech.com)
- Steven Leighton, Engineer at [Made Tech][made-tech] (steven@madetech.com)
- Cormac Brady, Engineer at [Made Tech][made-tech] (cormac@madetech.com)
- Jeff Pinkham, Engineer at [Made Tech][made-tech] (jeff@madetech.com)
- Elena Vilimaite, Engineer at [Made Tech][made-tech] (elena@madetech.com)
- Richard Foster, Lead Engineer at [Made Tech][made-tech] (richard@madetech.com)
- Luke Morton, Director at [Made Tech][made-tech] (luke@madetech.com)
- Dennis Robinson, Delivery Lead at London Borough of Hackney (dennis.robinson@hackney.gov.uk)
- Soraya Clarke, Delivery Manager at London Borough of Hackney (soraya.clarke@hackney.gov.uk)

[github-uh-simulator]: https://github.com/LBHackney-IT/lbh-universal-housing-simulator
[github-ics]: https://github.com/LBHackney-IT/LBH-IncomeCollection
[github-tenancy-api]: https://github.com/LBHackney-IT/LBHTenancyAPI
[docker-download]: https://www.docker.com/products/docker-desktop
[mt-ca]: https://github.com/madetech/clean-architecture
[made-tech]: https://madetech.com/
