#!/usr/bin/env python3
# Makes Tiny Tailwind's short sounds as mono 22.05 kHz .wav files (E6.3). Run from the repo root: python3 tools/make_sfx.py
import numpy as np, wave, os
SR = 22050
rng = np.random.default_rng(7)
def env(n, a=0.005, d=1.0):
    t = np.arange(n) / SR
    e = np.minimum(1.0, t / a) * np.exp(-t * d)
    e[-int(SR * 0.01):] *= np.linspace(1, 0, int(SR * 0.01))
    return e
def sweep(f0, f1, secs, kind="sine", d=8.0):
    n = int(SR * secs); f = np.geomspace(f0, f1, n); ph = np.cumsum(f) * 2 * np.pi / SR
    w = np.sin(ph) if kind == "sine" else np.sign(np.sin(ph)) * 0.6 if kind == "square" else 2 * ((ph / (2 * np.pi)) % 1) - 1
    return w * env(n, d=d)
def noise(secs, d=14.0, lp=0.35):
    n = int(SR * secs); x = rng.uniform(-1, 1, n); y = np.zeros(n); acc = 0.0
    for i in range(n):
        acc += lp * (x[i] - acc); y[i] = acc
    return y * env(n, d=d) * 2.0
def mix(*parts):
    n = max(len(p) for p in parts); o = np.zeros(n)
    for p in parts: o[:len(p)] += p
    return o
def seq(*parts): return np.concatenate(parts)
def save(name, x, vol=0.8):
    x = x / max(1e-6, np.max(np.abs(x))) * vol
    with wave.open(os.path.join("audio", name + ".wav"), "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes((x * 32767).astype(np.int16).tobytes())
save("shoot", sweep(1250, 520, 0.07, "square", 30), 0.45)
save("hit", mix(sweep(420, 180, 0.07, "square", 26), noise(0.05, 40)), 0.6)
save("pop", mix(sweep(520, 90, 0.22, "sine", 12), noise(0.16, 16, 0.5)), 0.8)
save("hurt", mix(sweep(300, 70, 0.3, "saw", 9), noise(0.2, 12, 0.2)), 0.8)
save("crystal", seq(sweep(1400, 1500, 0.04, "sine", 20), sweep(1900, 2100, 0.07, "sine", 22)), 0.4)
save("find", seq(sweep(660, 660, 0.09, "sine", 6), sweep(880, 880, 0.09, "sine", 6), sweep(1320, 1320, 0.35, "sine", 5)), 0.7)
save("dash", mix(noise(0.2, 12, 0.6), sweep(300, 900, 0.16, "sine", 12) * 0.5), 0.6)
save("checkpoint", seq(sweep(523, 523, 0.1, "sine", 5), sweep(784, 784, 0.1, "sine", 5), sweep(1046, 1046, 0.4, "sine", 4)), 0.6)
save("levelup", seq(*[sweep(f, f, 0.08, "square", 6) for f in (523, 659, 784, 1046)], sweep(1318, 1318, 0.3, "square", 5)), 0.5)
save("gate", mix(sweep(140, 60, 0.4, "saw", 6), noise(0.3, 9, 0.15)), 0.7)
save("boss", mix(sweep(110, 55, 0.9, "saw", 3), noise(0.8, 4, 0.1)), 0.8)
save("click", sweep(900, 700, 0.04, "sine", 40), 0.4)
save("defeat", seq(sweep(440, 220, 0.25, "sine", 5), sweep(330, 110, 0.5, "sine", 4)), 0.7)
save("coin", seq(sweep(1760, 1760, 0.05, "square", 18), sweep(2350, 2350, 0.12, "square", 14)), 0.32)
save("buy", seq(mix(noise(0.06, 30, 0.7), sweep(1320, 1320, 0.06, "square", 20)), sweep(1760, 1760, 0.06, "square", 16), sweep(2640, 2640, 0.22, "sine", 8)), 0.55)
save("break", mix(noise(0.25, 14, 0.45), sweep(220, 70, 0.2, "saw", 14)), 0.75)
save("leaf", noise(0.16, 18, 0.6), 0.35)
save("hint", seq(sweep(1046, 1046, 0.12, "sine", 7), sweep(1568, 1568, 0.32, "sine", 5)), 0.3)   # find hint chime (v0.3.4)
print("sfx done")
