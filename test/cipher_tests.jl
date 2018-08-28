# -*- coding: utf-8 -*-
# AES tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/aes-test.c

# AES 128
for (key,text,encrypted) in [
    (
        "00010203050607080A0B0C0D0F101112",
        "506812A45F08C889B97F5980038B8359",
        "D8F532538289EF7D06B506A4FD5BE9C9"
    ),(
        "14151617191A1B1C1E1F202123242526",
        "5C6D71CA30DE8B8B00549984D2EC7D4B",
        "59AB30F4D4EE6E4FF9907EF65B1FB68C"
    ),(
        "28292A2B2D2E2F30323334353738393A",
        "53F3F4C64F8616E4E7C56199F48F21F6",
        "BF1ED2FCB2AF3FD41443B56D85025CB1",
    ),(
        "A0A1A2A3A5A6A7A8AAABACADAFB0B1B2",
        "F5F4F7F684878689A6A7A0A1D2CDCCCF",
        "CE52AF650D088CA559425223F4D32694",
    ),(
        "2b7e151628aed2a6abf7158809cf4f3c",
        "6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
        "3ad77bb40d7a3660a89ecaf32466ef97f5d3d58503b9699de785895a96fdbaaf43b1cd7f598ece23881b00e3ed0306887b0c785e27e8ad3f8223207104725dd4",
    )
]
    @test encrypt("aes128", hex2bytes(key), hex2bytes(text)) == hex2bytes(encrypted)
    @test decrypt("aes128", hex2bytes(key), hex2bytes(encrypted)) == hex2bytes(text)
end

# AES192
for (key,text,encrypted) in [
    (
        "00010203050607080A0B0C0D0F10111214151617191A1B1C",
        "2D33EEF2C0430A8A9EBF45E809C40BB6",
        "DFF4945E0336DF4C1C56BC700EFF837F",
    ),(
        "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b",
        "6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
        "bd334f1d6e45f25ff712a214571fa5cc974104846d0ad3ad7734ecb3ecee4eefef7afd2270e2e60adce0ba2face6444e9a4b41ba738d6c72fb16691603c18e0e",
    )
]
    @test encrypt("aes192", hex2bytes(key), hex2bytes(text)) == hex2bytes(encrypted)
    @test decrypt("aes192", hex2bytes(key), hex2bytes(encrypted)) == hex2bytes(text)
end

# AES256
for (key,text,encrypted) in [
    (
        "00010203050607080A0B0C0D0F10111214151617191A1B1C1E1F202123242526",
        "834EADFCCAC7E1B30664B1ABA44815AB",
        "1946DABF6A03A2A2C3D0B05080AED6FC",
    ),(
        "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4",
        "6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
        "f3eed1bdb5d2a03c064b5a7e3db181f8591ccb10d410ed26dc5ba74a31362870b6ed21b99ca6f4f9f153e7b1beafed1d23304b7a39f9f3ff067d8d8f9e24ecc7",
    )
]
    @test encrypt("aes256", hex2bytes(key), hex2bytes(text)) == hex2bytes(encrypted)
    @test decrypt("aes256", hex2bytes(key), hex2bytes(encrypted)) == hex2bytes(text)
end

# Test lower-level API
key = "this key's exactly 32 bytes long"
enc = Encryptor("AES256", key)
plaintext = "this is 16 chars"
ciphertext = encrypt(enc, Vector{UInt8}(plaintext))

dec = Decryptor("AES256", key)
deciphertext = decrypt(dec, ciphertext)
@test Vector{UInt8}(plaintext) == deciphertext # no bytestring

willcauseassertion = "this is 16 (∀).." # case of length(::String) == 16
@test length(willcauseassertion) == 16
@test sizeof(willcauseassertion) == 18
# @test_throws AssertionError Vector{UInt8}(willcauseassertion) == decrypt(dec, encrypt(enc, Vector{UInt8}(willcauseassertion))) # can not catch this c assertion
@test_throws ArgumentError Vector{UInt8}(willcauseassertion) == decrypt(dec, encrypt(enc, Vector{UInt8}(willcauseassertion)))
# @test_throws AssertionError Vector{UInt8}(willcauseassertion) == decrypt(dec, encrypt(enc, Vector{UInt8}(willcauseassertion))) # can not catch this c assertion
@test_throws ArgumentError Vector{UInt8}(willcauseassertion) == decrypt(dec, encrypt(enc, Vector{UInt8}(willcauseassertion)))

willbebroken = "this is 16 (∀)" # case of length(::String) != 16
@test length(willbebroken) == 14
@test sizeof(willbebroken) == 16
@test Vector{UInt8}(willbebroken) == decrypt(dec, encrypt(enc, Vector{UInt8}(willbebroken)))
@test willbebroken == String(decrypt(dec, encrypt(enc, Vector{UInt8}(willbebroken))))
@test Vector{UInt8}(willbebroken) == decrypt(dec, encrypt(enc, Vector{UInt8}(willbebroken)))
@test willbebroken == String(decrypt(dec, encrypt(enc, Vector{UInt8}(willbebroken))))

