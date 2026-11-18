package port_types;
typedef struct packed {
logic MRxDV;
logic [3:0] MRxD;
logic Reset;
logic Transmitting;
logic [15:0] MaxFL;
logic r_IFG;
logic HugEn;
logic DlyCrcEn;
logic [47:0] MAC;
logic r_Pro;
logic r_Bro;
logic [31:0] r_HASH0;
logic [31:0] r_HASH1;
logic PassAll;
logic ControlFrmAddressOK;
} command_t;
typedef struct packed {
logic [7:0] RxData;
logic RxValid;
logic RxStartFrm;
logic RxEndFrm;
logic [15:0] ByteCnt;
logic ByteCntEq0;
logic ByteCntGreat2;
logic ByteCntMaxFrame;
logic CrcError;
logic StateIdle;
logic StatePreamble;
logic StateSFD;
logic [1:0] StateData;
logic RxAbort;
logic AddressMiss;
} response_t;
endpackage
