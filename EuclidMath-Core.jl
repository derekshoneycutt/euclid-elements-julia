using GeometryBasics;
using LinearAlgebra;

""" Fix an angle so that it is always 0 <= ∠ <= 2π"""
fix_angle(∠) = begin
    ∠ret = ∠ % 2π
    while ∠ret < 0
        ∠ret = ∠ret + 2π
    end
    ∠ret
end

""" Find a point that draw along a line indicated by vector B-A"""
function get_line(A::Point2, B::Point2; move_out=0)
    v = B - A
    norm_v = norm(v)
    u = v / norm_v
    x,y = A + (move_out > 0 ? move_out : norm_v) * u
    Point2f0(x, y)
end;

""" Find a point that will continue the given line"""
function continue_line(A::Point2, B::Point2, adjust_x=5)
    v = B - A
    u = v / norm(v)
    x,y = B + adjust_x * u
    Point2f0(x, y)
end;


""" Rotate a point about the origin"""
function rotate(P::Point2, θ::AbstractFloat)
    x,y = [cos(θ) -sin(θ); sin(θ) cos(θ)]*P
    Point2f0(x,y)
end;

""" Rotate a point about some other center"""
function rotate_about(P::Point2, C::Point2, θ::AbstractFloat)
    v = C-P
    v_norm = norm(v)
    u = v/v_norm
    x,y = [cos(θ) -sin(θ); sin(θ) cos(θ)]*u*v_norm + C
    Point2f0(x,y)
end;
