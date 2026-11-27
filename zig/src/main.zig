// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alexander Stephen Donahue
//
// Zero-dependency Zig (0.14.1+ / 0.17.0 compatible) comptime-specialized exact i128
// verifier across the finite witnesses of the Weyl-Heisenberg Magic Obstruction Frontier.

const std = @import("std");

const Gauss = struct {
    re: i128,
    im: i128,

    fn add(a: Gauss, b: Gauss) Gauss {
        return .{ .re = a.re + b.re, .im = a.im + b.im };
    }
    fn conj(a: Gauss) Gauss {
        return .{ .re = a.re, .im = -a.im };
    }
    fn mul(a: Gauss, b: Gauss) Gauss {
        return .{
            .re = a.re * b.re - a.im * b.im,
            .im = a.re * b.im + a.im * b.re,
        };
    }
    fn mulPowI(a: Gauss, q: usize) Gauss {
        return switch (q & 3) {
            0 => a,
            1 => .{ .re = -a.im, .im = a.re },
            2 => .{ .re = -a.re, .im = -a.im },
            else => .{ .re = a.im, .im = -a.re },
        };
    }
    fn normSq(a: Gauss) i128 {
        return a.re * a.re + a.im * a.im;
    }
};

const Zeta8 = struct {
    c0: i128,
    c1: i128,
    c2: i128,
    c3: i128,

    fn add(a: Zeta8, b: Zeta8) Zeta8 {
        return .{ .c0 = a.c0 + b.c0, .c1 = a.c1 + b.c1, .c2 = a.c2 + b.c2, .c3 = a.c3 + b.c3 };
    }
    fn conj(a: Zeta8) Zeta8 {
        return .{ .c0 = a.c0, .c1 = -a.c3, .c2 = -a.c2, .c3 = -a.c1 };
    }
    fn mul(a: Zeta8, b: Zeta8) Zeta8 {
        return .{
            .c0 = a.c0 * b.c0 - a.c1 * b.c3 - a.c2 * b.c2 - a.c3 * b.c1,
            .c1 = a.c0 * b.c1 + a.c1 * b.c0 - a.c2 * b.c3 - a.c3 * b.c2,
            .c2 = a.c0 * b.c2 + a.c1 * b.c1 + a.c2 * b.c0 - a.c3 * b.c3,
            .c3 = a.c0 * b.c3 + a.c1 * b.c2 + a.c2 * b.c1 + a.c3 * b.c0,
        };
    }
    fn mulPowI(a: Zeta8, q: usize) Zeta8 {
        return switch (q & 3) {
            0 => a,
            1 => .{ .c0 = -a.c2, .c1 = -a.c3, .c2 = a.c0, .c3 = a.c1 },
            2 => .{ .c0 = -a.c0, .c1 = -a.c1, .c2 = -a.c2, .c3 = -a.c3 },
            else => .{ .c0 = a.c2, .c1 = a.c3, .c2 = -a.c0, .c3 = -a.c1 },
        };
    }
};

fn fwhtComptime(comptime N: usize, buf: *[N]i128) void {
    var half: usize = 1;
    while (half < N) : (half <<= 1) {
        const step = half << 1;
        var base: usize = 0;
        while (base < N) : (base += step) {
            for (0..half) |k| {
                const x = buf[base + k];
                const y = buf[base + k + half];
                buf[base + k] = x + y;
                buf[base + k + half] = x - y;
            }
        }
    }
}

fn ipow128(base: i128, exp: usize) i128 {
    var r: i128 = 1;
    for (0..exp) |_| r *= base;
    return r;
}

const AuditResult = struct {
    bent_total: usize,
    bent_quad: usize,
    bent_triples: usize,
    w42_mub_ok: bool,
    w44_mub_ok: bool,
    w42_super_ok: bool,
    w44_super_ok: bool,
    n5_rupture_ok: bool,
    n5_num4: i128,
    w42_num4: i128,
    w44_num4: i128,
};

