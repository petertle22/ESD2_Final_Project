function [x, y, z] = volleyServe1(t)
    coeff = 0.68;
    if t <= 1.468
        x = 3 * t -2.75;
        y = (-4.9) * t ^ 2 + 6 * t + 1.75;
        z = -10*t + 12;
    else
        x = 3 * coeff * t + 1.654;
        y = (-4.9) * t ^ 2 + coeff * 7.72 * t + 0;
        z = 6 * coeff * t - 2.68;
   %end
end