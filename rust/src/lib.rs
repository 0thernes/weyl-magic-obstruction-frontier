// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alexander Stephen Donahue

#![forbid(unsafe_code)]
#![deny(warnings)]

/// Exact Gaussian integer `re + im * i`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct GaussInt {
    pub re: i128,
    pub im: i128,
}

impl GaussInt {
    pub const ZERO: Self = Self { re: 0, im: 0 };

    pub const fn new(re: i128, im: i128) -> Self {
        Self { re, im }
    }

    pub const fn add(self, rhs: Self) -> Self {
        Self { re: self.re + rhs.re, im: self.im + rhs.im }
    }

    pub const fn conj(self) -> Self {
        Self { re: self.re, im: -self.im }
    }

    pub const fn mul(self, rhs: Self) -> Self {
        Self {
            re: self.re * rhs.re - self.im * rhs.im,
            im: self.re * rhs.im + self.im * rhs.re,
        }
    }

    pub const fn mul_pow_i(self, q: usize) -> Self {
        match q & 3 {
            0 => self,
            1 => Self { re: -self.im, im: self.re },
            2 => Self { re: -self.re, im: -self.im },
            _ => Self { re: self.im, im: -self.re },
        }
    }

    pub const fn norm_sq(self) -> i128 {
        self.re * self.re + self.im * self.im
    }
}

/// Exact 8th cyclotomic integer `c0 + c1*z + c2*z^2 + c3*z^3` (`z^4 = -1`).
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Zeta8 {
    pub c0: i128,
    pub c1: i128,
    pub c2: i128,
    pub c3: i128,
}

impl Zeta8 {
    pub const ZERO: Self = Self { c0: 0, c1: 0, c2: 0, c3: 0 };

    pub const fn new(c0: i128, c1: i128, c2: i128, c3: i128) -> Self {
        Self { c0, c1, c2, c3 }
    }

    pub const fn add(self, b: Self) -> Self {
        Self { c0: self.c0 + b.c0, c1: self.c1 + b.c1, c2: self.c2 + b.c2, c3: self.c3 + b.c3 }
    }

    pub const fn conj(self) -> Self {
        Self { c0: self.c0, c1: -self.c3, c2: -self.c2, c3: -self.c1 }
    }

    pub const fn mul(self, b: Self) -> Self {
        Self {
            c0: self.c0 * b.c0 - self.c1 * b.c3 - self.c2 * b.c2 - self.c3 * b.c1,
            c1: self.c0 * b.c1 + self.c1 * b.c0 - self.c2 * b.c3 - self.c3 * b.c2,
            c2: self.c0 * b.c2 + self.c1 * b.c1 + self.c2 * b.c0 - self.c3 * b.c3,
            c3: self.c0 * b.c3 + self.c1 * b.c2 + self.c2 * b.c1 + self.c3 * b.c0,
        }
    }

    pub const fn mul_pow_i(self, q: usize) -> Self {
        match q & 3 {
            0 => self,
            1 => Self { c0: -self.c2, c1: -self.c3, c2: self.c0, c3: self.c1 },
            2 => Self { c0: -self.c0, c1: -self.c1, c2: -self.c2, c3: -self.c3 },
            _ => Self { c0: self.c2, c1: self.c3, c2: -self.c0, c3: -self.c1 },
        }
    }

    pub const fn norm_sq_pair(self) -> (i128, i128) {
        let p = self.mul(self.conj());
        (p.c0, p.c1)
    }
}

/// Exact 9th cyclotomic integer `Z[z]/(z^6 + z^3 + 1)`.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub struct Zeta9(pub [i128; 6]);

impl Zeta9 {
    pub const ZERO: Self = Self([0; 6]);

    pub const fn pow(k: usize) -> Self {
        match k % 9 {
            0 => Self([1, 0, 0, 0, 0, 0]),
            1 => Self([0, 1, 0, 0, 0, 0]),
            2 => Self([0, 0, 1, 0, 0, 0]),
            3 => Self([0, 0, 0, 1, 0, 0]),
            4 => Self([0, 0, 0, 0, 1, 0]),
            5 => Self([0, 0, 0, 0, 0, 1]),
            6 => Self([-1, 0, 0, -1, 0, 0]),
            7 => Self([0, -1, 0, 0, -1, 0]),
            _ => Self([0, 0, -1, 0, 0, -1]),
        }
    }

    pub fn plus(self, b: Self) -> Self {
        let mut out = [0i128; 6];
        for (i, slot) in out.iter_mut().enumerate() {
            *slot = self.0[i] + b.0[i];
        }
        Self(out)
    }

