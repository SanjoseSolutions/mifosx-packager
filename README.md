MifosX Packager
===============

Debian packaging for MifosX for Quick installation:

```
$ echo deb http://mifos.sanjosesolutions.in stable main | sudo tee /etc/apt/sources.list.d/mifosx.list
$ sudo apt-get update
$ sudo apt-get install mifosx
```

Setup
-----

Install epm. Download and unzip mifosplatform-RELEASE 1.25 in this folder. Then
generate deb by running:

```
$ make package
```

