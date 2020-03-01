# alexhaydock.co.uk

[![pipeline status](https://gitlab.com/alexhaydock/alexhaydock.co.uk/badges/master/pipeline.svg)](https://gitlab.com/alexhaydock/alexhaydock.co.uk/-/commits/master)

A live repo for [my personal website](https://alexhaydock.co.uk).

My site is based on the [al-folio](https://alshedivat.github.io/al-folio/) Jekyll theme.

### Test Locally
```sh
make test
```

### Build & Push to GitLab
```sh
make build
```

### Deployment (x86_64 / armv7l / aarch64):
```sh
docker run --rm -it -p "80:80/tcp" "registry.gitlab.com/alexhaydock/alexhaydock.co.uk"
```