    pub const fn conj(self) -> Self {
        let x = self.0;
        Self([x[0] - x[3], -x[2], -x[1], -x[3], x[5] - x[2], x[4] - x[1]])
    }

    pub fn times(self, b: Self) -> Self {
        let mut t = [0i128; 11];
        for i in 0..6 {
            for j in 0..6 {
                t[i + j] += self.0[i] * b.0[j];
            }
        }
        for k in (6..=10).rev() {
            let v = t[k];
            t[k - 3] -= v;
            t[k - 6] -= v;
        }
        Self([t[0], t[1], t[2], t[3], t[4], t[5]])
    }

    pub fn norm_sq(self) -> Self {
        self.times(self.conj())
    }
}

pub fn fwht(buf: &mut [i128]) {
    let n = buf.len();
    let mut half = 1usize;
    while half < n {
        let step = half << 1;
        let mut base = 0usize;
        while base < n {
            for k in 0..half {
                let x = buf[base + k];
                let y = buf[base + k + half];
                buf[base + k] = x + y;
                buf[base + k + half] = x - y;
            }
            base += step;
        }
        half <<= 1;
    }
}

#[derive(Debug, PartialEq, Eq)]
pub struct Bent4Audit {
    pub total_bent: usize,
    pub quad_bent: usize,
    pub deg_gt2_bent: usize,
    pub bent_with_zero_triple: usize,
}

pub fn audit_all_65536_f2_4() -> Bent4Audit {
    let mut res = Bent4Audit {
        total_bent: 0,
        quad_bent: 0,
        deg_gt2_bent: 0,
        bent_with_zero_triple: 0,
    };
    for tt in 0u32..65536 {
        let mut w = [0i128; 16];
        for (x, slot) in w.iter_mut().enumerate() {
            *slot = if ((tt >> x) & 1) == 1 { -1 } else { 1 };
        }
        fwht(&mut w);
        if !w.iter().all(|&v| v == 4 || v == -4) {
            continue;
        }
        res.total_bent += 1;
        let mut anf = [0u8; 16];
        for (x, slot) in anf.iter_mut().enumerate() {
            *slot = ((tt >> x) & 1) as u8;
        }
        for bit in 0..4 {
            let step = 1usize << bit;
            for x in 0..16 {
                if (x & step) != 0 {
                    anf[x] ^= anf[x ^ step];
                }
            }
        }
        let max_deg = (0..16usize)
            .filter(|&m| anf[m] != 0)
            .map(|m| m.count_ones() as usize)
            .max()
            .unwrap_or(0);
        if max_deg <= 2 {
            res.quad_bent += 1;
        } else {
            res.deg_gt2_bent += 1;
        }
        let mut ea = [0u16; 16];
        for (a, slot) in ea.iter_mut().enumerate().skip(1) {
            let mut mask = 0u16;
            for x in 0..16usize {
                if ((tt >> x) & 1) == ((tt >> (x ^ a)) & 1) {
                    mask |= 1u16 << x;
                }
            }
            *slot = mask;
        }
        let mut found = false;
        'outer: for a in 1..16usize {
            for b in (a + 1)..16usize {
                if (ea[a] ^ ea[b] ^ ea[a ^ b]) == 0 {
                    found = true;
                    break 'outer;
                }
            }
        }
        if found {
            res.bent_with_zero_triple += 1;
        }
    }
    res
}

pub fn verify_w42_z8_mub() -> ((i128, i128), (usize, usize, usize, usize)) {
    let psi = [
        Zeta8::new(0, -1, 0, 0), Zeta8::new(-1, 0, -1, 0), Zeta8::new(1, 0, 0, 0), Zeta8::ZERO,
        Zeta8::new(0, 0, 0, -1), Zeta8::ZERO, Zeta8::new(0, 0, 1, 0), Zeta8::new(0, 1, 0, -1),
    ];
    let mut norm = (0i128, 0i128);
    for &p in &psi {
        let ns = p.norm_sq_pair();
        norm.0 += ns.0;
        norm.1 += ns.1;
    }
    let (mut ci, mut cz, mut cf, mut co) = (0, 0, 0, 0);
    for a in 0..8usize {
        let (a0, a1) = (a / 2, a % 2);
        for b in 0..8usize {
            let (b0, b1) = (b / 2, b % 2);
            let mut s = Zeta8::ZERO;
            for x in 0..8usize {
                let (x0, x1) = (x / 2, x % 2);
                let xa = 2 * ((x0 + a0) % 4) + ((x1 + a1) % 2);
                let prod = psi[x].conj().mul(psi[xa]);
                s = s.add(prod.mul_pow_i(b0 * x0 + 2 * b1 * x1));
            }
            let (r0, r1) = s.norm_sq_pair();
            if r1 != 0 { co += 1; }
            else if r0 == 64 { ci += 1; }
            else if r0 == 0 { cz += 1; }
            else if r0 == 8 { cf += 1; }
            else { co += 1; }
        }
    }
    (norm, (ci, cz, cf, co))
}

