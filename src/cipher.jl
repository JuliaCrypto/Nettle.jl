## Defines all cipher functionality
## As usual, check out
#http://www.lysator.liu.se/~nisse/nettle/nettle.html#Cipher-functions

import Base: show
export CipherType, get_cipher_types
export gen_key32_iv16, add_padding_PKCS5, trim_padding_PKCS5
export Encryptor, Decryptor, decrypt, decrypt!, encrypt, encrypt!

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
    state::Vector{UInt8}
end
immutable Decryptor
    cipher_type::CipherType
    state::Vector{UInt8}
end

# The function that maps from a NettleCipher to a CipherType
function CipherType(nc::NettleCipher)
    CipherType( uppercase(unsafe_string(nc.name)),
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
            ncptr = unsafe_load(cglobal(("nettle_ciphers",libnettle),Ptr{Ptr{Void}}),cipher_idx)
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

const _cipher_suites = [:CBC] # [:CBC, :GCM, :CCM]

function gen_key32_iv16(pw::Vector{UInt8}, salt::Vector{UInt8})
    s1 = digest("MD5", [pw; salt])
    s2 = digest("MD5", [s1; pw; salt])
    s3 = digest("MD5", [s2; pw; salt])
    return ([s1; s2], s3)
end

function add_padding_PKCS5(data::Vector{UInt8}, block_size::Int)
  padlen = block_size - (sizeof(data) % block_size)
  return [data; map(i -> UInt8(padlen), 1:padlen)]
end

function trim_padding_PKCS5(data::Vector{UInt8})
  padlen = data[sizeof(data)]
  return data[1:sizeof(data)-padlen]
end

function Encryptor(name::AbstractString, key)
    cipher_types = get_cipher_types()
    name = uppercase(name)
    if !haskey(cipher_types, name)
        throw(ArgumentError("Invalid cipher type $name: call Nettle.get_cipher_types() to see available list"))
    end
    cipher_type = cipher_types[name]

    if sizeof(key) != cipher_type.key_size
        throw(ArgumentError("Key must be $(cipher_type.key_size) bytes long"))
    end

    state = Vector{UInt8}(cipher_type.context_size)
    if nettle_major_version >= 3
        ccall( cipher_type.set_encrypt_key, Void, (Ptr{Void}, Ptr{UInt8}), state, pointer(key))
    else
        ccall( cipher_type.set_encrypt_key, Void, (Ptr{Void}, Cuint, Ptr{UInt8}), state, sizeof(key), pointer(key))
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

    if sizeof(key) != cipher_type.key_size
        throw(ArgumentError("Key must be $(cipher_type.key_size) bytes long"))
    end

    state = Vector{UInt8}(cipher_type.context_size)
    if nettle_major_version >= 3
        ccall( cipher_type.set_decrypt_key, Void, (Ptr{Void}, Ptr{UInt8}), state, pointer(key))
    else
        ccall( cipher_type.set_decrypt_key, Void, (Ptr{Void}, Cuint, Ptr{UInt8}), state, sizeof(key), pointer(key))
    end

    return Decryptor(cipher_type, state)
end

function decrypt!(state::Decryptor, e::Symbol, iv::Vector{UInt8}, result, data)
    if sizeof(result) < sizeof(data)
        throw(ArgumentError("Output array of length $(sizeof(result)) insufficient for input data length ($(sizeof(data)))"))
    end
    if sizeof(result) % state.cipher_type.block_size > 0
        throw(ArgumentError("Output array of length $(sizeof(result)) must be N times $(state.cipher_type.block_size) bytes long"))
    end
    if sizeof(data) % state.cipher_type.block_size > 0
        throw(ArgumentError("Input array of length $(sizeof(data)) must be N times $(state.cipher_type.block_size) bytes long"))
    end
    if sizeof(iv) != state.cipher_type.block_size
        throw(ArgumentError("Iv must be $(state.cipher_type.block_size) bytes long"))
    end
    @compat if ! (Symbol(uppercase(string(e))) in _cipher_suites)
        throw(ArgumentError("now supports $(_cipher_suites) only but ':$(e)'"))
    end
if VERSION >= v"0.4.0"
    hdl = Libdl.dlopen_e(libnettle)
    s = Symbol("nettle_", lowercase(string(e)), "_decrypt")
    c = Libdl.dlsym(hdl, s)
    if c == C_NULL
        throw(ArgumentError("not found function '$(s)' for ':$(e)'"))
    end
    # c points (:nettle_***_decrypt, nettle) may be loaded as another instance
    iiv = copy(iv)
    ccall(c, Void, (
        Ptr{Void}, Ptr{Void}, Csize_t, Ptr{UInt8},
        Csize_t, Ptr{UInt8}, Ptr{UInt8}),
        state.state, state.cipher_type.decrypt, sizeof(iiv), iiv,
        sizeof(data), pointer(result), pointer(data))
    Libdl.dlclose(hdl)
else
    iiv = copy(iv)
    ccall((:nettle_cbc_decrypt, libnettle), Void, (
        Ptr{Void}, Ptr{Void}, Csize_t, Ptr{UInt8},
        Csize_t, Ptr{UInt8}, Ptr{UInt8}),
        state.state, state.cipher_type.decrypt, sizeof(iiv), iiv,
        sizeof(data), pointer(result), pointer(data))
end
    return result
end

function decrypt!(state::Decryptor, result, data)
    if sizeof(result) < sizeof(data)
        throw(ArgumentError("Output array of length $(sizeof(result)) insufficient for input data length ($(sizeof(data)))"))
    end
    if sizeof(result) % state.cipher_type.block_size > 0
        throw(ArgumentError("Output array of length $(sizeof(result)) must be N times $(state.cipher_type.block_size) bytes long"))
    end
    if sizeof(data) % state.cipher_type.block_size > 0
        throw(ArgumentError("Input array of length $(sizeof(data)) must be N times $(state.cipher_type.block_size) bytes long"))
    end
    ccall(state.cipher_type.decrypt, Void, (Ptr{Void},Csize_t,Ptr{UInt8},Ptr{UInt8}),
        state.state, sizeof(data), pointer(result), pointer(data))
    return result
end

function decrypt(state::Decryptor, e::Symbol, iv::Vector{UInt8}, data)
    result = Vector{UInt8}(sizeof(data))
    decrypt!(state, e, iv, result, data)
    return result
end

function decrypt(state::Decryptor, data)
    result = Vector{UInt8}(sizeof(data))
    decrypt!(state, result, data)
    return result
end

function encrypt!(state::Encryptor, e::Symbol, iv::Vector{UInt8}, result, data)
    if sizeof(result) < sizeof(data)
        throw(ArgumentError("Output array of length $(sizeof(result)) insufficient for input data length ($(sizeof(data)))"))
    end
    if sizeof(result) % state.cipher_type.block_size > 0
        throw(ArgumentError("Output array of length $(sizeof(result)) must be N times $(state.cipher_type.block_size) bytes long"))
    end
    if sizeof(data) % state.cipher_type.block_size > 0
        throw(ArgumentError("Input array of length $(sizeof(data)) must be N times $(state.cipher_type.block_size) bytes long"))
    end
    if sizeof(iv) != state.cipher_type.block_size
        throw(ArgumentError("Iv must be $(state.cipher_type.block_size) bytes long"))
    end
    @compat if ! (Symbol(uppercase(string(e))) in _cipher_suites)
        throw(ArgumentError("now supports $(_cipher_suites) only but ':$(e)'"))
    end
if VERSION >= v"0.4.0"
    hdl = Libdl.dlopen_e(libnettle)
    s = Symbol("nettle_", lowercase(string(e)), "_encrypt")
    c = Libdl.dlsym(hdl, s)
    if c == C_NULL
        throw(ArgumentError("not found function '$(s)' for ':$(e)'"))
    end
    # c points (:nettle_***_encrypt, nettle) may be loaded as another instance
    iiv = copy(iv)
    ccall(c, Void, (
        Ptr{Void}, Ptr{Void}, Csize_t, Ptr{UInt8},
        Csize_t, Ptr{UInt8}, Ptr{UInt8}),
        state.state, state.cipher_type.encrypt, sizeof(iiv), iiv,
        sizeof(data), pointer(result), pointer(data))
    Libdl.dlclose(hdl)
else
    iiv = copy(iv)
    ccall((:nettle_cbc_encrypt, libnettle), Void, (
        Ptr{Void}, Ptr{Void}, Csize_t, Ptr{UInt8},
        Csize_t, Ptr{UInt8}, Ptr{UInt8}),
        state.state, state.cipher_type.encrypt, sizeof(iiv), iiv,
        sizeof(data), pointer(result), pointer(data))
end
    return result
end

function encrypt!(state::Encryptor, result, data)
    if sizeof(result) < sizeof(data)
        throw(ArgumentError("Output array of length $(sizeof(result)) insufficient for input data length ($(sizeof(data)))"))
    end
    if sizeof(result) % state.cipher_type.block_size > 0
        throw(ArgumentError("Output array of length $(sizeof(result)) must be N times $(state.cipher_type.block_size) bytes long"))
    end
    if sizeof(data) % state.cipher_type.block_size > 0
        throw(ArgumentError("Input array of length $(sizeof(data)) must be N times $(state.cipher_type.block_size) bytes long"))
    end
    ccall(state.cipher_type.encrypt, Void, (Ptr{Void},Csize_t,Ptr{UInt8},Ptr{UInt8}),
        state.state, sizeof(data), pointer(result), pointer(data))
    return result
end

function encrypt(state::Encryptor, e::Symbol, iv::Vector{UInt8}, data)
    result = Vector{UInt8}(sizeof(data))
    encrypt!(state, e, iv, result, data)
    return result
end

function encrypt(state::Encryptor, data)
    result = Vector{UInt8}(sizeof(data))
    encrypt!(state, result, data)
    return result
end

# The one-shot functions that make this whole thing so easy
decrypt(name::AbstractString, key, data) = decrypt(Decryptor(name, key), data)
encrypt(name::AbstractString, key, data) = encrypt(Encryptor(name, key), data)

decrypt(name::AbstractString, e::Symbol, iv::Vector{UInt8}, key, data) = decrypt(Decryptor(name, key), e, iv, data)
encrypt(name::AbstractString, e::Symbol, iv::Vector{UInt8}, key, data) = encrypt(Encryptor(name, key), e, iv, data)

# Custom show overrides make this package have a little more pizzaz!
function show(io::IO, x::CipherType)
    write(io, "$(x.name) Cipher\n")
    write(io, "  Context size: $(x.context_size) bytes\n")
    write(io, "  Block size: $(x.block_size) bytes\n")
    write(io, "  Key size: $(x.key_size) bytes")
end
show(io::IO, x::Encryptor) = write(io, "$(x.cipher_type.name) Encryption state")
show(io::IO, x::Decryptor) = write(io, "$(x.cipher_type.name) Decryption state")
