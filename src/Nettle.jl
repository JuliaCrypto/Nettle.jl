module Nettle

using BinDeps
@BinDeps.load_dependencies [:nettle]

import Base: show
export SHA1, MD5, RMD160, SHA256, SHA384, SHA512, HMACState, update!, digest!, hexdigest!

abstract HashAlgorithm

immutable MD2 <: HashAlgorithm; end
immutable MD5 <: HashAlgorithm; end
immutable RIPEMD160 <: HashAlgorithm; end
immutable SHA1   <: HashAlgorithm; end
immutable SHA256 <: HashAlgorithm; end
immutable SHA384 <: HashAlgorithm; end
immutable SHA512 <: HashAlgorithm; end

# Output size of the algorithm in Bytes
output_size(::Type{MD2})    = 16
output_size(::Type{MD5})    = 16
output_size(::Type{RIPEMD160}) = 20
output_size(::Type{SHA1})   = 20
output_size(::Type{SHA256}) = 32
output_size(::Type{SHA384}) = 48
output_size(::Type{SHA512}) = 64

# ctx_size is found from nettle/sha*.h, look for structures such as sha256_ctx
ctx_size(::Type{MD2}) = 84
ctx_size(::Type{MD5}) = 92
ctx_size(::Type{RIPEMD160}) = 96
ctx_size(::Type{SHA1})   = 96
ctx_size(::Type{SHA256}) = 108
ctx_size(::Type{SHA384}) = 212
ctx_size(::Type{SHA512}) = 212

# HMAC
type HMACState{T<:HashAlgorithm}
  outer::Array{Uint8,1}
  inner::Array{Uint8,1}
  state::Array{Uint8,1}
end

function show{T<:HashAlgorithm}( io::IO, ::HMACState{T} )
  write(io, "$(string(T)) HMAC state")
end

# Precompile all our "hash_type" functions
for T in (MD5,MD2,RIPEMD160,SHA1,SHA256,SHA384,SHA512)
  @eval function hash_type(::Type{$T})
    cglobal(($(string("nettle_",lowercase(string(T)))),nettle))
  end
end

function HMACState{T<:HashAlgorithm}(::Type{T},key)
  outer = Array(Uint8,ctx_size(T))
  inner = Array(Uint8,ctx_size(T))
  state = Array(Uint8,ctx_size(T))

  ccall((:nettle_hmac_set_key,nettle),Void,(Ptr{Void},Ptr{Void},Ptr{Void},Ptr{Void},Csize_t,Ptr{Uint8}),outer,inner,state,hash_type(T),sizeof(key),key)
  HMACState{T}(outer,inner,state)
end

function update!{T<:HashAlgorithm}(state::HMACState{T},data)
  ccall((:nettle_hmac_update,nettle),Void,(Ptr{Void},Ptr{Void},Csize_t,Ptr{Uint8}),state.state,hash_type(T),sizeof(data),data)
end

function digest!{T<:HashAlgorithm}(state::HMACState{T})
  dgst = Array(Uint8,output_size(T))
  ccall((:nettle_hmac_digest,nettle),Void,(Ptr{Void},Ptr{Void},Ptr{Void},Ptr{Void},Csize_t,Ptr{Uint8}),state.outer,state.inner,state.state,hash_type(T),sizeof(dgst),dgst)
  dgst
end

# similar to Python's hmac.HMAC.hexdigest
function hexdigest!(state::HMACState)
  d = digest!(state)
  n = length(d)
  h = Array(Uint8, 2*n)
  for i = 1:n
    x = d[i]
    h[2*i] = Base.digit(x & 0xf)
    x >>= 4
    h[2*i-1] = Base.digit(x & 0xf)
  end
  ASCIIString(h)
end

end # module
