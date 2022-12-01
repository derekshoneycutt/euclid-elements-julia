
""" I.1 Find the third point that constructs an equilateral triangle from 2 points"""
function equilateral_from(A::Point2f, B::Point2f)
    #basically, the idea is pull the vector and rotate it 60° to find the 3rd equaliteral point
    v = B-A
    r = norm(v)

    u_θ = vector_angle(A, B)

    θ = π/3 + u_θ
    x, y = [r*cos(θ), r*sin(θ)]+A
    Point2f0(x, y)
end;
