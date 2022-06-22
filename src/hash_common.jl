export get_hash_types

# This is a mirror of the nettle-meta.h:nettle_hash struct
struct NettleHash
    name::Ptr{UInt8}
    context_size::Cuint
    digest_size::Cuint
    block_size::Cuint
    init::Ptr{Cvoid}     # nettle_hash_init_func
    update::Ptr{Cvoid}   # nettle_hash_update_func
    digest::Ptr{Cvoid}   # nettle_hash_digest_func
end

# We convert from the above NettleHash to a HashType for two reasons:
#   First, we need a way to keep the actual pointer address around
#   Secondly, it's nice to convert the name from a pointer to an actual string
# This cuts down on the amount of work we have to do for some operations
# (especially HMAC operations) at the cost of a bit of memory.  I'll take it.
struct HashType
    name::String
    context_size::Cuint
    digest_size::Cuint
    block_size::Cuint
    init::Ptr{Cvoid}     # nettle_hash_init_func
    update::Ptr{Cvoid}   # nettle_hash_update_func
    digest::Ptr{Cvoid}   # nettle_hash_digest_func

    # This pointer member not actually in the original nettle struct
    ptr::Ptr{Cvoid}
end

# The function that maps from a NettleHash to a HashType
function HashType(nh::NettleHash, nhptr::Ptr{Cvoid})
    HashType( uppercase(unsafe_string(nh.name)),
                    nh.context_size, nh.digest_size, nh.block_size,
                    nh.init, nh.update, nh.digest, nhptr)
end

# The global dictionary of hash types we know how to construct
const _hash_types = Dict{String,HashType}()

# We're going to load in each NettleHash struct individually, deriving
# HashAlgorithm types off of the names we find, and storing the output
# and context size from the data members in the C structures
function get_hash_types()
    # If we have already gotten the hash types from libnettle, don't query again
    if isempty(_hash_types)
        hash_idx = 1
        # nettle_hashes is an array of pointers ended by a NULL pointer, continue reading hash types until we hit it
        while( true )
            nhptr = unsafe_load(cglobal(("_nettle_hashes",libnettle),Ptr{Ptr{Cvoid}}),hash_idx)
            if nhptr == C_NULL
                break
            end
            hash_idx += 1

            nh = unsafe_load(convert(Ptr{NettleHash}, nhptr))
            hash_type = HashType(nh, convert(Ptr{Cvoid},nhptr))
            _hash_types[hash_type.name] = hash_type
        end
    end
    return _hash_types
end
