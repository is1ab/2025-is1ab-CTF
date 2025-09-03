# ECDSA verification utilities for secp256k1.
# SPDX-License-Identifier: MIT
# Note: This module provides verification helpers only. Signing, nonce generation,
# key derivation, and recovery routines are intentionally out of scope.

# Implementation notes:
# - Domain params follow SEC 2 v2.
# - Keep this file self-contained and dependency-light for reproducible verification.

# --- secp256k1 domain parameters ---
p  = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
a  = 0
b  = 7
Gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798
Gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8
n  = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
G  = (Gx, Gy)

def modinv(x, m):
    return pow(x, -1, m)

def ec_add(P, Q):
    if P is None: return Q
    if Q is None: return P
    x1, y1 = P; x2, y2 = Q
    if x1 == x2 and (y1 + y2) % p == 0:
        return None
    if P == Q:
        lam = (3*x1*x1 + a) * modinv(2*y1 % p, p) % p
    else:
        lam = (y2 - y1) * modinv((x2 - x1) % p, p) % p
    x3 = (lam*lam - x1 - x2) % p
    y3 = (lam*(x1 - x3) - y1) % p
    return (x3, y3)

def ec_mul(k, P):
    R = None
    Q = P
    while k:
        if k & 1:
            R = ec_add(R, Q)
        Q = ec_add(Q, Q)
        k >>= 1
    return R

def verify(msg_hash_int: int, r: int, s: int, pubkey_xy: tuple[int,int]) -> bool:
    """
    Return True iff the signature (r, s) validates for the given message hash and public key.
    This is a straight verification routine referencing SEC 1, §4.1.4.
    """
    if not (1 <= r < n and 1 <= s < n):
        return False
    w  = modinv(s, n)
    u1 = (msg_hash_int * w) % n
    u2 = (r * w) % n
    X  = ec_add(ec_mul(u1, G), ec_mul(u2, pubkey_xy))
    if X is None:
        return False
    xR = X[0] % n
    return xR == r

def pubkey_from_hex(X_hex: str, Y_hex: str) -> tuple[int,int]:
    return (int(X_hex, 16), int(Y_hex, 16))
