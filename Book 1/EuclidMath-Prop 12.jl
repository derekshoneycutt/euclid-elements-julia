
""" I.12 Get a point that forms a perpendicular from a line AB to another point C """
function get_perpendicular_to_point(A::Point2f, B::Point2f, C::Point2f)
    # get the equation of the line
    m = (B[2]-A[2])/(B[1]-A[1])
    b = B[2]-m*B[1]

    # now, get the equation of a perpendicular line, based on C
    H_m = -1 / m # slope of the perpendicular
    H_b = C[2] - H_m*C[1] #intercept of the perpendicular

    # Now, calculate where they intercept and return H
    H_x = (b - H_b)/(H_m - m)
    H = Point2f0(H_x, H_x*H_m + H_b)
end;
