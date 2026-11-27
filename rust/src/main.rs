// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Alexander Stephen Donahue

#![forbid(unsafe_code)]
#![deny(warnings)]

use weyl_magic_verifier::{
    audit_all_65536_f2_4, verify_char3_alltop, verify_n5_rupture, verify_w42_super_mub,
    verify_w42_z8_mub, verify_w44_super_mub, verify_w44_z8_mub,
};

fn main() {
    let b4 = audit_all_65536_f2_4();
    let z42 = verify_w42_z8_mub();
    let z44 = verify_w44_z8_mub();
    let s42 = verify_w42_super_mub();
    let s44 = verify_w44_super_mub();
    let n5 = verify_n5_rupture();
    let c3 = [1, 2, 3, 4].map(verify_char3_alltop);

    println!("{{");
    println!("  \"engine\": \"rust-i128\",");
    println!("  \"bent4\": {{\"total\": {}, \"quad\": {}, \"deg_gt2\": {}, \"zero_triple\": {}}},",
             b4.total_bent, b4.quad_bent, b4.deg_gt2_bent, b4.bent_with_zero_triple);
    println!("  \"w42_z8_mub\": {{\"norm2\": {}, \"counts\": [{}, {}, {}, {}]}},",
             z42.0.0, z42.1.0, z42.1.1, z42.1.2, z42.1.3);
    println!("  \"w44_z8_mub\": {{\"norm2\": {}, \"counts\": [{}, {}, {}, {}]}},",
             z44.0.0, z44.1.0, z44.1.1, z44.1.2, z44.1.3);
    println!("  \"w42_super_mub\": {{\"norm2\": {}, \"num4\": \"{}\", \"num6\": \"{}\", \"num8\": \"{}\"}},",
             s42.0, s42.1, s42.2, s42.3);
    println!("  \"w44_super_mub\": {{\"norm2\": {}, \"num4\": \"{}\", \"num6\": \"{}\", \"num8\": \"{}\"}},",
             s44.0, s44.1, s44.2, s44.3);
    println!("  \"n5_rupture\": {{\"norm2\": {}, \"num4\": \"{}\"}},", n5.0, n5.1);
    println!("  \"char3_alltop\": [");
    for (idx, row) in c3.iter().enumerate() {
        let comma = if idx + 1 < c3.len() { "," } else { "" };
        println!("    {{\"n\": {}, \"counts\": [{}, {}, {}, {}]}}{}",
                 idx + 1, row.0, row.1, row.2, row.3, comma);
    }
    println!("  ]");
    println!("}}");
}
