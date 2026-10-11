import numpy as np

rng = np.random.default_rng(0)

# ============================================================================
# 1. REAL-WORLD SCENARIO  (Merton consumption / savings problem)
# ----------------------------------------------------------------------------
# A 35-year-old consultant has $500k invested and plans to retire at 65 (30 yrs).
# Each year she chooses:
#   (a) how much of her wealth to CONSUME (spend on living / experiences), and
#   (b) what fraction of the remaining portfolio to hold in a risky equity index
#       vs. safe bonds.
# Objective (Merton): maximize EXPECTED DISCOUNTED CRRA UTILITY OF CONSUMPTION.
# Ruin (wealth -> ~0 before retirement) is absorbing: she cannot recover.
# ============================================================================
T      = 30        # years to retirement (finite horizon)
GAMMA  = 3.0       # CRRA risk aversion
BETA   = 0.96      # time preference (patience)
RF     = 0.01      # safe real return
W0     = 500.0     # starting wealth, $k
WMAX   = 3000.0
N      = 601
W      = np.linspace(1e-6, WMAX, N)
C_FRACS = np.linspace(0.0, 1.0, 51)   # consumption as fraction of wealth
ALPHAS  = np.linspace(0.0, 1.0, 21)   # risky share
RUIN_U  = -1e9

# risky asset regimes: list of (probability, return)
BASE    = [(0.50, 0.25), (0.50, -0.15)]   # mean 5%, vol ~20%
GOOD    = [(0.70, 0.30), (0.30, -0.05)]   # strong regime
BAD     = [(0.40, 0.10), (0.60, -0.20)]   # weak regime
# belief = 50/50 mixture of the two regimes (what you act on when you don't know)
BELIEF  = [(0.35, 0.30), (0.15, -0.05), (0.20, 0.10), (0.30, -0.20)]

def util(c):
    c = np.maximum(c, 1e-9)
    return c ** (1.0 - GAMMA) / (1.0 - GAMMA)   # CRRA; -> -inf as c -> 0

def interp(V, Wp):
    return np.interp(Wp, W, V, left=RUIN_U, right=V[-1])

def solve_dp(outcomes, horizon=T):
    """Backward induction = the Bellman recursion. Returns V, policy_c, policy_a."""
    V = util(W)                       # terminal: consume everything at retirement
    pol_c = np.zeros((horizon, N))
    pol_a = np.zeros((horizon, N))
    probs = np.array([p for p, _ in outcomes])
    rets  = np.array([r for _, r in outcomes])
    for t in range(horizon - 1, -1, -1):
        best = np.full(N, -np.inf)
        bc = np.zeros(N); ba = np.zeros(N)
        for cf in C_FRACS:
            c = cf * W
            uc = util(c)
            wleft = W - c
            for a in ALPHAS:
                rp = (1.0 - a) * RF + a * rets          # portfolio returns per outcome
                Wp = wleft[:, None] * (1.0 + rp)[None, :]
                Eu = (interp(V, Wp) * probs[None, :]).sum(axis=1)
                val = uc + BETA * Eu
                m = val > best
                best[m] = val[m]; bc[m] = cf; ba[m] = a
        V = best
        pol_c[t] = bc
        pol_a[t] = ba
    return V, pol_c, pol_a

def simulate(pol_c, pol_a, horizon=T, n=40000):
    """Monte-Carlo a policy on the BASE return process. Returns (ruin_prob, mean_utility)."""
    w = np.full(n, W0)
    acc = np.zeros(n)
    ruined = np.zeros(n, dtype=bool)
    for t in range(horizon):
        idx = np.clip(np.searchsorted(W, w), 0, N - 1)
        cf = pol_c[t][idx]; a = pol_a[t][idx]
        c = cf * w
        acc += (BETA ** t) * util(c)
        w = w - c
        up = rng.random(n) < BASE[0][0]
        r = np.where(up, BASE[0][1], BASE[1][1])
        w = np.maximum(w * (1.0 + (1.0 - a) * RF + a * r), 0.0)
        ruined |= w <= W[0]
    acc += (BETA ** T) * util(w)
    acc[ruined] = RUIN_U
    return ruined.mean(), acc.mean()

print("=" * 74)
print("MERTON CONSUMPTION PROBLEM — finite horizon DP (the Bellman recursion)")
print("=" * 74)
V, pc, pa = solve_dp(BASE)
i0 = int(np.argmin(np.abs(W - W0)))
print(f"\nOptimal policy at t=0, wealth ${W0:.0f}k:")
print(f"  consume {pc[0, i0]*100:5.1f}%  (${pc[0, i0]*W0:6.1f}k this year)")
print(f"  risky share {pa[0, i0]*100:5.0f}%")
print("\nPolicy as retirement approaches (at the SAME $500k):")
for t in (0, 10, 20, 29):
    print(f"  t={t:2d} ({35+t} yo): consume {pc[t, i0]*100:5.1f}%   risky {pa[t, i0]*100:5.0f}%")
