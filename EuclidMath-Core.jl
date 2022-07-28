using GeometryBasics;
using LinearAlgebra;

# Fix an angle so that it is always 0 <= ∠ <= 2π
fix_angle(∠) = begin
    ∠ret = ∠
    while ∠ret > 2π
        ∠ret = ∠ret - 2π
    end
    while ∠ret < 0
        ∠ret = ∠ret + 2π
    end
    ∠ret
end

# Find a point that draw along a line indicated by vector B-A
function get_line(A::Point2f, B::Point2f, move_out=5)
    v = B - A
    norm_v = norm(v)
    u = v / norm_v
    x,y = A + (move_out > 0 ? move_out : norm_v) * u
    Point2f(x, y)
end;

# Find a point that will continue the given line
function continue_line(A::Point2f, B::Point2f, adjust_x=5)
    v = B - A
    u = v / norm(v)
    x,y = B + adjust_x * u
    Point2f(x, y)
end;


# Rotate a point about the origin
function rotate(P::Point2f, θ::Float32)
    x,y = [cos(θ) -sin(θ); sin(θ) cos(θ)]*P
    Point2f(x,y)
end;

# Rotate a point about some other center
function rotate_about(P::Point2f, C::Point2f, θ::Float32)
    v = C-P
    v_norm = norm(v)
    u = v/v_norm
    x,y = [cos(θ) -sin(θ); sin(θ) cos(θ)]*u*v_norm + C
    Point2f(x,y)
end;
