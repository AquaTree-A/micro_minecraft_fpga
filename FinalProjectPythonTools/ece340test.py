from scipy.optimize import newton
import math

# 定义方程
def f(V_m):
    return (1 + V_m / 0.0259) * math.exp(V_m / 0.0259) - 5.21e11

# 使用 secant 方法求解方程，不提供导数

v = 0.615627631
i = 620e-3 - 1.19e-12 * (math.exp(v / 0.0259) - 1)
p = v * i

print(f(0.615627631))
print(i)
print(p)

print(p / (0.699 * 0.62))
print(v / i)
