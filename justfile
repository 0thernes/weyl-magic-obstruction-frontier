# SPDX-License-Identifier: Apache-2.0
set shell := ["bash", "-cu"]

default: verify-all

verify-lean:
    cd lean && lake build && lake build PalomarChallenge && lake env lean VerifyAxioms.lean && lake env leanchecker --fresh PalomarSolution && lake env leanchecker-paranoid --fresh PalomarSolution

verify-lean-6kernel:
    cd lean && lake check --paranoid && lake comparator --config comparator.json --paranoid

verify-rust:
    cd rust && cargo clippy --all-targets -- -D warnings && cargo test --release

verify-zig:
    cd zig && zig test src/main.zig && zig run -OReleaseFast src/main.zig

verify-c:
    mkdir -p build
    nasm -f elf64 asm/fwht_x64.asm -o build/fwht_x64.o
    gcc -std=c11 -O3 -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion -DWEYL_MAGIC_HAS_ASM -Ic/include c/src/weyl_magic.c c/src/qrng_stream.c c/tests/test_weyl_magic.c build/fwht_x64.o -o build/test_weyl_magic
    ./build/test_weyl_magic
    gcc -std=c11 -O1 -g -fsanitize=address,undefined -fno-omit-frame-pointer -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion -Ic/include c/src/weyl_magic.c c/src/qrng_stream.c c/tests/test_weyl_magic.c -o build/test_weyl_magic_san
    ./build/test_weyl_magic_san
    gcc -std=c11 -O3 -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion -DWEYL_MAGIC_HAS_ASM -Ic/include c/src/weyl_magic.c c/src/qrng_stream.c c/tests/fuzz_weyl_magic.c build/fwht_x64.o -o build/fuzz_weyl_magic
    ./build/fuzz_weyl_magic
    gcc -std=c11 -O2 -Wall -Wextra -Wpedantic -Werror -Wshadow -Wconversion -Ic/include c/src/weyl_magic.c c/tests/cbmc_harness.c -o build/cbmc_harness
    ./build/cbmc_harness
    gcc -std=gnu11 -O2 -Ithird_party/qgtl/include -Ithird_party/qgtl/stub third_party/qgtl/src/quantum_geometric/distributed/differential_geometry.c c/src/qgtl_bridge.c -o build/qgtl_bridge -lm
    ./build/qgtl_bridge

verify-cbmc:
    cbmc --bounds-check --pointer-check --signed-overflow-check -Ic/include c/src/weyl_magic.c c/tests/cbmc_harness.c

verify-libfuzzer:
    clang -std=c11 -O2 -g -DLIBFUZZER -fsanitize=fuzzer,address,undefined -Ic/include c/src/weyl_magic.c c/src/qrng_stream.c c/tests/fuzz_weyl_magic.c -o build/libfuzzer_fwht
    ./build/libfuzzer_fwht -runs=50000

verify-python:
    PYTHONPATH=src:. python3 examples/quickstart_demo.py
    PYTHONPATH=src:. pytest -v tests/test_all.py
    PYTHONPATH=src:. python3 scripts/mutation_check.py
    python3 scripts/check_readme_axioms.py
    python3 scripts/verify_site.py
    ruff check src reference tests scripts examples
    mypy --strict src reference

verify-moonlab:
    node node/moonlab_crosscheck.cjs

build-paper:
    python3 scripts/package_arxiv.py

audit:
    bash scripts/audit-repo.sh .

reproduce: verify-lean verify-rust verify-zig verify-c verify-moonlab verify-python build-paper
    sha256sum -c data/MANIFEST.sha256
    sha256sum -c MANIFEST.sha256

rollback tag="v1.0.0":
    git fetch --tags
    git checkout "{{tag}}"
    sha256sum -c data/MANIFEST.sha256
    sha256sum -c MANIFEST.sha256

verify-all: verify-lean verify-rust verify-zig verify-c verify-moonlab verify-python build-paper
