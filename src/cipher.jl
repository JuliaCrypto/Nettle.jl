## Defines all cipher functionality
## As usual, check out
#http://www.lysator.liu.se/~nisse/nettle/nettle.html#Cipher-functions

import Base: show
export CipherType, get_cipher_types, Encryptor, Decryptor, decrypt, decrypt!, encrypt, encrypt!

# This is a mirror of the nettle-meta.h:nettle_cipher struct
immutable NettleCipher
    name::Ptr{UInt8}
    context_size::Cuint
    block_size::Cuint
    key_size::Cuint
    set_encrypt_key::Ptr{Void}
    set_decrypt_key::Ptr{Void}
    encrypt::Ptr{Void}
    decrypt::Ptr{Void}
end

# For much the same reasons as in hash_common.jl, we define a separate, more "Julia friendly" type
immutable CipherType
    name::AbstractString
    context_size::Cuint
    block_size::Cuint
    key_size::Cuint
    set_encrypt_key::Ptr{Void}
    set_decrypt_key::Ptr{Void}
    encrypt::Ptr{Void}
    decrypt::Ptr{Void}
end

# These are the user-facing types that are used to actually {en,de}cipher stuff
immutable Encryptor
    cipher_type::CipherType
    state::Array{UInt8,1}
end
immutable Decryptor
    cipher_type::CipherType
    state::Array{UInt8,1}
end

# The function that maps from a NettleCipher to a CipherType
function CipherType(nc::NettleCipher)
    CipherType( uppercase(bytestring(nc.name)),
                nc.context_size, nc.block_size, nc.key_size,
                nc.set_encrypt_key, nc.set_decrypt_key, nc.encrypt, nc.decrypt)
end

# The global dictionary of hash types we know how to construct
const _cipher_types = Dict{AbstractString,CipherType}()

# We're going to load in each NettleCipher struct individually, deriving
# HashAlgorithm types off of the names we find, and storing the output
# and context size from the data members in the C structures
function get_cipher_types()
    # If we have already gotten the hash types from libnettle, don't query again
    if isempty(_cipher_types)
        cipher_idx = 1
        # nettle_ciphers is an array of pointers ended by a NULL pointer, continue reading hash types until we hit it
        while( true )
            ncptr = unsafe_load(cglobal(("nettle_ciphers",nettle),Ptr{Ptr{Void}}),cipher_idx)
            if ncptr == C_NULL
                break
            end
            cipher_idx += 1
            nc = unsafe_load(convert(Ptr{NettleCipher}, ncptr))
            cipher_type = CipherType(nc)
            _cipher_types[cipher_type.name] = cipher_type
        end
    end
    return _cipher_types
end


function Encryptor(name::AbstractString, key)
    cipher_types = get_cipher_types()
    name = uppercase(name)
    if !haskey(cipher_types, name)
        throw(ArgumentError("Invalid cipher type $name: call Nettle.get_cipher_types() to see available list"))
    end
    cipher_type = cipher_types[name]

    if length(key) != cipher_type.key_size
        throw(ArgumentError("Key must be $(cipher_type.key_size) bytes long"))
    end

    state = Array(UInt8, cipher_type.context_size)
    if nettle_major_version >= 3
        ccall( cipher_type.set_encrypt_key, Void, (Ptr{Void}, Ptr{UInt8}), state, pointer(key))
    else
        ccall( cipher_type.set_encrypt_key, Void, (Ptr{Void}, Cuint, Ptr{UInt8}), state, length(key), pointer(key))
    end

    return Encryptor(cipher_type, state)
end

function Decryptor(name::AbstractString, key)
    cipher_types = get_cipher_types()
    name = uppercase(name)
    if !haskey(cipher_types, name)
        throw(ArgumentError("Invalid cipher type $name: call Nettle.get_cipher_types() to see available list"))
    end
    cipher_type = cipher_types[name]

    if length(key) != cipher_type.key_size
        throw(ArgumentError("Key must be $(cipher_type.key_size) bytes long"))
    end

    state = Array(UInt8, cipher_type.context_size)
    if nettle_major_version >= 3
        ccall( cipher_type.set_decrypt_key, Void, (Ptr{Void}, Ptr{UInt8}), state, pointer(key))
    else
        ccall( cipher_type.set_decrypt_key, Void, (Ptr{Void}, Cuint, Ptr{UInt8}), state, length(key), pointer(key))
    end

    return Decryptor(cipher_type, state)
end

function decrypt!(state::Decryptor, result, data)
    if length(result) < length(data)
        throw(ArgumentError("Output array of length $(length(result)) insufficient for input data length ($(length(data)))"))
    end
    ccall(state.cipher_type.decrypt, Void, (Ptr{Void},Csize_t,Ptr{UInt8},Ptr{UInt8}),
        state.state, sizeof(data), pointer(result), pointer(data))
    return result
end

function decrypt(state::Decryptor, data)
    result = Array(UInt8, length(data))
    decrypt!(state, result, data)
    return result
end


function encrypt!(state::Encryptor, result, data)
    if length(result) < length(data)
        throw(ArgumentError("Output array of length $(length(result)) insufficient for input data length ($(length(data)))"))
    end
    ccall(state.cipher_type.encrypt, Void, (Ptr{Void},Csize_t,Ptr{UInt8},Ptr{UInt8}),
        state.state, sizeof(data), pointer(result), pointer(data))
    return result
end

function encrypt(state::Encryptor, data)
    result = Array(UInt8, length(data))
    encrypt!(state, result, data)
    return result
end

# The one-shot functions that make this whole thing so easy
decrypt(name::AbstractString, key, data) = decrypt(Decryptor(name, key), data)
encrypt(name::AbstractString, key, data) = encrypt(Encryptor(name, key), data)

# Custom show overrides make this package have a little more pizzaz!
function show(io::IO, x::CipherType)
    write(io, "$(x.name) Cipher\n")
    write(io, "  Context size: $(x.context_size) bytes\n")
    write(io, "  Block size: $(x.block_size) bytes\n")
    write(io, "  Key size: $(x.key_size) bytes")
end
show(io::IO, x::Encryptor) = write(io, "$(x.cipher_type.name) Encryption state")
show(io::IO, x::Decryptor) = write(io, "$(x.cipher_type.name) Decryption state")
