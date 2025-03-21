@__DIR__
using Pkg 
Pkg.add("AutoGrad")

using DifferentialEquations

# function
f(u, p, t)  = 10.1 * u

# initialization
u0 = 0.1
tspan = (0.0, 1.0)

# definite the ode problem
prob = ODEProblem(f, u0, tspan)

# solving 
sol = solve(prob, QNDF())
sol = solve(prob, RadauIIA5())
sol = solve(prob,KenCarp4() )
sol = solve(prob,Rodas5() )
sol = solve(prob, Vern7(), reltol=1e-6)
sol = solve(prob, BS3())
sol[19]
sol = solve(prob, AutoVern7(Rodas5()) ,reltol= 1e-8)
sol = solve(prob, AutoTsit5(Rosenbrock23()) ,reltol = 1e-8, abstol = 1e-8)
sol = solve(prob, Tsit5(), reltol = 1e-8, abstol = 1e-8)
sol[19]
sol.t[9]
#println(sol)
using Plots
[t + 2u for (u, t) in zip(sol.u, sol.t)]
plot(sol)
plot(sol, title="Differential Equations solution", xaxis="time", yaxis= "u(t)", label = "solution line")
plot!(sol.t, t -> 0.5 * exp(1.01t), lw = 3, ls = :dash, label = "True Solution")
# visualize the result
using Plots
plot(sol, linewidth = 5, title = "Solution to the linear ode with a tick line",
xaxis = "Time (t)", yaxis = "u(t) (in μm)", label = "My Thick Line!") # legend=false
plot!(sol.t, t -> 0.5 * exp(1.01t), lw = 3, ls = :dash, label = "True Solution!")

# We can choose solvers according to our choice
# 1. AutoTsit5(Rosenblock23()) : it can handle both stiff and non stiff conditions


# Solving system of ordinary differetial Equations
# Ww will solve the loretze equaiton and visualize the attractors
# define the problems
function loretzprob(du, u, p, t)
    du[1] = 10.0 * (u[2] - u[1])
    du[2] = u[1] * (28.0 - u[3]) - u[2]
    du[3] = u[1] * u[2] - (8 / 3) * u[3]  
end

# define the initial conditions
u0 = [1.0; 0.0; 0.0]
tspan = (0.0, 100.0)
# define the ode problem
prob = ODEProblem(loretzprob, u0, tspan)

# solution of the problem 
sol = solve(prob)
using Plots
# plot the solution
plot(sol, idxs= (1, 2, 3), title="Lorentz equation solution", xaxis="x(t)", yaxis="y(t)", zaxis="z(t)")

# multidimensional systems in the form of timeseris
plot(sol, idxs=(0, 1))

# other types of non homogenous parameteized ode 
l= 1.0
m = 0.49
g = 9.8198324
function pendulum!(du, u, p, t)
    du[1] = u[2]
    du[2] = -3g /(2l) * sin(u[1]) + 3/ (m * l^2) * p(t)
end

M = t -> 0.1sin(t)
θ = 0.01
ω = 0.0
u = [θ, ω]
tspan = [0.0, 10.0]
prob = ODEProblem(pendulum!, u, tspan, M )
sol = solve(prob)

plot(sol, idxs = (0, 1), title = "pendulum oscillation", xaxis = "time", yaxis="u(t)")

using DifferentialEquations
using Plots
A = [1.0 0 0 -5
    4 -2 4 -3
    -4 0 0 1
    5 -2 2 3]
u0 = rand(4, 2)
tspan = (0.0, 1.0)
f(u, p, t) = A * u
prob = ODEProblem(f, u0, tspan)
sol = solve(prob)
plot(sol)