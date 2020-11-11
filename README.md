# imago-maximo

A collection of container images.

```shell
alias docker=podman
```

## qpid-proton

Apache QPID CPP and QPID Proton in a Debian based image.

```shell
export QPID_PROTON_VER="0.32.0"
docker build \
 --build-arg QPIDPROTON_VER="${QPID_PROTON_VER}" \
 --build-arg QPIDCPP_VER="1.39.0" \
 --tag s33pol/qpid-proton:${QPID_PROTON_VER} \
 -f qpid-proton.Containerfile \
 .
```

## s33pol/go-vscode

VSCode 'Remote Container" base for a Debian based Go 1 build.

```shell
docker build \
 --tag s33pol/golang-vscode \
 -f go-vscode.Containerfile \
 .
```
