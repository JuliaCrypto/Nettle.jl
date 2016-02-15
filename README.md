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
plaintext == bytestring(deciphertext)

# or...
decrypt("AES256", key, encrypt("AES256", key, plaintext)) == plaintext.data
```

For AES256CBC encrypt/decrypt, generate a pair of key32 and iv16 with salt.

(And add or trim padding yourself.)

```julia
passwd = "Secret Passphrase"
salt = hex2bytes("a3e550e89e70996c") # use random 8 bytes
s1 = digest("MD5", [passwd.data; salt])
s2 = digest("MD5", [s1; passwd.data; salt])
s3 = digest("MD5", [s2; passwd.data; salt])
key32 = [s1; s2]
iv16 = s3

enc = Encryptor("AES256", key32)
plaintext = "Message"
num = 16 - (length(plaintext) % 16)
bytes16 = [plaintext.data; map(i -> UInt8(num), 1:num)]
ciphertext = encrypt(enc, :CBC, iv16, bytes16) # add padding yourself (PKCS#5)

# after encrypt, the value of iv16 (and s3) is changed
# reset key32 and iv16

passwd = "Secret Passphrase"
salt = hex2bytes("a3e550e89e70996c")
s1 = digest("MD5", [passwd.data; salt])
s2 = digest("MD5", [s1; passwd.data; salt])
s3 = digest("MD5", [s2; passwd.data; salt])
key32 = [s1; s2]
iv16 = s3

dec = Decryptor("AES256", key32)
deciphertext = decrypt(dec, :CBC, iv16, ciphertext)
padlen = deciphertext[length(deciphertext)] # trim padding yourself (PKCS#5)
plaintext == bytestring(deciphertext[1:length(deciphertext)-padlen])

# or... (add or trim padding yourself)
cipherbytes = encrypt("AES256", :CBC, iv16, key32, plainbytes)
decipherbytes = decrypt("AES256", :CBC, iv16, key32, cipherbytes)
```
