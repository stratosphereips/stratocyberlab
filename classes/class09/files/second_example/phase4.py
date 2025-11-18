def func4(a1: int, a2: int, a3: int):
    v3 = a2 + (a3-a2) // 2
    if v3 > a1:
        v3 += func4(a1, a2, v3-1)
    elif v3 < a1:
        v3 += func4(a1, v3 + 1, a3)

    return v3

for i in range(1, 15):
    res = func4(i, 0, 14)
    if res == 10:
        print(f"Yay! Correct input: {i}")
        break
