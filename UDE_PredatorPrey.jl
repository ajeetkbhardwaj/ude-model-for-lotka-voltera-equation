### PART 1: LOADING PACKAGES IN JULIA

# SciML Tools: We will load packages for Differential Equations and Optimization Libraries
using OrdinaryDiffEq, ModelingToolkit, SciMLSensitivity, DataDrivenSparse
using Optimization, OptimizationOptimisers, OptimizationOptimJL

# Standard Libraries
using LinearAlgebra, Statistics

# External Libraries
using ComponentArrays, Lux, Zygote, Plots, StableRNGs
gr()

# Set a random seed for reproducible behaviour
rng = StableRNG(1111)


#### PART 2: GENERATING THE DATA 
function lotka!(du, u, p, t)
    α, β, γ, δ = p
    ##Rabbit
    du[1] = α * u[1] - β * u[2] * u[1]

    ##Fox
    du[2] = γ * u[1] * u[2] - δ * u[2]
end

# Define the experimental parameter
tspan = (0.0, 5.0)
u0 = 5.0f0 * rand(rng, 2)
p_ = [1.3, 0.9, 0.8, 1.8]
prob = ODEProblem(lotka!, u0, tspan, p_)
solution = solve(prob, Vern7(), abstol = 1e-12, reltol = 1e-12, saveat = 0.25)

# Add noise in terms of the mean
X = Array(solution)
t = solution.t

x̄ = mean(X, dims = 2)
noise_magnitude = 5e-3
Xₙ = X .+ (noise_magnitude * x̄) .* randn(rng, eltype(X), size(X))

plot(solution, alpha = 0.75, color = :red, label = ["True Data" nothing])
scatter!(t, transpose(Xₙ), color = :green, label = ["Noisy Data" nothing])

rbf(x) = exp.(-(x .^ 2))

#### PART 3: DEFINING THE NEURAL NETWORK WHICH WE WILL USE TO REPLACE THE INTERACTION TERM

## This is where we define the Neural Network!
# Multilayer FeedForward
const U = Lux.Chain(Lux.Dense(2, 5, rbf), Lux.Dense(5, 5, rbf), Lux.Dense(5, 5, rbf),
              Lux.Dense(5, 2))
# Get the initial parameters and state variables of the model
p, st = Lux.setup(rng, U)
const _st = st

#### PART 4: DEFINING THE UNIVERSAL DIFFERENTIAL EQUATION

# Define the hybrid model
function ude_dynamics!(du, u, p, t, p_true)
    û = U(u, p, _st)[1] # Network prediction
    du[1] = p_true[1] * u[1] + û[1]
    du[2] = -p_true[4] * u[2] + û[2]
end

# Closure with the known parameter
nn_dynamics!(du, u, p, t) = ude_dynamics!(du, u, p, t, p_)
# Define the problem
prob_nn = ODEProblem(nn_dynamics!, Xₙ[:, 1], tspan, p)

function predict(θ, X = Xₙ[:, 1], T = t)
    _prob = remake(prob_nn, u0 = X, tspan = (T[1], T[end]), p = θ)
    Array(solve(_prob, Vern7(), saveat = T,
                abstol = 1e-6, reltol = 1e-6,
                sensealg=QuadratureAdjoint(autojacvec=ReverseDiffVJP(true))))
end

function loss(θ)
    X̂ = predict(θ)
    mean(abs2, Xₙ .- X̂)
end

losses = Float64[]

callback = function (p, l)
    push!(losses, l)
    if length(losses) % 50 == 0
        println("Current loss after $(length(losses)) iterations: $(losses[end])")
    end
    return false
end

#### PART 5: DEFINING THE OPTIMIZATION PROCEDURE

adtype = Optimization.AutoZygote()
optf = Optimization.OptimizationFunction((x, p) -> loss(x), adtype)
optprob = Optimization.OptimizationProblem(optf, ComponentVector{Float64}(p))


#### PART 6: TRAINING THE NEURAL NETWORK

res1 = Optimization.solve(optprob, ADAM(), callback = callback, maxiters = 5000)
println("Training loss after $(length(losses)) iterations: $(losses[end])")

optprob2 = Optimization.OptimizationProblem(optf, res1.u)
res2 = Optimization.solve(optprob2, Optim.LBFGS(), callback = callback, maxiters = 1000)
println("Final training loss after $(length(losses)) iterations: $(losses[end])")

# Rename the best candidate
p_trained = res2.u


#### PART 7: VISUALIZATIONS

# Plot the losses
pl_losses = plot(1:5000, losses[1:5000], yaxis = :log10, xaxis = :log10,
                 xlabel = "Iterations", ylabel = "Loss", label = "ADAM", color = :blue)
plot!(5001:length(losses), losses[5001:end], yaxis = :log10, xaxis = :log10,
      xlabel = "Iterations", ylabel = "Loss", label = "BFGS", color = :red)


## Analysis of the trained network
# Plot the data and the approximation
ts = first(solution.t):(mean(diff(solution.t)) / 2):last(solution.t)
X̂ = predict(p_trained, Xₙ[:, 1], ts)
# Trained on noisy data vs real solution
pl_trajectory = plot(ts, transpose(X̂), xlabel = "t", ylabel = "x(t), y(t)", color = :red,
                     label = ["UDE Approximation" nothing])
scatter!(solution.t, transpose(Xₙ), color = :black, label = ["Measurements" nothing])

# Ideal unknown interactions of the predictor
Ȳ = [-p_[2] * (X̂[1, :] .* X̂[2, :])'; p_[3] * (X̂[1, :] .* X̂[2, :])']
# Neural network guess
Ŷ = U(X̂, p_trained, st)[1]

pl_reconstruction = plot(ts, transpose(Ŷ), xlabel = "t", ylabel = "U(x,y)", color = :red,
                         label = ["UDE Approximation" nothing])
plot!(ts, transpose(Ȳ), color = :black, label = ["True Interaction" nothing])


# Plot the error
pl_reconstruction_error = plot(ts, norm.(eachcol(Ȳ - Ŷ)), yaxis = :log, xlabel = "t",
                               ylabel = "L2-Error", label = nothing, color = :red)
pl_missing = plot(pl_reconstruction, pl_reconstruction_error, layout = (2, 1))

pl_overall = plot(pl_trajectory, pl_missing)