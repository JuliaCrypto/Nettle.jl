## Defines all hashing functionality
## As usual, check out http://www.lysator.liu.se/~nisse/nettle/nettle.html#Hash-functions

import Base: show
export Hasher, update!, digest, digest!, hexdigest!, hexdigest

struct Hasher
    hash_type::HashType
    state::Vector{UInt8}
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
    state = Vector{UInt8}(undef, hash_type.context_size)
    ccall(hash_type.init, Cvoid, (Ptr{Cvoid},), state)
    return Hasher(hash_type, state)
end

# Update hash state with new data
function update!(state::Hasher, data)
    ccall(state.hash_type.update, Cvoid, (Ptr{Cvoid},Csize_t,Ptr{UInt8}), state.state, sizeof(data), pointer(data))
    return state
end

# Spit out a digest of the current hash state and reset it
function digest!(state::Hasher)
    digest = Vector{UInt8}(undef, state.hash_type.digest_size)
    ccall(state.hash_type.digest, Cvoid, (Ptr{Cvoid},UInt32,Ptr{UInt8}), state.state, sizeof(digest), pointer(digest))
    return digest
end

# Take a digest, and convert it to a printable hex representation
hexdigest!(state::Hasher) = bytes2hex(digest!(state))

# The one-shot functions that makes this whole thing so easy.
digest(hash_name::AbstractString, data) = digest!(update!(Hasher(hash_name), data))
digest(hash_name::AbstractString, io::IO) = digest(hash_name, readall(io))
hexdigest(hash_name::AbstractString, data) = hexdigest!(update!(Hasher(hash_name), data))
hexdigest(hash_name::AbstractString, io::IO) = hexdigest(hash_name, readall(io))

# Custom show overrides make this package have a little more pizzaz!
function show(io::IO, x::HashType)
    write(io, "$(x.name) Hash\n")
    write(io, "  Context size: $(x.context_size) bytes\n")
    write(io, "  Digest size: $(x.digest_size) bytes\n")
    write(io, "  Block size: $(x.block_size) bytes")
end
show(io::IO, x::Hasher) = write(io, "$(x.hash_type.name) Hash state")
