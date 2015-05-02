## Defines all cipher functionality
## As usual, check out
#http://www.lysator.liu.se/~nisse/nettle/nettle.html#Cipher-functions

import Base: show
export CipherEncrypt, CipherDecrypt, CipherAlgorithm, CipherAlgorithms
export key_size, block_size, decrypt, decrypt!, encrypt, encrypt!

# All Cipher Algorithms derive from this abstract type
abstract CipherAlgorithm

# This is our rather poorly named list of CipherAlgorithm types
CipherAlgorithms = DataType[]

# This is the user-facing type that is used to actually cipher stuff
type CipherEncrypt{T<:CipherAlgorithm}
    ctx::Array{Uint8,1}
end

type CipherDecrypt{T<:CipherAlgorithm}
    ctx::Array{Uint8,1}
end

# This is a mirror of the nettle-meta.h:nettle_cipher struct
immutable NettleCipher
    name::Ptr{Uint8}
    context_size::Cuint
    block_size::Cuint
    key_size::Cuint
    set_encrypt_key::Ptr{Void}
    set_decrypt_key::Ptr{Void}
    encrypt::Ptr{Void}
    decrypt::Ptr{Void}
end


# We're going to load in each nettle_cipher struct individually, deriving
# CipherAlgorithm types off of the names we find, and calculating the output
# and context size from the data members in the C structures
function cipher_init()
    cipher_idx = 1
    while( true )
    nhptr = unsafe_load(cglobal(("nettle_ciphers",nettle),Ptr{Ptr{Void}}),cipher_idx)
    if nhptr == C_NULL
        break
    end
    nh = unsafe_load(convert(Ptr{NettleCipher}, nhptr))

    # Otherwise, we continue on to derive the information from this struct
    name = symbol(uppercase(bytestring(nh.name)))

    # Load in the Ptr{Uint32}'s
    const_ctx_size = nh.context_size
    const_block_size = nh.block_size
    const_key_size = nh.key_size

    # Save the function pointers as well
    fptr_set_encrypt_key = nh.set_encrypt_key
    fptr_set_decrypt_key = nh.set_decrypt_key
    fptr_encrypt = nh.encrypt
    fptr_decrypt = nh.decrypt


    # First, create the type itself
    @eval immutable $name <: CipherAlgorithm; end

    # Next, record all the important information about this cipher algorithm
    @eval ctx_size(::Type{$name}) = $(convert(Int,const_ctx_size))
    @eval cipher_type(::Type{$name}) = $nhptr
    @eval block_size(::Type{$name}) = $(convert(Int,const_block_size))
    @eval key_size(::Type{$name}) = $(convert(Int,const_key_size))

    # Generate the constructors and encrypt/decrypt functions while we're at it!
    # Since we have the function pointers from nh, we'll use those
    @eval function CipherEncrypt(::Type{$name},key::Union(String,Vector{Uint8}))
        length(key) != key_size($name) && error("Key must be $(key_size($name)) bytes long")
        ctx = Array(Uint8, ctx_size($name))
        if nettle_major_version >= 3
            ccall($fptr_set_encrypt_key, Void, (Ptr{Void}, Ptr{Uint8}),
                  ctx, pointer(key))
        else
            ccall($fptr_set_encrypt_key, Void, (Ptr{Void}, Cuint, Ptr{Uint8}),
                  ctx, length(key), pointer(key))
        end
        CipherEncrypt{$name}(ctx)
    end

    @eval function CipherDecrypt(::Type{$name},key::Union(String,Vector{Uint8}))
        length(key) != key_size($name) && error("Key must be $(key_size($name)) bytes long")
        ctx = Array(Uint8, ctx_size($name))
        if nettle_major_version >= 3
            ccall($fptr_set_decrypt_key, Void, (Ptr{Void}, Ptr{Uint8}),
                  ctx, pointer(key))
        else
            ccall($fptr_set_decrypt_key, Void, (Ptr{Void}, Cuint, Ptr{Uint8}),
                  ctx, length(key), pointer(key))
        end
        CipherDecrypt{$name}(ctx)
    end

    @eval function decrypt(state::CipherDecrypt{$name},source)
        result = Array(Uint8,length(source))
        decrypt!(state,result,source)
        result
    end

    @eval function decrypt!(state::CipherDecrypt{$name},dst::Vector{Uint8},source::Vector{Uint8})
        n = length(source)
        @assert length(dst) == n
        ccall($fptr_decrypt,Void,(Ptr{Void},Csize_t,Ptr{Uint8},Ptr{Uint8}),state.ctx,sizeof(source),pointer(dst),pointer(source))
        dst
    end

    @eval function encrypt(state::CipherEncrypt{$name},source::Vector{Uint8})
        result = Array(Uint8,length(source))
        encrypt!(state,result,source)
        result
    end

    @eval function encrypt!(state::CipherEncrypt{$name},dst::Vector{Uint8},source::Vector{Uint8})
        n = length(source)
        @assert length(dst) == n
        ccall($fptr_encrypt,Void,(Ptr{Void},Csize_t,Ptr{Uint8},Ptr{Uint8}),state.ctx,sizeof(source),pointer(dst),pointer(source))
        dst
    end

    # Generate e.g. aes128_encrypt(key,string) and aes128_decrypt(key,string)
    name_encrypt = symbol("$(bytestring(nh.name))_encrypt")
    @eval $name_encrypt(key, string) = encrypt(CipherEncrypt($name, key), string)

    name_decrypt = symbol("$(bytestring(nh.name))_decrypt")
    @eval $name_decrypt(key, string) = decrypt(CipherDecrypt($name, key), string)

    # Add this type into the CipherAlgorithms group
    @eval push!(CipherAlgorithms, $name)

    # Finally, export the type we just created
    for sym in [name, name_encrypt, name_decrypt]
        eval(Expr(:export, sym))
    end

    cipher_idx += 1
    end
end

function show{T<:CipherAlgorithm}( io::IO, ::CipherEncrypt{T} )
  write(io, "$(string(T)) encryption cipher context")
end

function show{T<:CipherAlgorithm}( io::IO, ::CipherDecrypt{T} )
  write(io, "$(string(T)) decryption cipher context")
end