pub fn verify_w44_z8_mub() -> ((i128, i128), (usize, usize, usize, usize)) {
    let psi = [
        Zeta8::new(3, 0, 1, 0), Zeta8::new(-1, 0, 3, 0), Zeta8::new(-3, 0, -1, 0), Zeta8::new(-1, 0, 3, 0),
        Zeta8::new(0, 3, 0, 1), Zeta8::new(0, 1, 0, 7), Zeta8::new(0, 3, 0, 1), Zeta8::new(0, 3, 0, 1),
        Zeta8::new(-3, 0, -1, 0), Zeta8::new(-1, 0, 3, 0), Zeta8::new(-1, 0, -7, 0), Zeta8::new(-5, 0, -5, 0),
        Zeta8::new(0, -3, 0, -1), Zeta8::new(0, -3, 0, -1), Zeta8::new(0, 5, 0, -5), Zeta8::new(0, 3, 0, 1),
    ];
    let mut norm = (0i128, 0i128);
    for &p in &psi {
        let ns = p.norm_sq_pair();
        norm.0 += ns.0;
        norm.1 += ns.1;
    }
    let (mut ci, mut cz, mut cf, mut co) = (0, 0, 0, 0);
    for a in 0..16usize {
        let (a0, a1) = (a / 4, a % 4);
        for b in 0..16usize {
            let (b0, b1) = (b / 4, b % 4);
            let mut s = Zeta8::ZERO;
            for x in 0..16usize {
                let (x0, x1) = (x / 4, x % 4);
                let xa = 4 * ((x0 + a0) % 4) + ((x1 + a1) % 4);
                let prod = psi[x].conj().mul(psi[xa]);
                s = s.add(prod.mul_pow_i(b0 * x0 + b1 * x1));
            }
            let (r0, r1) = s.norm_sq_pair();
            if r1 != 0 { co += 1; }
            else if r0 == 102400 { ci += 1; }
            else if r0 == 0 { cz += 1; }
            else if r0 == 6400 { cf += 1; }
            else { co += 1; }
        }
    }
    (norm, (ci, cz, cf, co))
}

pub fn verify_w42_super_mub() -> (i128, i128, i128, i128) {
    let v = [
        GaussInt::new(-2, 5), GaussInt::new(-2, 5), GaussInt::new(-9, 9), GaussInt::new(-9, -10),
        GaussInt::new(-11, -4), GaussInt::new(-11, -4), GaussInt::new(-1, -18), GaussInt::new(0, 1),
    ];
    let norm2: i128 = v.iter().map(|z| z.norm_sq()).sum();
    let (mut n4, mut n6, mut n8) = (0i128, 0i128, 0i128);
    for a in 0..8usize {
        let (a0, a1) = (a / 2, a % 2);
        for b in 0..8usize {
            let (b0, b1) = (b / 2, b % 2);
            let mut s = GaussInt::ZERO;
            for x in 0..8usize {
                let (x0, x1) = (x / 2, x % 2);
                let xa = 2 * ((x0 + a0) % 4) + ((x1 + a1) % 2);
                s = s.add(v[x].conj().mul(v[xa]).mul_pow_i(b0 * x0 + 2 * b1 * x1));
            }
            let m = s.norm_sq();
            let m2 = m * m;
            n4 += m2;
            n6 += m2 * m;
            n8 += m2 * m2;
        }
    }
    (norm2, n4, n6, n8)
}

