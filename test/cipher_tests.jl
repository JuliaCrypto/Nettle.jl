# AES tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/aes-test.c

# AES 128
for (key,text,encrypted) in {
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
}
    @test aes128_encrypt(hex2bytes(key),hex2bytes(text)) == hex2bytes(encrypted)
    @test aes128_decrypt(hex2bytes(key),hex2bytes(encrypted)) == hex2bytes(text)
end

# AES192
for (key,text,encrypted) in {
    (
        "00010203050607080A0B0C0D0F10111214151617191A1B1C",
        "2D33EEF2C0430A8A9EBF45E809C40BB6",
        "DFF4945E0336DF4C1C56BC700EFF837F",
    ),(
        "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b",
        "6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
        "bd334f1d6e45f25ff712a214571fa5cc974104846d0ad3ad7734ecb3ecee4eefef7afd2270e2e60adce0ba2face6444e9a4b41ba738d6c72fb16691603c18e0e",
    )
}
    @test aes192_encrypt(hex2bytes(key),hex2bytes(text)) == hex2bytes(encrypted)
    @test aes192_decrypt(hex2bytes(key),hex2bytes(encrypted)) == hex2bytes(text)
end

# AES256
for (key,text,encrypted) in {
    (
        "00010203050607080A0B0C0D0F10111214151617191A1B1C1E1F202123242526",
        "834EADFCCAC7E1B30664B1ABA44815AB",
        "1946DABF6A03A2A2C3D0B05080AED6FC",
    ),(
        "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4",
        "6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e5130c81c46a35ce411e5fbc1191a0a52eff69f2445df4f9b17ad2b417be66c3710",
        "f3eed1bdb5d2a03c064b5a7e3db181f8591ccb10d410ed26dc5ba74a31362870b6ed21b99ca6f4f9f153e7b1beafed1d23304b7a39f9f3ff067d8d8f9e24ecc7",
    )
}
    @test aes256_encrypt(hex2bytes(key),hex2bytes(text)) == hex2bytes(encrypted)
    @test aes256_decrypt(hex2bytes(key),hex2bytes(encrypted)) == hex2bytes(text)
end
