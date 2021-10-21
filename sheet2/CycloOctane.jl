using HomotopyContinuation, LinearAlgebra, DynamicPolynomials

c² = 2
@var z[1:3, 1:6]
z_vec = vec(z)[1:17] # the 17 variables in a vector
Z = [zeros(3) z[:,1:5] [z[1,6]; z[2,6]; 0] [√c²; 0; 0]] # the eight points in a matrix

# define the functions for cyclooctane:
F1 = [(Z[:, i] - Z[:, i+1]) ⋅ (Z[:, i] - Z[:, i+1]) - c² for i in 1:7]
F2 = [(Z[:, i] - Z[:, i+2]) ⋅ (Z[:, i] - Z[:, i+2]) - 8c²/3 for i in 1:6]
F3 = (Z[:, 7] - Z[:, 1]) ⋅ (Z[:, 7] - Z[:, 1]) - 8c²/3
F4 = (Z[:, 8] - Z[:, 2]) ⋅ (Z[:, 8] - Z[:, 2]) - 8c²/3
f = System([F1; F2; F3; F4])

N = 17 # ambient dimension
L₀ = rand_subspace(N; codim = 2)
R_L₀ = solve(f; target_subspace = L₀,threading = true)


Ω_tiny = solve(
    f,
    solutions(R_L₀);
    start_subspace = L₀,
    target_subspaces = [rand_subspace(N; codim = 2, real = true) for _ in 1:10],
    transform_result = (R,p) -> real_solutions(R),
    flatten = true,
    threading = true
)

Ω_medium = solve(
    f,
    solutions(R_L₀);
    start_subspace = L₀,
    target_subspaces = [rand_subspace(N; codim = 2, real = true) for _ in 1:100],
    transform_result = (R,p) -> real_solutions(R),
    flatten = true,
    threading = true
)

Ω_large = solve(
    f,
    solutions(R_L₀);
    start_subspace = L₀,
    target_subspaces = [rand_subspace(N; codim = 2, real = true) for _ in 1:500],
    transform_result = (R,p) -> real_solutions(R),
    flatten = true,
    threading = true
)

M_tiny = reduce(hcat, Ω_tiny)
M_medium = reduce(hcat, Ω_medium)
M_large = reduce(hcat, Ω_large)

using DelimitedFiles
open("M_tiny.txt", "w") do io
    writedlm(io, M_tiny)
end
open("M_medium.txt", "w") do io
    writedlm(io, M_medium)
end
open("M_large.txt", "w") do io
    writedlm(io, M_large)
end