pub fn verify_w44_super_mub() -> (i128, i128, i128, i128) {
    let v = [
        GaussInt::new(9, -10), GaussInt::new(-7, -1), GaussInt::new(4, 4), GaussInt::new(2, 15),
        GaussInt::new(1, 1), GaussInt::new(-7, 0), GaussInt::new(2, -1), GaussInt::new(5, 2),
        GaussInt::new(14, -7), GaussInt::new(-6, 14), GaussInt::new(3, 6), GaussInt::new(-5, -1),
        GaussInt::new(-2, 1), GaussInt::new(0, -16), GaussInt::new(3, 4), GaussInt::new(-4, 13),
    ];
    let norm2: i128 = v.iter().map(|z| z.norm_sq()).sum();
    let (mut n4, mut n6, mut n8) = (0i128, 0i128, 0i128);
    for a in 0..16usize {
        let (a0, a1) = (a / 4, a % 4);
        for b in 0..16usize {
            let (b0, b1) = (b / 4, b % 4);
            let mut s = GaussInt::ZERO;
            for x in 0..16usize {
                let (x0, x1) = (x / 4, x % 4);
                let xa = 4 * ((x0 + a0) % 4) + ((x1 + a1) % 4);
                s = s.add(v[x].conj().mul(v[xa]).mul_pow_i(b0 * x0 + b1 * x1));
            }
            let m = s.norm_sq();
            let m2 = m * m;
            n4 += m2;
            n6 += m2 * m;
            n8 += m2 * m2;
        }
    }
    (norm2, n4, n6, n8)
}

pub fn verify_n5_rupture() -> (i128, i128) {
    let v = [
        GaussInt::new(1,-2), GaussInt::new(-1,0), GaussInt::new(-2,-3), GaussInt::new(-2,-3),
        GaussInt::new(0,-1), GaussInt::new(-5,3), GaussInt::new(-2,2), GaussInt::new(1,1),
        GaussInt::new(0,1), GaussInt::new(1,-2), GaussInt::new(1,-1), GaussInt::new(1,0),
        GaussInt::new(0,-1), GaussInt::new(-2,-3), GaussInt::new(-1,0), GaussInt::new(0,3),
        GaussInt::new(0,-1), GaussInt::new(-1,2), GaussInt::new(-3,2), GaussInt::new(-5,-2),
        GaussInt::new(-1,-1), GaussInt::new(1,0), GaussInt::new(-3,1), GaussInt::new(2,2),
        GaussInt::new(0,3), GaussInt::new(1,0), GaussInt::new(-3,3), GaussInt::new(1,1),
        GaussInt::new(-3,2), GaussInt::new(3,-2), GaussInt::new(-3,0), GaussInt::new(1,3),
    ];
    let norm2: i128 = v.iter().map(|z| z.norm_sq()).sum();
    let mut num4 = 0i128;
    for a in 0..32usize {
        let mut re = [0i128; 32];
        let mut im = [0i128; 32];
        for x in 0..32usize {
            let p = v[x].conj().mul(v[x ^ a]);
            re[x] = p.re;
            im[x] = p.im;
        }
        fwht(&mut re);
        fwht(&mut im);
        for b in 0..32usize {
            let m = re[b] * re[b] + im[b] * im[b];
            num4 += m * m;
        }
    }
    (norm2, num4)
}