print("\nValue function V(W) is concave and rises with wealth:")
for ww in (100, 500, 1000, 2000):
    j = int(np.argmin(np.abs(W - ww)))
    print(f"  V(${ww}k) = {V[j]:.3f}")

print("\n" + "=" * 74)
print("COMPARISON — optimal policy vs. naive 'all-in equities, spend 5%/yr'")
print("=" * 74)
opt_ruin, opt_U = simulate(pc, pa)
naive_c = np.full((T, N), 0.05)
naive_a = np.ones((T, N))
nv_ruin, nv_U = simulate(naive_c, naive_a)
print(f"  optimal : ruin {opt_ruin*100:5.1f}%   expected discounted utility {opt_U:8.3f}")
print(f"  all-in  : ruin {nv_ruin*100:5.1f}%   expected discounted utility {nv_U:8.3f}")
print("  -> all-in is worse: over-betting a good edge costs utility even without ruin.")

print("\n" + "=" * 74)
print("RUIN GATE — a bet that can go to ZERO (absorbing) + multiplicative sizing")
print("=" * 74)
print("  Each year you put fraction f into a venture: 10% chance of total loss of")
print("  that slice, else it returns +25%. The rest sits in cash (0%).")
def venture(f, n=100000, years=30):
    w = np.ones(n)
    for _ in range(years):
        loss = rng.random(n) < 0.10
        w = w * np.where(loss, 1.0 - f, 1.0 + f * 0.25)
    return (w <= 0.01).mean(), np.median(w)
for f in (1.0, 0.5, 0.3, 0.1):
    ruin, med = venture(f)
    print(f"    f={f:>4}: ruin {ruin*100:5.1f}%   median final wealth x{med:6.3f}")
print("  -> all-in (f=1) ends the game ~96% of the time (0.9^30 = 4% survival).")
print("  -> sizing as a FRACTION (f~0.3) compounds and survives. Never all-in.")

print("\n" + "=" * 74)
print("FIXED POINT — infinite-horizon value iteration (GPI settles)")
print("=" * 74)
Vinf = util(W)
tol = 1e-6
for it in range(1, 5001):
    best = np.full(N, -np.inf)
    for cf in C_FRACS:
        c = cf * W; uc = util(c); wleft = W - c
        for a in ALPHAS:
            rp = (1.0 - a) * RF + a * np.array([r for _, r in BASE])
            Wp = wleft[:, None] * (1.0 + rp)[None, :]
            Eu = (interp(Vinf, Wp) * np.array([p for p, _ in BASE])[None, :]).sum(axis=1)
            val = uc + BETA * Eu
            best = np.maximum(best, val)
    d = np.max(np.abs(best - Vinf)); Vinf = best
    if d < tol:
        break
print(f"  converged after {it} sweeps (max|dV| < {tol})  -> the fixed point")

print("\n" + "=" * 74)
print("POMDP — unknown regime: act on a BELIEF, update it (Bayes)")
print("=" * 74)
pg = 0.5
p_up_good, p_up_bad = 0.7, 0.4
p_up = pg * p_up_good + (1 - pg) * p_up_bad
post_up   = pg * p_up_good / p_up
post_down = pg * (1 - p_up_good) / (1 - p_up)
print(f"  prior P(good regime) = {pg:.3f}")
print(f"  observe an UP year   -> posterior P(good) = {post_up:.3f}")
print(f"  observe a DOWN year  -> posterior P(good) = {post_down:.3f}")
Vg, pcg, pag = solve_dp(GOOD)
Vb, pcb, pab = solve_dp(BAD)
Vl, pcl, pal = solve_dp(BELIEF)
print("\n  Optimal risky share at $500k under different knowledge:")
print(f"    know it's GOOD   : {pag[0, i0]*100:5.0f}%")
print(f"    act on BELIEF    : {pal[0, i0]*100:5.0f}%   <- hedged, between the two")
print(f"    know it's BAD    : {pab[0, i0]*100:5.0f}%")
print("  -> under uncertainty the policy is robust, not the boldest bet.")
print("  -> UNKNOWN UNKNOWNS: a third regime you never named would break all of these,")
print("     so you keep margin and treat surprises as model failure (outer loop).")
