module QuantumMechanics

using LinearAlgebra: SymTridiagonal, norm, normalize, diagind, β
using SparseArrays: AbstractSparseMatrix, SparseMatrixCSC

using ..LastHomework: DiscreteLaplacian, Boundary, InternalSquare, validate, setvalues!

import ..Lanczos: lanczos

export Hamiltonian, probability

struct Hamiltonian{T} <: AbstractSparseMatrix{T,Int64}
    parent::SparseMatrixCSC{T,Int64}
end
Hamiltonian(parent::AbstractMatrix{T}) where {T} =
    Hamiltonian{T}(SparseMatrixCSC{T}(parent))
function Hamiltonian(A::DiscreteLaplacian, π::AbstractVector, q::Number)
    H = float(A)
    H[diagind(H)] .+= q * π
    return Hamiltonian(H)
end

function lanczos(A::Hamiltonian, π―β=rand(size(A, 1)); maxiter=30)
    N = Int(sqrt(size(A, 1)))  # A is a NΒ² Γ NΒ² matrix
    BOUNDARY = Boundary((N, N), 0)
    SQUARE = InternalSquare((N, N), 0)
    n = 1  # Initial step
    setvalues!(π―β, BOUNDARY)
    setvalues!(π―β, SQUARE)
    π―β = normalize(π―β)
    V = Matrix{eltype(π―β)}(undef, length(π―β), maxiter)  # NΒ² Γ maxiter
    V[:, n] = π―β
    π°β²β = A * π―β
    setvalues!(π°β²β, BOUNDARY)
    setvalues!(π°β²β, SQUARE)
    Ξ±β = π°β²β β π―β   # π―ββΊ A π―β
    π°β = π°β²β - Ξ±β * π―β  # π°β, GramβSchmidt process
    # validate(π°β, BOUNDARY)
    # validate(π°β, SQUARE)
    π = Vector{eltype(float(Ξ±β))}(undef, maxiter)
    π = Vector{Float64}(undef, maxiter)
    π[n], π[n] = Ξ±β, 0
    for n in 2:maxiter
        π°βββ = π°β
        π[n] = norm(π°βββ)
        if iszero(π[n])
            error("")
        else
            π―β = π°βββ / π[n]
            # validate(π―β, BOUNDARY)
            # validate(π―β, SQUARE)
            V[:, n] = π―β
        end
        π°β²β = A * π―β
        setvalues!(π°β²β, BOUNDARY)
        setvalues!(π°β²β, SQUARE)
        π[n] = π°β²β β π―β  # π―ββΊ A π―β
        π°β = π°β²β - π[n] * π―β - π[n] * V[:, n - 1]
        # validate(π°β, BOUNDARY)
        # validate(π°β, SQUARE)
    end
    T = SymTridiagonal(π, π[2:end])
    return T, V
end

probability(π::AbstractVector) = abs2.(normalize(π))
function probability(Ο::AbstractMatrix, xrange=1:size(Ο, 1), yrange=1:size(Ο, 2))
    πβ² = normalize(Ο)
    return sum(abs2.(πβ²[yrange, xrange]))  # Note the x and y order!
end

Base.parent(S::Hamiltonian) = S.parent

Base.size(S::Hamiltonian) = size(parent(S))

Base.IndexStyle(::Type{Hamiltonian{T}}) where {T} = IndexLinear()

Base.getindex(S::Hamiltonian, i) = getindex(parent(S), i)

Base.setindex!(S::Hamiltonian, v, i) = setindex!(parent(S), v, i)

end
