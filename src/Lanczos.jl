module Lanczos

using LinearAlgebra: SymTridiagonal, norm, normalize, eigen, β
using ProgressMeter: @showprogress

export lanczos, restart_lanczos, loop_lanczos

function lanczos(A::AbstractMatrix, π―β=rand(size(A, 1)); maxiter=30)
    n = 1  # Initial step
    π―β = normalize(π―β)
    V = Matrix{eltype(π―β)}(undef, length(π―β), maxiter)
    V[:, n] = π―β
    π°β²β = A * π―β
    Ξ±β = π°β²β β π―β   # π―ββ€ A π―β
    π°β = π°β²β - Ξ±β * π―β  # π°β, GramβSchmidt process
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
            V[:, n] = π―β
        end
        π°β²β = A * π―β
        π[n] = π°β²β β π―β  # π―ββ€ A π―β
        π°β = π°β²β - π[n] * π―β - π[n] * V[:, n - 1]
    end
    T = SymTridiagonal(π, π[2:end])
    return T, V
end

recover_eigvec(V, π°) = normalize(V * π°)

function restart_lanczos(T, V)
    vals, vecs = eigen(T)
    index = if all(vals .> 0)
        argmin(vals)  # Index of the smallest eigenvalue
    else
        argmax(abs.(vals))  # Index of the smallest eigenvalue
    end
    π° = vecs[:, index]  # Associated eigenvector
    return recover_eigvec(V, π°)
end

function loop_lanczos(A::AbstractMatrix, n, π―β=rand(size(A, 1)); maxiter=30)
    @showprogress for _ in 1:n
        T, V = lanczos(A, π―β; maxiter=maxiter)
        π―β = restart_lanczos(T, V)
    end
    return π―β
end

end
