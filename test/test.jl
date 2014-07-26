using Nettle
using Base.Test


# MD5 HMAC tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/hmac-test.c
for (key,text,digest) in {
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
}
    @test md5_hmac(key,text) == hex2bytes(digest)
end


# SHA1 HMAC tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/hmac-test.c
for (key,text,digest) in {
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
}
    @test sha1_hmac(key,text) == hex2bytes(digest)
end


# SHA256 HMAC tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/hmac-test.c
for (key,text,digest) in {
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
}
    @test sha256_hmac(key,text) == hex2bytes(digest)
end

# MD5 hash tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/md5-test.c
for (text, hash) in {
    (
        "",
        "d41d8cd98f00b204e9800998ecf8427e"
    ),(
        "a",
        "0cc175b9c0f1b6a831c399e269772661"
    ),(
        "abc",
        "900150983cd24fb0d6963f7d28e17f72"
    ),(
        "message digest",
        "f96b697d7cb7938d525a2f31aaf161d0"
    ),(
        "abcdefghijklmnopqrstuvwxyz",
        "c3fcd3d76192e4007dfb496cca67e13b"
    ),(
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef" *
        "ghijklmnopqrstuvwxyz0123456789",
        "d174ab98d277d9f5a5611c2c9f419d9f"
    ),(
        "12345678901234567890123456789012" *
        "34567890123456789012345678901234" *
        "5678901234567890",
        "57edf4a22be3c955ac49da2e2107b67a"
    )
}
    @test md5_hash(text) == hex2bytes(hash)
end


# SHA1 hash tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/sha1-test.c
for (text, hash) in {
    (
        "",
        "da39a3ee5e6b4b0d3255bfef95601890afd80709",
    ),(
        "a",
        "86f7e437faa5a7fce15d1ddcb9eaeaea377667b8",
    ),(
        "abc",
        "a9993e364706816aba3e25717850c26c9cd0d89d",
    ),(
        "abcdefghijklmnopqrstuvwxyz",
        "32d10c7b8cf96570ca04ce37f2a19d84240d3a89",
    ),(
        "message digest",
        "c12252ceda8be8994d5fa0290a47231c1d16aae3",
    ),(
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmn" *
        "opqrstuvwxyz0123456789",
        "761c457bf73b14d27e9e9265c46f4b4dda11f940",
    ),(
        "1234567890123456789012345678901234567890" *
        "1234567890123456789012345678901234567890",
        "50abf5706a150990a08b2c5ea40fa0e585554732",
    ),(
        "38", 
        "5b384ce32d8cdef02bc3a139d4cac0a22bb029e8"
    )
}
    @test sha1_hash(text) == hex2bytes(hash)
end


# SHA256 hash tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/sha256-test.c
for (text,hash) in {
    (
        "abc",
        "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
    ),( 
        "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
        "248d6a61d20638b8e5c026930c3e6039a33ce45964ff2167f6ecedd419db06c1"
    ),(
        "abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmno" *
        "ijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu",
        "cf5b16a778af8380036ce59e7b0492370b249b11e8f07a51afac45037afee9d1"
    ),(
        "",
        "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    ),(
        "a",
        "ca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb"
    ),(
        "38",
        "aea92132c4cbeb263e6ac2bf6c183b5d81737f179f21efdc5863739672f0f470"
    ),(
        "message digest",
        "f7846f55cf23e14eebeab5b4e1550cad5b509e3348fbc4efa3a1413d393cb650"
    ),(
        "abcdefghijklmnopqrstuvwxyz",
        "71c480df93d6ae2f1efad1447c66c9525e316218cf51fc8d9ed832f2daf18b73"
    ),(
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789",
        "db4bfcbd4da0cd85a60c3c37d3fbd8805c77f15fc6b1fdfe614ee0a7c8fdb4c0"
    ),(
        "1234567890123456789012345678901234567890123456789012345678901234" *
        "5678901234567890",
        "f371bc4a311f2b009eef952dd83ca80e2b60026c8e935592d0f9c308453c813e"
    )
}
    @test sha256_hash(text) == hex2bytes(hash)
end


# Test that digest!() actually resets the HashState
h = HashState(SHA1)
update!(h,"")
@test hexdigest!(h) == "da39a3ee5e6b4b0d3255bfef95601890afd80709"
update!(h,"The quick brown fox jumps over the lazy dog")
@test hexdigest!(h) == "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12"
h = HashState(SHA256)
update!(h,"The quick brown fox jumps over the lazy dog")
@test hexdigest!(h) == "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"
