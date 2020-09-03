# Crip

We have `pip` "Pip Installs Packages",
and this is `crip` Container Registry Installed Packages.

## Install

```shell
curl --silent -o /usr/local/bin/crip \
    https://raw.githubusercontent.com/svlentink/crip/master/crip.sh
chmod +x /usr/local/bin/crip
```

## Why?

At multiple companies I encountered that they did not have
(an easy accessible) internal/private python package repository.
But most companies do have a container registry,
which can be used to store data:

```Dockerfile
FROM scratch
COPY my-content /
```

However, not every environment comes with the option to run container
(e.g. WSL 1 or CDSW),
thus not the option to run or develop inside a container.

For this use case, this project was started,
being able to retrieve data
(without `docker` installed)
from a container registry.

