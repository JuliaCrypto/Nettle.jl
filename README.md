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

#or...
bytes2hex(sha256_hmac(secret_key, data))
```

Outputs:

```
"34716fd7c26bf0748f6d730cf14cff1a049ab130e292e9807f7c108dbeb933b9"
```

`libnettle` contains many cryptographic functions, as more are exposed by this wrapper, sections below will be updated.

Hashing Functionality
=====================

`libnettle` supports a wide array of hashing algorithms.  This package interrogates `libnettle` at startup to determine the available hash types, which are then available in `Nettle.HashAlgorithms`.  Typically these include `SHA1`, `SHA224`, `SHA256`, `SHA384`, `SHA512`, `MD2`, `MD5` and `RIPEMD160`.  The Hashing algorithms are also individually exported by `Nettle`, so you may access them with just `SHA256`, for example.

Typical usage of these hash algorithms is to create a `HashState`, `update!` it, and finally get a `digest`:

```julia
h = HashState(SHA256)
update!(h, "this is a test")
hexdigest!(h)

#or...
bytes2hex(sha256_hash("this is a test"))
```

Outputs:

```
2e99758548972a8e8822ad47fa1017ff72f06f3ff6a016851f45c398732bc50c
```

A `digest!` function is also available to return the digest as an `Array(Uint8,1)`.  Note that both the `digest!` function and the `hexdigest!` function reset the internal `HashState` object to a pristine state, ready for further `update!` calls.


HMAC Functionality
==================
[HMAC](http://en.wikipedia.org/wiki/Hash-based_message_authentication_code) functionality revolves around the `HMACState` type, created by the function of the same name.  Arguments to this constructor are the desired hash type, and the desired key used to authenticate the hashing:

```julia
h = HMACState(SHA256, "mykey")
update!(h, "this is a test")
hexdigest!(h)
```

Outputs:

```
"ca1dcafe1b5fb329256248196c0f92a95fbe3788db6c5cb0775b4106db437ba2"
```

A `digest!` function is also available to return the digest as an `Array(Uint8,1)`.  Note that both the `digest!` function and the `hexdigest!` function reset the internal `HMACState` object to a pristine state, ready for further `update!` calls.