fn runAllChecks() AuditResult {
    var res = AuditResult{
        .bent_total = 0,
        .bent_quad = 0,
        .bent_triples = 0,
        .w42_mub_ok = false,
        .w44_mub_ok = false,
        .w42_super_ok = false,
        .w44_super_ok = false,
        .n5_rupture_ok = false,
        .n5_num4 = 0,
        .w42_num4 = 0,
        .w44_num4 = 0,
    };

    // Pillar 2: all 65,536 Boolean functions on F_2^4
    for (0..65536) |tt| {
        var w: [16]i128 = undefined;
        for (0..16) |x| {
            w[x] = if (((tt >> @as(u5, @intCast(x))) & 1) == 1) -1 else 1;
        }
        fwhtComptime(16, &w);
        var is_bent = true;
        for (w) |v| {
            if (v != 4 and v != -4) {
                is_bent = false;
                break;
            }
        }
        if (!is_bent) continue;
        res.bent_total += 1;

        var anf: [16]u8 = undefined;
        for (0..16) |x| anf[x] = @intCast((tt >> @as(u5, @intCast(x))) & 1);
        for (0..4) |bit| {
            const step = @as(usize, 1) << @as(u3, @intCast(bit));
            for (0..16) |x| {
                if ((x & step) != 0) anf[x] ^= anf[x ^ step];
            }
        }
        var max_deg: usize = 0;
        for (0..16) |m| {
            if (anf[m] != 0) {
                const wt: usize = @popCount(@as(u8, @intCast(m)));
                if (wt > max_deg) max_deg = wt;
            }
        }
        if (max_deg <= 2) res.bent_quad += 1;

        var ea: [16]u16 = @splat(0);
        for (1..16) |a| {
            var mask: u16 = 0;
            for (0..16) |x| {
                const fx = (tt >> @as(u5, @intCast(x))) & 1;
                const fxa = (tt >> @as(u5, @intCast(x ^ a))) & 1;
                if (fx == fxa) mask |= @as(u16, 1) << @as(u4, @intCast(x));
            }
            ea[a] = mask;
        }
        var found = false;
        outer: for (1..16) |a| {
            for ((a + 1)..16) |b| {
                if ((ea[a] ^ ea[b] ^ ea[a ^ b]) == 0) {
                    found = true;
                    break :outer;
                }
            }
        }
        if (found) res.bent_triples += 1;
    }

    // Pillar 3: W(4)xW(2) and W(4)xW(4) Z[zeta_8] MUB fiducials
    const psi42 = [8]Zeta8{
        .{ .c0 = 0, .c1 = -1, .c2 = 0, .c3 = 0 },
        .{ .c0 = -1, .c1 = 0, .c2 = -1, .c3 = 0 },
        .{ .c0 = 1, .c1 = 0, .c2 = 0, .c3 = 0 },
        .{ .c0 = 0, .c1 = 0, .c2 = 0, .c3 = 0 },
        .{ .c0 = 0, .c1 = 0, .c2 = 0, .c3 = -1 },
        .{ .c0 = 0, .c1 = 0, .c2 = 0, .c3 = 0 },
        .{ .c0 = 0, .c1 = 0, .c2 = 1, .c3 = 0 },
        .{ .c0 = 0, .c1 = 1, .c2 = 0, .c3 = -1 },
    };
    var norm42 = Zeta8{ .c0 = 0, .c1 = 0, .c2 = 0, .c3 = 0 };
    for (psi42) |p| norm42 = norm42.add(p.mul(p.conj()));
    var ci: usize = 0;
    var cz: usize = 0;
    var cf: usize = 0;
    var co: usize = 0;
    for (0..8) |a| {
        const a0 = a / 2;
        const a1 = a % 2;
        for (0..8) |b| {
            const b0 = b / 2;
            const b1 = b % 2;
            var s = Zeta8{ .c0 = 0, .c1 = 0, .c2 = 0, .c3 = 0 };
            for (0..8) |x| {
                const x0 = x / 2;
                const x1 = x % 2;
                const xa = 2 * ((x0 + a0) % 4) + ((x1 + a1) % 2);
                s = s.add(psi42[x].conj().mul(psi42[xa]).mulPowI(b0 * x0 + 2 * b1 * x1));
            }
            const ns = s.mul(s.conj());
            if (ns.c1 != 0 or ns.c2 != 0 or ns.c3 != 0) co += 1
            else if (ns.c0 == 64) ci += 1
            else if (ns.c0 == 0) cz += 1
            else if (ns.c0 == 8) cf += 1
            else co += 1;
        }
    }
    res.w42_mub_ok = (norm42.c0 == 8 and norm42.c1 == 0 and norm42.c2 == 0 and norm42.c3 == 0 and
        ci == 1 and cz == 7 and cf == 56 and co == 0);

    const psi44 = [16]Zeta8{
        .{ .c0 = 3, .c1 = 0, .c2 = 1, .c3 = 0 }, .{ .c0 = -1, .c1 = 0, .c2 = 3, .c3 = 0 },
        .{ .c0 = -3, .c1 = 0, .c2 = -1, .c3 = 0 }, .{ .c0 = -1, .c1 = 0, .c2 = 3, .c3 = 0 },
        .{ .c0 = 0, .c1 = 3, .c2 = 0, .c3 = 1 }, .{ .c0 = 0, .c1 = 1, .c2 = 0, .c3 = 7 },
        .{ .c0 = 0, .c1 = 3, .c2 = 0, .c3 = 1 }, .{ .c0 = 0, .c1 = 3, .c2 = 0, .c3 = 1 },
        .{ .c0 = -3, .c1 = 0, .c2 = -1, .c3 = 0 }, .{ .c0 = -1, .c1 = 0, .c2 = 3, .c3 = 0 },
        .{ .c0 = -1, .c1 = 0, .c2 = -7, .c3 = 0 }, .{ .c0 = -5, .c1 = 0, .c2 = -5, .c3 = 0 },
        .{ .c0 = 0, .c1 = -3, .c2 = 0, .c3 = -1 }, .{ .c0 = 0, .c1 = -3, .c2 = 0, .c3 = -1 },
        .{ .c0 = 0, .c1 = 5, .c2 = 0, .c3 = -5 }, .{ .c0 = 0, .c1 = 3, .c2 = 0, .c3 = 1 },
    };
    var norm44 = Zeta8{ .c0 = 0, .c1 = 0, .c2 = 0, .c3 = 0 };
    for (psi44) |p| norm44 = norm44.add(p.mul(p.conj()));
    ci = 0; cz = 0; cf = 0; co = 0;
    for (0..16) |a| {
        const a0 = a / 4;
        const a1 = a % 4;
        for (0..16) |b| {
            const b0 = b / 4;
            const b1 = b % 4;
            var s = Zeta8{ .c0 = 0, .c1 = 0, .c2 = 0, .c3 = 0 };
            for (0..16) |x| {
                const x0 = x / 4;
                const x1 = x % 4;
                const xa = 4 * ((x0 + a0) % 4) + ((x1 + a1) % 4);
                s = s.add(psi44[x].conj().mul(psi44[xa]).mulPowI(b0 * x0 + b1 * x1));
            }
            const ns = s.mul(s.conj());
            if (ns.c1 != 0 or ns.c2 != 0 or ns.c3 != 0) co += 1
            else if (ns.c0 == 102400) ci += 1
            else if (ns.c0 == 0) cz += 1
            else if (ns.c0 == 6400) cf += 1
            else co += 1;
        }
    }
    res.w44_mub_ok = (norm44.c0 == 320 and norm44.c1 == 0 and norm44.c2 == 0 and norm44.c3 == 0 and
        ci == 1 and cz == 15 and cf == 240 and co == 0);

    // Pillar 3: Super-MUB Z[i] witnesses
    const v42 = [8]Gauss{
        .{ .re = -2, .im = 5 }, .{ .re = -2, .im = 5 }, .{ .re = -9, .im = 9 }, .{ .re = -9, .im = -10 },
        .{ .re = -11, .im = -4 }, .{ .re = -11, .im = -4 }, .{ .re = -1, .im = -18 }, .{ .re = 0, .im = 1 },
    };
    var norm_v42: i128 = 0;
    for (v42) |z| norm_v42 += z.normSq();
    var n4: i128 = 0;
    var n6: i128 = 0;
    var n8: i128 = 0;
    for (0..8) |a| {
        const a0 = a / 2;
        const a1 = a % 2;
        for (0..8) |b| {
            const b0 = b / 2;
            const b1 = b % 2;
            var s = Gauss{ .re = 0, .im = 0 };
            for (0..8) |x| {
                const x0 = x / 2;
                const x1 = x % 2;
                const xa = 2 * ((x0 + a0) % 4) + ((x1 + a1) % 2);
                s = s.add(v42[x].conj().mul(v42[xa]).mulPowI(b0 * x0 + 2 * b1 * x1));
            }
            const m = s.normSq();
            const m2 = m * m;
            n4 += m2;
            n6 += m2 * m;
            n8 += m2 * m2;
        }
    }
    res.w42_num4 = n4;
    res.w42_super_ok = (norm_v42 == 1001 and n4 == 1851540086824 and
        8 * n4 < 15 * ipow128(norm_v42, 4) and
        64 * n6 < 71 * ipow128(norm_v42, 6) and
        512 * n8 > 519 * ipow128(norm_v42, 8));

    const v44 = [16]Gauss{
        .{ .re = 9, .im = -10 }, .{ .re = -7, .im = -1 }, .{ .re = 4, .im = 4 }, .{ .re = 2, .im = 15 },
        .{ .re = 1, .im = 1 }, .{ .re = -7, .im = 0 }, .{ .re = 2, .im = -1 }, .{ .re = 5, .im = 2 },
        .{ .re = 14, .im = -7 }, .{ .re = -6, .im = 14 }, .{ .re = 3, .im = 6 }, .{ .re = -5, .im = -1 },
        .{ .re = -2, .im = 1 }, .{ .re = 0, .im = -16 }, .{ .re = 3, .im = 4 }, .{ .re = -4, .im = 13 },
    };
    var norm_v44: i128 = 0;
    for (v44) |z| norm_v44 += z.normSq();
    n4 = 0; n6 = 0; n8 = 0;
    for (0..16) |a| {
        const a0 = a / 4;
        const a1 = a % 4;
        for (0..16) |b| {
            const b0 = b / 4;
            const b1 = b % 4;
            var s = Gauss{ .re = 0, .im = 0 };
            for (0..16) |x| {
                const x0 = x / 4;
                const x1 = x % 4;
                const xa = 4 * ((x0 + a0) % 4) + ((x1 + a1) % 4);
                s = s.add(v44[x].conj().mul(v44[xa]).mulPowI(b0 * x0 + b1 * x1));
            }
            const m = s.normSq();
            const m2 = m * m;
            n4 += m2;
            n6 += m2 * m;
            n8 += m2 * m2;
        }
    }
    res.w44_num4 = n4;
    res.w44_super_ok = (norm_v44 == 1596 and n4 == 12399519780160 and
        16 * n4 < 31 * ipow128(norm_v44, 4) and
        256 * n6 < 271 * ipow128(norm_v44, 6) and
        4096 * n8 > 4111 * ipow128(norm_v44, 8));

    // Pillar 4: 5-qubit rupture witness
    const v5 = [32]Gauss{
        .{ .re = 1, .im = -2 }, .{ .re = -1, .im = 0 }, .{ .re = -2, .im = -3 }, .{ .re = -2, .im = -3 },
        .{ .re = 0, .im = -1 }, .{ .re = -5, .im = 3 }, .{ .re = -2, .im = 2 }, .{ .re = 1, .im = 1 },
        .{ .re = 0, .im = 1 }, .{ .re = 1, .im = -2 }, .{ .re = 1, .im = -1 }, .{ .re = 1, .im = 0 },
        .{ .re = 0, .im = -1 }, .{ .re = -2, .im = -3 }, .{ .re = -1, .im = 0 }, .{ .re = 0, .im = 3 },
        .{ .re = 0, .im = -1 }, .{ .re = -1, .im = 2 }, .{ .re = -3, .im = 2 }, .{ .re = -5, .im = -2 },
        .{ .re = -1, .im = -1 }, .{ .re = 1, .im = 0 }, .{ .re = -3, .im = 1 }, .{ .re = 2, .im = 2 },
        .{ .re = 0, .im = 3 }, .{ .re = 1, .im = 0 }, .{ .re = -3, .im = 3 }, .{ .re = 1, .im = 1 },
        .{ .re = -3, .im = 2 }, .{ .re = 3, .im = -2 }, .{ .re = -3, .im = 0 }, .{ .re = 1, .im = 3 },
    };
    var norm_v5: i128 = 0;
    for (v5) |z| norm_v5 += z.normSq();
    var total5: i128 = 0;
    for (0..32) |a| {
        var re_buf: [32]i128 = undefined;
        var im_buf: [32]i128 = undefined;
        for (0..32) |x| {
            const p = v5[x].conj().mul(v5[x ^ a]);
            re_buf[x] = p.re;
            im_buf[x] = p.im;
        }
        fwhtComptime(32, &re_buf);
        fwhtComptime(32, &im_buf);
        for (0..32) |b| {
            const m = re_buf[b] * re_buf[b] + im_buf[b] * im_buf[b];
            total5 += m * m;
        }
    }
    res.n5_num4 = total5;
    res.n5_rupture_ok = (norm_v5 == 254 and total5 == 11097089024 and total5 < 3 * ipow128(norm_v5, 4));
    return res;
}

pub fn main() !void {
    const r = runAllChecks();
    if (r.bent_total != 896 or r.bent_quad != 896 or r.bent_triples != 896 or
        !r.w42_mub_ok or !r.w44_mub_ok or !r.w42_super_ok or !r.w44_super_ok or !r.n5_rupture_ok)
    {
        return error.VerificationFailed;
    }
    std.debug.print(
        "[zig] PASS: bent4=({d},{d},{d}) w42_num4={d} w44_num4={d} n5_num4={d}\n",
        .{ r.bent_total, r.bent_quad, r.bent_triples, r.w42_num4, r.w44_num4, r.n5_num4 },
    );
}

test "weyl-magic exact i128 verification" {
    const r = runAllChecks();
    try std.testing.expectEqual(@as(usize, 896), r.bent_total);
    try std.testing.expectEqual(@as(usize, 896), r.bent_quad);
    try std.testing.expectEqual(@as(usize, 896), r.bent_triples);
    try std.testing.expect(r.w42_mub_ok);
    try std.testing.expect(r.w44_mub_ok);
    try std.testing.expect(r.w42_super_ok);
    try std.testing.expect(r.w44_super_ok);
    try std.testing.expect(r.n5_rupture_ok);
}