criticalbytes = hex2bytes("6e6f74555446382855aa552de2888029")
@test length(criticalbytes) == 16
@test sizeof(criticalbytes) == 16
@test criticalbytes == decrypt(dec, encrypt(enc, criticalbytes))

# This one will pass, but may be caught UnicodeError exception when evaluate it by julia ide.
dummy = String(decrypt(dec, encrypt(enc, criticalbytes)))
@test isa(dummy, AbstractString)
if !isdefined(Core, :String) || !isdefined(Core, :AbstractString)
    @test !isa(dummy, ASCIIString)
end
@test isa(dummy, String) # gray zone
@test sizeof(dummy) == 16
@test length(Vector{UInt8}(dummy)) == 16
@test length(dummy) != 16


# Test errors
@test_throws ArgumentError Encryptor("this is not a cipher", key)
@test_throws ArgumentError Decryptor("this is not a cipher either", key)

@test_throws ArgumentError Encryptor("AES256", "bad key length")
@test_throws ArgumentError Decryptor("AES256", "bad key length")

enc = Encryptor("AES256", key)
dec = Decryptor("AES256", key)
result = Vector{UInt8}(undef, sizeof(plaintext) - 1)
@test_throws ArgumentError encrypt!(enc, result, plaintext)
@test_throws ArgumentError decrypt!(dec, result, plaintext)

# Test show methods
println("Testing cipher show methods:")
println(get_cipher_types()["AES256"])
println(Encryptor("AES256", key))
println(Decryptor("AES256", key))

println("Testing cipher AES256CBC:")
# AES256CBC
for (pw,salt,iv,key,text,encrypted) in [
    (
        Vector(b"Secret Passphrase"),
        "a3e550e89e70996c",
        "7c7ed9434ddb9c2d1e1fcc38b4bf4667",
        "e299ff9d8e4831f07e5323913c53e5f0fec3a040a211d6562fa47607244d0051",
        "4d657373616765",
        "da8aab1b904205a7e49c1ecc7118a8f4",
    ),(
        Vector(b"Secret Passphrase"),
        "a3e550e89e70996c",
        "7c7ed9434ddb9c2d1e1fcc38b4bf4667",
        "e299ff9d8e4831f07e5323913c53e5f0fec3a040a211d6562fa47607244d0051",
        "4d657373616765090909090909090909",
        "da8aab1b904205a7e49c1ecc7118a8f4804bef7be79216196739de7845da182d",
    )
]
    (key32, iv16) = (hex2bytes(key), hex2bytes(iv))
    @test gen_key32_iv16(pw, hex2bytes(salt)) == (key32, iv16)
    @test encrypt("aes256", :CBC, iv16, key32, add_padding_PKCS5(hex2bytes(text), 16)) == hex2bytes(encrypted)
    @test trim_padding_PKCS5(decrypt("aes256", :CBC, iv16, key32, hex2bytes(encrypted))) == hex2bytes(text)
end

# Test errors
badkey = "this key's exactly 32(∪∩∀ДЯ)...."
@test length(badkey) == 32
@test sizeof(badkey) == 40
@test_throws ArgumentError Encryptor("AES256", badkey)
@test_throws ArgumentError Decryptor("AES256", badkey)

iv = Vector(b"this is 16 chars")
key = Vector(b"this key's exactly 32 bytes long")
enc = Encryptor("AES256", key)
dec = Decryptor("AES256", key)
shortresult = Vector{UInt8}(undef, sizeof(plaintext) - 1)
@test_throws ArgumentError encrypt!(enc, :CBC, iv, shortresult, plaintext)
@test_throws ArgumentError decrypt!(dec, :CBC, iv, shortresult, plaintext)
result = Vector{UInt8}(undef, sizeof(plaintext))
shorttext = Vector{UInt8}(undef, sizeof(plaintext) - 1)
@test_throws ArgumentError encrypt!(enc, :CBC, iv, result, shorttext)
@test_throws ArgumentError decrypt!(dec, :CBC, iv, result, shorttext)
longresult = Vector{UInt8}(undef, sizeof(plaintext) + 1)
longtext = Vector{UInt8}(undef, sizeof(plaintext) + 1)
@test_throws ArgumentError encrypt!(enc, :CBC, iv, longresult, longtext)
@test_throws ArgumentError decrypt!(dec, :CBC, iv, longresult, longtext)
shortiv = Vector{UInt8}(undef, sizeof(iv) - 1)
@test_throws ArgumentError encrypt!(enc, :CBC, shortiv, result, plaintext)
@test_throws ArgumentError decrypt!(dec, :CBC, shortiv, result, plaintext)
longiv = Vector{UInt8}(undef, sizeof(iv) + 1)
@test_throws ArgumentError encrypt!(enc, :CBC, longiv, result, plaintext)
@test_throws ArgumentError decrypt!(dec, :CBC, longiv, result, plaintext)

# encrypt!(enc, :GCM, iv, result, plaintext)
# decrypt!(dec, :CCM, iv, result, plaintext)
@test_throws ArgumentError encrypt!(enc, :UNKNOWN, iv, result, plaintext)
@test_throws ArgumentError decrypt!(dec, :UNKNOWN, iv, result, plaintext)

println("Cipher AES256CBC OK.")
