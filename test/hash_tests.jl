# -*- coding: utf-8 -*-
# MD5 hash tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/md5-test.c
for (text, hash) in [
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
    ),(
        "UTF8String(∀)",
        "cb2e2ce95d88a414ccd3773c1108f489"
    ),(
        "UTF8String(\xe2\x88\x80)",
        "cb2e2ce95d88a414ccd3773c1108f489"
    ),(
        hex2bytes("6e6f74555446382855aa5529"), # "notUTF8(\x55\xaa\x55)".data
        "b0672a2efe1f1d2906e236687ae0153c"
    )
]
    @test digest("md5", text) == hex2bytes(hash)
end


# SHA1 hash tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/sha1-test.c
for (text, hash) in [
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
]
    @test hexdigest("sha1", text) == hash
end


# SHA256 hash tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/sha256-test.c
for (text,hash) in [
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
]
    h = Hasher("sha256")
    update!(h, text)
    @test hexdigest!(h) == hash
end


# Test that digest!() actually resets the HashState
h = Hasher("SHA1")
update!(h,"")
@test hexdigest!(h) == "da39a3ee5e6b4b0d3255bfef95601890afd80709"
update!(h,"The quick brown fox jumps over the lazy dog")
@test hexdigest!(h) == "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12"
h = Hasher("SHA256")
update!(h,"The quick brown fox jumps over the lazy dog")
@test hexdigest!(h) == "d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"

# Test invalid parameters
@test_throws ArgumentError Hasher("this is not a hash name")

# Test show methods
println("Testing hash show methods:")
println(get_hash_types()["SHA256"])
println(Hasher("SHA256"))
