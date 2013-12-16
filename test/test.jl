using Nettle
using Base.Test

# Hash tests
h = HashState(MD5)
update!(h,"")
@test hexdigest!(h) == "d41d8cd98f00b204e9800998ecf8427e"
h = HashState(SHA1)
update!(h,"")
@test hexdigest!(h) == "da39a3ee5e6b4b0d3255bfef95601890afd80709"

# Test digest!() actually resets the HashState
update!(h,"The quick brown fox jumps over the lazy dog")
@test hexdigest!(h) == "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12"
h = HashState(SHA256)
update!(h,"The quick brown fox jumps over the lazy dog")
@test hexdigest!(h) == "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"




# HMAC tests
h = HMACState(MD5,"")
update!(h,"")
@test hexdigest!(h) == "74e6f7298a9c2d168935f58c001bad88"
h = HMACState(SHA1,"")
update!(h,"")
@test hexdigest!(h) == "fbdb1d1b18aa6c08324b7d64b71fb76370690e1d"
h = HMACState(SHA256,"")
update!(h,"")
@test hexdigest!(h) == "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad"

# Keyed HMAC tests
h = HMACState(MD5,"key")
update!(h,"The quick brown fox jumps over the lazy dog")
@test hexdigest!(h) == "80070713463e7749b90c2dc24911e275"
h = HMACState(SHA1,"key")
update!(h,"The quick brown fox jumps over the lazy dog")
@test hexdigest!(h) == "de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9"
h = HMACState(SHA256,"key")
update!(h,"The quick brown fox jumps over the lazy dog")
@test hexdigest!(h) == "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8"
