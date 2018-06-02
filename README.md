Nettle.jl
=========

[![Build Status](https://travis-ci.org/staticfloat/Nettle.jl.svg?branch=master)](https://travis-ci.org/staticfloat/Nettle.jl) [![Build status](https://ci.appveyor.com/api/projects/status/auhjpg59nw3a3aij?svg=true)](https://ci.appveyor.com/project/staticfloat/nettle-jl)


`libnettle` supports a wide array of hashing algorithms.  This package interrogates `libnettle` to determine the available hash types, which are then available from `Nettle.get_hash_types()`.  Typically these include `SHA1`, `SHA224`, `SHA256`, `SHA384`, `SHA512`, `MD2`, `MD5` and `RIPEMD160`.

Typical usage of these hash algorithms is to create a `Hasher`, `update!` it, and finally get a `digest`:

```julia
h = Hasher("sha256")
update!(h, "this is a test")
hexdigest!(h)

#or...
hexdigest("sha256", "this is a test")
```

Outputs:

```
2e99758548972a8e8822ad47fa1017ff72f06f3ff6a016851f45c398732bc50c
```

A `digest!` function is also available to return the digest as an `Array(UInt8,1)`.  Note that both the `digest!` function and the `hexdigest!` function reset the internal `Hasher` object to a pristine state, ready for further `update!` calls.


HMAC Functionality
==================
[HMAC](http://en.wikipedia.org/wiki/Hash-based_message_authentication_code) functionality revolves around the `HMACState` type, created by the function of the same name.  Arguments to this constructor are the desired hash type, and the desired key used to authenticate the hashing:

```julia
h = HMACState("sha256", "mykey")
update!(h, "this is a test")
hexdigest!(h)

#or...
hexdigest("sha256", "mykey", "this is a test")
```

Outputs:

```
"ca1dcafe1b5fb329256248196c0f92a95fbe3788db6c5cb0775b4106db437ba2"
```

A `digest!` function is also available to return the digest as an `Array(UInt8,1)`.  Note that both the `digest!` function and the `hexdigest!` function reset the internal `HMACState` object to a pristine state, ready for further `update!` calls.


Encryption/Decryption Functionality
==================================

Nettle also provides encryption and decryption functionality, using the `Encryptor` and `Decryptor` objects.  Cipher types are available through `get_cipher_types()`.  Create a pair of objects with a shared key, and `encrypt()`/`decrypt()` to your heart's content:

```julia
key = "this key's exactly 32 bytes long"
enc = Encryptor("AES256", key)
plaintext = "this is 16 chars"
ciphertext = encrypt(enc, plaintext)

dec = Decryptor("AES256", key)
deciphertext = decrypt(dec, ciphertext)
Vector{UInt8}(plaintext) == deciphertext # no bytestring

# or...
decrypt("AES256", key, encrypt("AES256", key, plaintext)) == Vector{UInt8}(plaintext)
```

For AES256CBC encrypt/decrypt, generate a pair of key32 and iv16 with salt.

(And add or trim padding yourself.)

```julia
passwd = "Secret Passphrase"
salt = hex2bytes("a3e550e89e70996c") # use random 8 bytes
(key32, iv16) = gen_key32_iv16(Vector{UInt8}(passwd), salt)

enc = Encryptor("AES256", key32)
plaintext = "Message"
ciphertext = encrypt(enc, :CBC, iv16, add_padding_PKCS5(Vector{UInt8}(plaintext), 16))

dec = Decryptor("AES256", key32)
deciphertext = decrypt(dec, :CBC, iv16, ciphertext)
Vector{UInt8}(plaintext) == trim_padding_PKCS5(deciphertext) # no bytestring

# or...
plainbytes = hex2bytes("414155aa5541416162")
cipherbytes = encrypt("AES256", :CBC, iv16, key32, add_padding_PKCS5(plainbytes, 16))
decipherbytes = decrypt("AES256", :CBC, iv16, key32, cipherbytes)
plainbytes == trim_padding_PKCS5(decipherbytes) # no bytestring
```
