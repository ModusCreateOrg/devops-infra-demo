consul-ssl
==========

Check `generate-certs.sh` and edit the variables to suit your needs.

Then run:

```
./generate-certs.sh
```

or

```
docker run --rm -v $(pwd):/run -w /run ubuntu:latest ./generate-certs.sh
```

This will generate:
 * `ca.crt`
 * `consul.key`
 * `consul.crt`

Move these files into `packer/files/consul.d/ssl/` and rebuild the AMI.
