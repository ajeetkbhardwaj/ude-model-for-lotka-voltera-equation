# Delay Differential Equations : it have a delayed argument which is called history function h(p, t) uses interpolations throughout the solution
# history to form a continuous extension of the solver's past and depends on the parameter p and time t.

# Solving a model of breast cancer growth kinetics

using DifferentialEquations
function breast_cancer_model(du,u, h, p, t)
    p0, q0, v0, d0, p1, q1, v1, d1, d2, beta0, beta1, tau = p
    hist3 = h(p, t - tau)[3]
    du[1] = (v0 / (1 + beta0 * (hist3^2)) * (p0 -q0) * u[1] - d0 *u[1])
    du[2] = (v0 / (1 + beta0 * (hist3^2)) * (1 -p0 + q0) * u[1] + 
    (v0 / (1 + beta1 * (hist3^2))) * (p1 -q1)*u[2] - d1 * u[2])
    du[3] = (v0 / (1 + beta1 * (hist3^2)) * (1 - p1 + q1) * u[2] - d2 * u[3])  
end

# define the delayed problem
h(p, t) = ones(3)
tau = 1
lags = [tau]
p0 = 0.3;
q0 = 0.2;
v0 = 9;
d0 = 0.3;
p1 = 0.2;
q1 = 0.3;
v1 = 1;
d1 = 10;
d2 = 1;
beta0 = 1;x
beta1 = 1;
p = (p0, q0, v0, d0, p1, q1, v1, d1, d2, beta0, beta1, tau)
tspan = (0.0, 10.0)
u0 = [1.0, 1.0, 1.0]
prob = DDEProblem(breast_cancer_model, u0, h, tspan, p; constant_lags = lags)
alg = MethodOfSteps(Tsit5())
sol = solve(prob, alg)

using Plots
plot(sol)
plot(sol, denseplot=false)
plot(sol, plotdensity=1000)
animate(sol, lw=10, every=1)
# let's speed up a bit 
h(out, p, t) = (out .= 1.0)
const out = zeros(3)
function breast_cancer_model(du,u, h, p, t)
    # updates out to be correct history function
    h(out, p, t-tau)
    du[1] = (v0 / (1 + beta0 * (out[3]^2)) * (p0 -q0) * u[1] - d0 *u[1])
    du[2] = (v0 / (1 + beta0 * (out[3]^2)) * (1 -p0 + q0) * u[1] + 
    (v0 / (1 + beta1 * (hist3^2))) * (p1 -q1)*u[2] - d1 * u[2])
    du[3] = (v0 / (1 + beta1 * (out[3]^2)) * (1 - p1 + q1) * u[2] - d2 * u[3])  
end