pub fn verify_char3_alltop(n: usize) -> (usize, usize, usize, usize) {
    let poly: &[usize] = match n {
        1 => &[1],
        2 => &[2, 0],
        3 => &[2, 1, 0],
        4 => &[1, 2, 0, 0],
        _ => panic!("unsupported n"),
    };
    let d = 3usize.pow(n as u32);
    let fmul = |u: &[usize], v: &[usize]| -> Vec<usize> {
        let mut tmp = vec![0usize; 2 * n - 1];
        for i in 0..n {
            for j in 0..n {
                tmp[i + j] = (tmp[i + j] + u[i] * v[j]) % 3;
            }
        }
        for k in (n..(2 * n - 1)).rev() {
            let c = tmp[k];
            tmp[k] = 0;
            if c != 0 {
                for i in 0..n {
                    tmp[k - n + i] = (tmp[k - n + i] + c * poly[i]) % 3;
                }
            }
        }
        tmp.truncate(n);
        tmp
    };
    let ftrace = |u: &[usize]| -> usize {
        let mut tr = 0usize;
        for i in 0..n {
            let mut ei = vec![0usize; n];
            ei[i] = 1;
            let p = fmul(u, &ei);
            tr = (tr + p[i]) % 3;
        }
        tr
    };
    let mut t_ten = vec![vec![vec![0usize; n]; n]; n];
    for i in 0..n {
        let mut ei = vec![0usize; n]; ei[i] = 1;
        for j in 0..n {
            let mut ej = vec![0usize; n]; ej[j] = 1;
            let eij = fmul(&ei, &ej);
            for k in 0..n {
                let mut ek = vec![0usize; n]; ek[k] = 1;
                t_ten[i][j][k] = ftrace(&fmul(&eij, &ek));
            }
        }
    }
    let mut vecs = vec![vec![0usize; n]; d];
    let mut g = vec![0usize; d];
    for (x, row) in vecs.iter_mut().enumerate() {
        let mut tmp = x;
        for slot in row.iter_mut().take(n) {
            *slot = tmp % 3;
            tmp /= 3;
        }
        let mut val = 0usize;
        for i in 0..n { val += t_ten[i][i][i] * row[i]; }
        for i in 0..n {
            for j in 0..n {
                if i != j {
                    val += 3 * t_ten[i][i][j] * row[i] * row[i] * row[j];
                }
            }
        }
        for i in 0..n {
            for j in (i + 1)..n {
                for k in (j + 1)..n {
                    val += 6 * t_ten[i][j][k] * row[i] * row[j] * row[k];
                }
            }
        }
        g[x] = val % 9;
    }
    let (mut ci, mut cz, mut cf, mut co) = (0, 0, 0, 0);
    let id_val = (d as i128) * (d as i128);
    let flat_val = d as i128;
    for (a, va) in vecs.iter().enumerate() {
        for vb in &vecs {
            let mut s = Zeta9::ZERO;
            for (x, vx) in vecs.iter().enumerate() {
                let mut xa = 0usize;
                let mut mult = 1usize;
                let mut bx = 0usize;
                for i in 0..n {
                    xa += ((vx[i] + va[i]) % 3) * mult;
                    mult *= 3;
                    bx += vb[i] * vx[i];
                }
                let e = (g[xa] + 9 - g[x] + 3 * bx) % 9;
                s = s.plus(Zeta9::pow(e));
            }
            let _ = a;
            let ns = s.norm_sq();
            let pure = ns.0[1..6].iter().all(|&v| v == 0);
            if !pure { co += 1; }
            else if ns.0[0] == id_val { ci += 1; }
            else if ns.0[0] == 0 { cz += 1; }
            else if ns.0[0] == flat_val { cf += 1; }
            else { co += 1; }
        }
    }
    (ci, cz, cf, co)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_pillar2_all_65536_f2_4() {
        let a = audit_all_65536_f2_4();
        assert_eq!(a.total_bent, 896);
        assert_eq!(a.quad_bent, 896);
        assert_eq!(a.deg_gt2_bent, 0);
        assert_eq!(a.bent_with_zero_triple, 896);
    }

    #[test]
    fn test_pillar3_z8_mubs_and_super_mubs() {
        assert_eq!(verify_w42_z8_mub(), ((8, 0), (1, 7, 56, 0)));
        assert_eq!(verify_w44_z8_mub(), ((320, 0), (1, 15, 240, 0)));

        let (n42, m4, m6, m8) = verify_w42_super_mub();
        assert_eq!(n42, 1001);
        assert_eq!(m4, 1_851_540_086_824);
        assert_eq!(m6, 1_114_095_888_133_087_352);
        assert_eq!(m8, 1_022_331_659_421_630_523_334_728);
        assert!(8 * m4 < 15 * 1001_i128.pow(4));
        assert!(64 * m6 < 71 * 1001_i128.pow(6));
        assert!(512 * m8 > 519 * 1001_i128.pow(8));

        let (n44, k4, k6, k8) = verify_w44_super_mub();
        assert_eq!(n44, 1596);
        assert_eq!(k4, 12_399_519_780_160);
        assert_eq!(k6, 17_475_825_055_844_169_216);
        assert_eq!(k8, 42_256_971_384_682_869_158_123_968);
        assert!(16 * k4 < 31 * 1596_i128.pow(4));
        assert!(256 * k6 < 271 * 1596_i128.pow(6));
        assert!(4096 * k8 > 4111 * 1596_i128.pow(8));
    }

    #[test]
    fn test_pillar4_n5_rupture() {
        let (norm2, num4) = verify_n5_rupture();
        assert_eq!(norm2, 254);
        assert_eq!(num4, 11_097_089_024);
        assert!(num4 < 3 * 254_i128.pow(4));
    }

    #[test]
    fn test_pillar5_char3_alltop_n1_to_n4() {
        assert_eq!(verify_char3_alltop(1), (1, 2, 6, 0));
        assert_eq!(verify_char3_alltop(2), (1, 8, 72, 0));
        assert_eq!(verify_char3_alltop(3), (1, 26, 702, 0));
        assert_eq!(verify_char3_alltop(4), (1, 80, 6480, 0));
    }
}
