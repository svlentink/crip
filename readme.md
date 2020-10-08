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

## Layout

### crip

Wrapper around `crput` for `crip create`
and `crget` for `crip [install|remove]`.

It makes sure that when installing or removing it is done from the default Python library directory of your OS.

Example using the container created with the `crput` example below;
```shell
crip install my_container_image:latest -req 'mv *.crt /etc/ssl/certs/'
```
Which will install the `requirements.txt` from the container
(`-req` is a short hand for
`'pip3 install -r requirements.txt;rm requirements.txt'`),
move the certificate in the right place and makes the `my_python_lib` globally available in Python through
`import my_python_lib`.


### crput

This is the only of the 3 that requires docker.
What is basically does is package your files as an container image that only holds your designated files.
Note that it only creates the image, you still need to `docker push`.

An alternative is to do this manually in your CI/CD pipeline:
```Dockerfile
FROM scratch AS bundler
COPY self-signed.crt /
COPY my_python_lib.py /
COPY requirements.txt /
FROM scratch
COPY --from=bundler / /
```

