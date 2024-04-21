local math_trig = {}
math_trig.math_sin = {}
math_trig.math_cos = {}

-- Precompute sin and cos values

for i = 0, 360 do
    math_trig.math_sin[i] = math.sin(math.rad(i))
    math_trig.math_cos[i] = math.cos(math.rad(i))
end

-- Helper funcitons

math_trig.sin = function(angle)
    return math_trig.math_sin[(angle % 360) // 1]
end

math_trig.cos = function(angle)
    return math_trig.math_cos[(angle % 360) // 1]
end

return math_trig