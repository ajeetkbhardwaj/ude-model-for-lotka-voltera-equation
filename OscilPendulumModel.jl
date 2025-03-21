using DifferentialEquations
# Problem-1: Oscillatory pendulum model subject to torque
# dθ(t)/dt = ω(t)
# dω(t)/dt = -3g/2l sin(θ(t)) + 3/ml^2M(t)

function pendulum!(du, u, p, t)
    # independent variables
    theta, omega = u
    # contatns gravatational constant, lentgh of the pendulum and Mass of the knob
    g, l, m, mt = p

    du[1] = omega
    du[2] = -((3g) / (2l)) * sin(theta) + ((3 / m * l^2) * mt)
end

# Boundary coniditions
tspan = (0.0, 10.0)
l = 1.0
m = 1.0
g = 9.81
mt = 2.0

p = (g, l, m, mt)

# Initial conditions of independent variables

# Initial angular deflection (θ0): 0.01 rad
θ_0 = 0.001
# Initial angular velocity (ω0): 0.0 rad/s
ω_0 = 0.0
u_0 = [θ_0, ω_0]

# Ode problem 
problem = ODEProblem(pendulum!, u_0, tspan, p)

# solution
sol = solve(problem)