# MD5 HMAC tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/hmac-test.c
for (key,text,true_digest) in [
    (
        "",
        "",
        "74e6f7298a9c2d168935f58c001bad88"
    ),(
        "key",
        "The quick brown fox jumps over the lazy dog",
        "80070713463e7749b90c2dc24911e275"
    ),(
        hex2bytes(
        "0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b"),
        "Hi There",
        "9294727a3638bb1c13f48ef8158bfc9d"
    ),(
        "Jefe",
        "what do ya want for nothing?",
        "750c783e6ab0b503eaa86e310a5db738"
    ),(
        hex2bytes(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
        hex2bytes(
        "dddddddddddddddddddddddddddddddd" *
        "dddddddddddddddddddddddddddddddd" *
        "dddddddddddddddddddddddddddddddd" *
        "dddd"),
        "56be34521d144c88dbb8c733f0e8b3f6"
    ),(
        hex2bytes(
        "0102030405060708090a0b0c0d0e0f10" *
        "111213141516171819"),
        hex2bytes(
        "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" *
        "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" *
        "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" *
        "cdcd"),
        "697eaf0aca3a3aea3a75164746ffaa79"
    ),(
        hex2bytes(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
        "Test Using Larger Than Block-Size Key - Hash Key First",
        "6b1ab7fe4bd7bf8f0b62e6ce61b9d0cd"
    ),(
        hex2bytes(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
        "Test Using Larger Than Block-Size Key and Larger " *
        "Than One Block-Size Data",
        "6f630fad67cda0ee1fb1f562db3aa53e"
    )
]
    @test digest("md5", key, text) == hex2bytes(true_digest)
end


# SHA1 HMAC tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/hmac-test.c
for (key,text,true_digest) in [
    (
        "",
        "",
        "fbdb1d1b18aa6c08324b7d64b71fb76370690e1d"
    ),(
        "key",
        "The quick brown fox jumps over the lazy dog",
        "de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9"
    ),(
        hex2bytes(
        "0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b"),
        "Hi There",
        "b617318655057264e28bc0b6fb378c8ef146be00"
    ),(
        "Jefe",
        "what do ya want for nothing?",
        "effcdf6ae5eb2fa2d27416d5f184df9c259a7c79"
    ),(
        hex2bytes(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
        hex2bytes(
        "dddddddddddddddddddddddddddddddd" *
        "dddddddddddddddddddddddddddddddd" *
        "dddddddddddddddddddddddddddddddd" *
        "dddd"),
        "125d7342b9ac11cd91a39af48aa17b4f63f175d3"
    ),(
        hex2bytes(
        "0102030405060708090a0b0c0d0e0f10" *
        "111213141516171819"),
        hex2bytes(
        "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" *
        "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" *
        "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" *
        "cdcd"),
        "4c9007f4026250c6bc8414f9bf50c86c2d7235da"
    ),(
        hex2bytes(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
        "Test Using Larger Than Block-Size Key - Hash Key First",
        "aa4ae5e15272d00e95705637ce8a3b55ed402112"
    ),(
        hex2bytes(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
        "Test Using Larger Than Block-Size Key and Larger " *
        "Than One Block-Size Data",
        "e8e99d0f45237d786d6bbaa7965c7808bbff1a91"
    )
]
    @test hexdigest("sha1", key, text) == true_digest
end


# SHA256 HMAC tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/hmac-test.c
for (key,text,true_digest) in [
   (
        "",
        "",
        "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad"
    ),(
        "key",
        "The quick brown fox jumps over the lazy dog",
        "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8"
    ),(
        hex2bytes(
        "0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b" *
        "0b0b0b0b"),
        "Hi There",
        "b0344c61d8db38535ca8afceaf0bf12b" *
        "881dc200c9833da726e9376c2e32cff7"
    ),(
        "Jefe",
        "what do ya want for nothing?",
        "5bdcc146bf60754e6a042426089575c7" *
        "5a003f089d2739839dec58b964ec3843"
    ),(
        hex2bytes(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaa"),
        hex2bytes(
        "dddddddddddddddddddddddddddddddd" *
        "dddddddddddddddddddddddddddddddd" *
        "dddddddddddddddddddddddddddddddd" *
        "dddd"),
        "773ea91e36800e46854db8ebd09181a7" *
        "2959098b3ef8c122d9635514ced565fe"
    ),(
        hex2bytes(
        "0102030405060708090a0b0c0d0e0f10" *
        "111213141516171819"),
        hex2bytes(
        "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" *
        "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" *
        "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" *
        "cdcd"),
        "82558a389a443c0ea4cc819899f2083a" *
        "85f0faa3e578f8077a2e3ff46729665b"
    ),(
        hex2bytes(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaa"),
        "Test Using Larger Than Block-Size Key - Hash Key First",
        "60e431591ee0b67f0d8a26aacbf5b77f" *
        "8e0bc6213728c5140546040f0ee37f54"
    ),(
        hex2bytes(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaa"),
        "This is a test using a larger than block-size ke" *
        "y and a larger than block-size data. The key nee" *
        "ds to be hashed before being used by the HMAC al" *
        "gorithm.",
        "9b09ffa71b942fcb27635fbcd5b0e944" *
        "bfdc63644f0713938a7f51535c3a35e2"
    )
]
    h = HMACState("sha256", key)
    update!(h, text)
    @test hexdigest!(h) == true_digest
end

# Test invalid parameters
@test_throws ArgumentError HMACState("this is not a cipher", "")

# Test show methods
println("Testing HMAC show methods:")
println(HMACState("SHA256", ""))
