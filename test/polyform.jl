using SymbolicUtils: PolyForm, Term, symtype
using Test, SymbolicUtils

include("utils.jl")

@testset "div and polyform" begin
    @syms x y z
    @test repr(PolyForm(x-y)) == "x - y"
    @test repr(x/y*x/z) == "(x^2) / (y*z)"
    @test repr(simplify_fractions(((x-y+z)*(x+4z+1)) /
                                  (y*(2x - 3y + 3z) +
                                   x*(x + z)))) == repr(simplify_fractions((1 + x + 4z) / (x + 3.0y)))
    @test simplify_fractions(x/(x+3) + 3/(x+3)) == 1
    @test repr(simplify(simplify_fractions(cos(x)/sin(x) + sin(x)/cos(x)))) == "1 / (cos(x)*sin(x))"
end

@testset "expand" begin
    @syms a b c d
    @test expand(a * (b + -1 * c) + -1 * (b * a + -1 * c * a)) == 0
    @eqtest simplify(expand(sin((a+b)^2)^2)) == simplify(sin(a^2+2*(b*a)+b^2)^2)
    @test simplify(expand(sin((a+b)^2)^2 + cos((a+b)^2)^2)) == 1
    @syms x1::Real f(::Real)::Real

    # issue 193
    #@test isequal(expand(f(2.0 + x1)), f(2.0 + x1))
    @test symtype(expand(f(x1 + 2.0))) == Real

    # cleanup rules
    # I don't think we need this anymore?
   #@test expand(Term{Number}(identity, 0)) == 0
   #@test expand(Term{Number}(one, 0)) == 1
   #@test expand(Term{Number}(zero, 0)) == 0
   #@test expand(identity(a * b) - b * a) == 0
    @test expand(a * b - b * a) == 0
end

@testset "simplify_fractions with quick-cancel" begin
    @syms x y
    @test simplify_fractions(x/2x) == 1//2
    @test simplify_fractions(2x//x) == 2
    @eqtest simplify_fractions((x+y) * (x-y) / (x+y)) == (x-y)
    @eqtest simplify_fractions(x^3 * y / x) == y*x^2
    @eqtest simplify_fractions(2x^3 * y / x) == 2y*x^2
    @eqtest simplify_fractions(x / (3(x^3)*y)) == simplify_fractions(1/(3*(y*x^2)))
    @eqtest simplify_fractions(2x / (3(x^3)*y)) == simplify_fractions(2/(3*(y*x^2)))
    @eqtest simplify_fractions(x^2 / (3(x^3)*y)) == simplify_fractions(1/(3*(y*x)))
    @eqtest simplify_fractions((3(x^3)*y) / x^2) == simplify_fractions(3*(y*x))
    @eqtest simplify_fractions(x^2/x^4) == (1/x^2)
    @eqtest simplify_fractions(x^2/x^3) == 1/x
    @eqtest simplify_fractions(x^3/x^2) == x
    @eqtest simplify_fractions(x^2/x^2) == 1
    @eqtest simplify_fractions(3x^2/x^3) == 3/x
    @eqtest simplify_fractions(3*(x^2)*(y^3)/(3*(x^3)*(y^2))) == y/x
    @eqtest simplify_fractions(3*(x^x)/x*y) == 3*(x^x)/x*y
end