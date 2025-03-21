@__DIR__
# cd(@__DIR__)
using Pkg
Pkg.add("SingularIntegralEquations")
Pkg.add("DynamicalSystems")
Pkg.activate(".")

#using ForwardDiff, FiniteDiff
using JuliaPractice

f(x)  = 2x^2 + x 

g(x) = ForwardDiff.derivative(f, 2.0)
h(x) = FiniteDiff.finite_difference_derivative(f, 2.0)
g(9.3)
f(83.2)
h(92.3)
# to start creating julia packages we will use pkg templates

#using PkgTemplates

#t = Template(user = "ajeetkbhardwaj")
#t("JuliaPractice")
# it will create a package and 
# to use that package inside our dev enviroment

# base enviroment : activate @v1.10
# Julia Practice : activate "Julia Practice"
# remove a package : rm 