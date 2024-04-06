function [x, y, z] = volley1(t)
    coeff = 0.21;
    timeCollision = 2.764;
    if t <= timeCollision
        x = t - 2;
        y = (-4.9) * t ^ 2 + 13 * t + 1.55;
        z = -5*t + 6;
    else
        x = coeff * (1) * t + 0.764;
        y = -coeff * (-9.8 * timeCollision + 13) * t + 0.05;
        z = coeff * (-5) * t + -7.82;
    end
end 