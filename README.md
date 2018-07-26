# LBH Income API

## Setup

```sh
$ make build
```

## Development

To serve the application, run the following and visit [http://localhost:3000](http://localhost:3000)

```sh
$ make serve
```

To run tests:

```sh
$ make test
```

If you're TDDing code, it can sometimes be faster to boot up the app container once, then run tests within it. That way you don't have to start the docker container every time you run tests:

```sh
$ make serve
# in a separate tab
$ make shell
# after every change
$ rspec
```

The above is useful because you can TDD your change and manually test through the browser without having to restart anything.
