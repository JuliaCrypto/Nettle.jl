## Defines all hashing functionality
## As usual, check out http://www.lysator.liu.se/~nisse/nettle/nettle.html#Hash-functions

import Base: show
export Hasher, update!, digest!, hexdigest!, calc_hash

immutable Hasher
    hash_type::HashType
    state::Array{UInt8,1}
end

# Constructor for Hasher
function Hasher(name::AbstractString)
    hash_types = get_hash_types()
    name = uppercase(name)
    if !haskey(hash_types, name)
        throw(ArgumentError("Invalid hash type $name: call Nettle.get_hash_types() to see available list"))
    end

    # Construct Hasher object for this type and initialize using Nettle's init functions
    hash_type = hash_types[name]
    state = Array(UInt8, hash_type.context_size)
    ccall(hash_type.init, Void, (Ptr{Void},), state)
    return Hasher(hash_type, state)
end

# Update hash state with new data
function update!(state::Hasher, data)
    ccall(state.hash_type.update, Void, (Ptr{Void},Csize_t,Ptr{UInt8}), state.state, sizeof(data), pointer(data))
    return state
end

# Spit out a digest of the current hash state and reset it
function digest!(state::Hasher)
    digest = Array(UInt8, state.hash_type.digest_size)
    ccall(state.hash_type.digest, Void, (Ptr{Void},UInt32,Ptr{UInt8}), state.state, sizeof(digest), pointer(digest))
    return digest
end

# Take a digest, and convert it to a printable hex representation
hexdigest!(state::Hasher) = bytes2hex(digest!(state))

# The one-shot function that makes this whole thing so easy.
calc_hash(name::AbstractString, data) = digest!(update!(Hasher(name), data))

# Custom show overrides make this package have a little more pizzaz!
function show(io::IO, x::HashType)
    write(io, "$(x.name) Hash\n")
    write(io, "  Context size: $(x.context_size) bytes\n")
    write(io, "  Digest size: $(x.digest_size) bytes\n")
    write(io, "  Block size: $(x.block_size) bytes")
end
show(io::IO, x::Hasher) = write(io, "$(x.hash_type.name) Hash state")

