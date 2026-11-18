# Native Ports

DUT module `eth_rxethmac`, with no parameters, no inout ports, and all ports unsigned. Model module name `dvbench_model`, with the same native ports. All multibit vectors are indexed [width-1:0], and all outputs are within the comparison scope.

| Name | Direction | Width |
|---|---|---|
| MRxClk | In | 1 |
| MRxDV | In | 1 |
| MRxD | In | 4 |
| Reset | In | 1 |
| Transmitting | In | 1 |
| MaxFL | In | 16 |
| r_IFG | In | 1 |
| HugEn | In | 1 |
| DlyCrcEn | In | 1 |
| MAC | In | 48 |
| r_Pro | In | 1 |
| r_Bro | In | 1 |
| r_HASH0 | In | 32 |
| r_HASH1 | In | 32 |
| PassAll | In | 1 |
| ControlFrmAddressOK | In | 1 |
| RxData | Out | 8 |
| RxValid | Out | 1 |
| RxStartFrm | Out | 1 |
| RxEndFrm | Out | 1 |
| ByteCnt | Out | 16 |
| ByteCntEq0 | Out | 1 |
| ByteCntGreat2 | Out | 1 |
| ByteCntMaxFrame | Out | 1 |
| CrcError | Out | 1 |
| StateIdle | Out | 1 |
| StatePreamble | Out | 1 |
| StateSFD | Out | 1 |
| StateData | Out | 2 |
| RxAbort | Out | 1 |
| AddressMiss | Out | 1 |

MRxClk is a rising-edge clock; Reset is active-high and asynchronous. RxData is paired with RxValid; other status/counter/error outputs are observed in the current or pipeline windows specified by the spec.
