# Native interface contract

The hidden DUT is `VGASyncModule_TopLevel`; no RTL implementation is distributed.

| Port | Direction | Width | Contract |
|---|---|---:|---|
| `Clock` | input | 1 | sole rising-edge clock |
| `Reset` | input | 1 | synchronous active-high reset sampled on `Clock` rising edge |
| `Enabled` | input | 1 | sampled on `Clock` rising edge when reset is low |
| `OutCounter` | output | 10 | unsigned counter |
| `OutVisible`, `OutFP`, `OutSP`, `OutBP`, `OutMax` | output | 1 each | combinational decoded flags |

The service replaces a declaration-only DUT boundary with the fixed hidden implementation. Candidate HDL may connect these native ports but may not use hierarchy, bind, force, VPI/DPI, file I/O, or simulator debug databases.
