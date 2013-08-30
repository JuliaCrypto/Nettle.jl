Nettle.jl
=========

A simple wrapper around [libnettle](http://www.lysator.liu.se/~nisse/nettle/nettle.html), a cryptographic library.

Example usage:
```julia
using Nettle

secret_key = "this is a secret"
data = "this is my data"

h = HMACState(SHA256, secret_key)
update!(h, data)
hexdigest!(h)
```

Outputs:

```
"34716fd7c26bf0748f6d730cf14cff1a049ab130e292e9807f7c108dbeb933b9"
```

`libnettle` contains many cryptographic functions, as more are exposed by this wrapper, sections below will be updated.

Hashing Functionality
=====================

`libnettle` supports a wide array of hashing algorithms.  This package interrogates `libnettle` at startup to determine the available hash types, which are then available in `Nettle.HashAlgorithms`.  Typically these include `SHA1`, `SHA256`, `SHA384`, `SHA512`, `SHA3_256`, `SHA3_512`, `MD2`, `MD5` and `RIPEMD160`.  The Hashing algorithms are also exported by `Nettle`, so you may access them with just `SHA256`, for example.

Typical usage of these hash algoritms is to 


HMAC Functionality
==================
[HMAC](http://en.wikipedia.org/wiki/Hash-based_message_authentication_code) functionality revolves around the `HMACState` type, created by the function of the same name.  Arguments to this constructor are the desired hash type, and the desired key used to authenticate the hashing:

```julia
h = HMACState(SHA256, "mykey")
```

Valid 

