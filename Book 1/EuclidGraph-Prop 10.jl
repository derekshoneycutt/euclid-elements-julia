
""" Represents drawing a bisection of a finite line for Euclid """
struct EuclidBisectLine
    ABC::EuclidEquilTri
    CD::EuclidBisectAngle
end

""" Get the end points and middle point of the bisecting line described """
function Points(bisect::EuclidBisectLine)
    C = Point(bisect.ABC)
    F = Point(bisect.CD)
    bisection = (C .+ F) ./ 2
    [C, F, bisection]
end

""" Calculate the bisection of a given finite line, given by endpoints A and B """
function bisect_line(A::Point2f0, B::Point2f0;
                        cursorcolor=:red, color=:black, linewidth::Float32=1f0, cursorlw::Float32=0.025f0)
    # Let AB be the given finite straight line
    #Thus it is required to bisect the finite straight line AB.
    #Let the equilateral triangle ABC be constructed on it [I.1],
    ABC = equilateral_triangle(A, B, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorlw=cursorlw)
    C = Point(ABC)

    #and let the angle ACB be bisected by the straight line CD [I.9];
    CD = bisect_angle(C, B, A, cursorcolor=cursorcolor, color=color, linewidth=linewidth, cursorlw=cursorlw)

    #I say that the straight line AB has been bisected at the point D.

    #For, since AC is equal to CB, and CD is common,
    #  the two sides AC, CD are equal to the two sides BC, CD respectively;
    #and the angle ACD is equal to the angle BCD;
    #    therefore the base AD is equal to the base BD [I.4]

    #Therefore the given finite straight line has been bisected at D.

    #QEF
    EuclidBisectLine(ABC, CD)
end

""" Fill out the total drawing of a bisect line operation """
function fill_bisect_line(bisect::EuclidBisectLine)
    fill_equilateral(bisect.ABC)
    fill_bisect_angle(bisect.CD)
end

""" Reset drawing of a bisect line operation """
function reset_bisect_line(bisect::EuclidBisectLine)
    reset_equilateral(bisect.ABC)
    reset_bisect_angle(bisect.CD)
end

""" Animate a previously calculation of a bisected line """
function animate_bisect_line(bisect::EuclidBisectLine, hide_until::AbstractFloat, max_at::AbstractFloat, t::AbstractFloat;
                                    fade_start::AbstractFloat=0f0, fade_end::AbstractFloat=0f0)
    d(n, ofn=2) = hide_until + (n-1)*(max_at - hide_until)/ofn
    df(n, ofn=2) = fade_start + (n-1)*(fade_end - fade_start)/ofn
    #animate ABC
    animate_equilateral(bisect.ABC, d(1), d(2), t, fade_start=df(1), fade_end=df(2))

    #Animate CD
    animate_bisect_angle(bisect.CD, d(2), max_at, t, fade_start=df(2), fade_end=fade_end)
end
