# Native interface

The design uses the evaluator-provided `meta_package` types as its native interface. Their declarations are supplied before the candidate filelist; candidate compilation does not need hidden source paths.

| Port | Direction | Width/type |
|---|---|---|
| `clk`, `reset_n` | input | 1 each; reset is synchronous active low |
| `ecdsa_lh_wr` | input | 1 |
| `ecdsa_lh_waddr` | input | 12 |
| `ecdsa_lh_wdata` | input | 256 |
| `ecdsa_lh_sn_wdata` | input | 64 |
| `ecdsa_lh_ppl_wdata` | input | 6 |
| `irl_lh_valid`, `irl_lh_sop`, `irl_lh_eop` | input | 1 each |
| `irl_lh_hdr_data` | input | 128 |
| `irl_lh_meta_data` | input | `meta_package::irl_lh_meta_type` |
| `ecdsa_lh_ready` | input | 1; not used as a write handshake |
| `lh_ecdsa_hash_valid`, `lh_ecdsa_valid` | output | 1 each |
| `lh_ecdsa_hash_data` | output | 256 |
| `lh_ecdsa_hdr_data` | output | 128 |
| `lh_ecdsa_meta_data` | output | `meta_package::lh_ecdsa_meta_type` |
| `lh_ecdsa_sop`, `lh_ecdsa_eop` | output | 1 each |
| `lh_pp_valid` | output | 1 |
| `lh_pp_hdr_data` | output | 128 |
| `lh_pp_meta_data` | output | `meta_package::lh_pp_meta_type` |
| `lh_pp_sop`, `lh_pp_eop` | output | 1 each |

All three metadata types are unpacked SystemVerilog structs, with unsigned four-state logic fields. No implicit packed bit-vector layout exists. The evaluator supplies meta_package before the submission filelist; do not redeclare that package.

| Field in declaration order | irl_lh_meta_type | lh_ecdsa_meta_type | lh_pp_meta_type |
|---|---:|---:|---:|
| traffic_class | 8 | 8 | absent |
| hdr_len | 8 | 8 | 8 |
| buf_ptr | 12 | 12 | 12 |
| len | 14 | 14 | 14 |
| port | 3 | 3 | 3 |
| rci | 12 | 12 | 12 |
| fid | 12 | 12 | 12 |
| tid | 10 | 10 | 10 |
| type1 | 1 | 1 | 1 |
| type3 | 1 | 1 | 1 |
| discard | 1 | 1 | 1 |

Aggregate field widths are 82, 82 and 74 bits. Assign and compare fields individually. Vectors have descending indices. The input/ECDSA types are distinct despite identical fields. No top-level parameters exist.

