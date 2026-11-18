module dvbench_model #(
    parameter APB_ADDR_WIDTH=12
)(
    input logic HCLK,HRESETn,
    input logic [APB_ADDR_WIDTH-1:0] PADDR,
    input logic [31:0] PWDATA,
    input logic PWRITE,PSEL,PENABLE,
    output logic [31:0] PRDATA,
    output logic PREADY,PSLVERR,
    input logic dft_cg_enable_i,ref_clk_i,event_lo_i,event_hi_i,
    output logic [31:0] timer_val_lo_o,
    output logic irq_lo_o,irq_hi_o,busy_o
);
    logic [31:0] configuration[0:1];
    logic [31:0] comparison[0:1];
    logic [31:0] elapsed[0:1];
    logic [31:0] divider_count[0:1];
    logic [1:0] reached,divider_reached,pause_after_match;
    logic [3:0] reference_samples;
    logic [31:0] updated_configuration[0:1];
    logic [31:0] updated_comparison[0:1];
    logic [1:0] clear_counter,clear_divider,write_counter,start_timer,reset_timer;
    logic [1:0] counter_tick,divider_tick,clock_active;
    logic [31:0] divider_limit[0:1];
    logic access,write_access,legal_address,reference_rise,delayed_reference_rise;
    logic [5:0] offset;

    assign access=PSEL && PENABLE;
    assign write_access=access && PWRITE;
    assign offset=PADDR[5:0];
    assign reference_rise=reference_samples[1] && !reference_samples[2];
    assign delayed_reference_rise=reference_samples[2] && !reference_samples[3];
    assign timer_val_lo_o=elapsed[0];
    assign busy_o=configuration[0][0] || configuration[1][0];
    assign PREADY=access;

    always_comb begin
        legal_address=PADDR[APB_ADDR_WIDTH-1:6]=='h10;
        case(offset)
            0,4,8,12,16,20,24,28,32,36:begin end
            default:legal_address=0;
        endcase
        PRDATA=0;
        PSLVERR=access && !legal_address;
        if(access && !legal_address)PRDATA=32'hdeadbeef;
        else if(access && !PWRITE)begin
            case(offset)
                0:PRDATA=configuration[0];
                4:PRDATA=configuration[1];
                8:PRDATA=elapsed[0];
                12:PRDATA=elapsed[1];
                16:PRDATA=comparison[0];
                20:PRDATA=comparison[1];
                default:PRDATA=0;
            endcase
        end
        write_counter=0;start_timer=0;reset_timer=0;
        for(integer channel=0;channel<2;channel=channel+1)begin
            updated_configuration[channel]=configuration[channel];
            updated_comparison[channel]=comparison[channel];
        end
        if(write_access && legal_address)begin
            case(offset)
                0:updated_configuration[0]=PWDATA;
                4:updated_configuration[1]=PWDATA;
                8:write_counter[0]=1;
                12:write_counter[1]=1;
                16:updated_comparison[0]=PWDATA;
                20:updated_comparison[1]=PWDATA;
                24:start_timer[0]=1;
                28:start_timer[1]=1;
                32:reset_timer[0]=1;
                36:reset_timer[1]=1;
                default:begin end
            endcase
        end
        for(integer channel=0;channel<2;channel=channel+1)begin
            clear_counter[channel]=configuration[channel][1] || reset_timer[channel];
            clear_divider[channel]=clear_counter[channel];
            if(!clear_counter[channel])begin
                if(configuration[0][31])clear_counter[channel]=configuration[0][4] && (&reached);
                else clear_counter[channel]=configuration[channel][4] && reached[channel];
            end
            if(configuration[channel][6] && divider_reached[channel])
                clear_divider[channel]=!configuration[channel][7] || reference_rise;
            divider_limit[channel]={24'b0,configuration[channel][15:8]}+(configuration[channel][7]?1:0);
            divider_tick[channel]=configuration[channel][0] && configuration[channel][6] && (!configuration[channel][7] || reference_rise);
            counter_tick[channel]=configuration[channel][0] && (configuration[channel][6]?divider_reached[channel]:(!configuration[channel][7] || reference_rise));
        end
        if(configuration[0][0] && configuration[0][31])begin
            counter_tick[1]=(elapsed[0]==32'hffffffff) &&
                (configuration[0][6]?divider_reached[0]:1'b1) &&
                (!configuration[0][7] || delayed_reference_rise);
        end
        clock_active[0]=dft_cg_enable_i || clear_counter[0] || write_counter[0] || configuration[0][0];
        clock_active[1]=dft_cg_enable_i || clear_counter[1] || write_counter[1] || configuration[1][0] || (configuration[0][0] && configuration[0][31]);
        if((event_lo_i && updated_configuration[0][3]) || start_timer[0])updated_configuration[0][0]=1;
        else if(updated_configuration[0][5] && reached[0] && (!configuration[0][31] || reached[1]))updated_configuration[0][0]=0;
        if((event_hi_i && updated_configuration[1][3]) || start_timer[1])updated_configuration[1][0]=1;
        else if((!configuration[1][31] && updated_configuration[1][5] && reached[1]) || (updated_configuration[0][5] && (&reached)))updated_configuration[1][0]=0;
        for(integer channel=0;channel<2;channel=channel+1)
            if(clear_counter[channel])updated_configuration[channel][1]=0;
        irq_lo_o=reached[0] && configuration[0][2] && configuration[0][0] && (!configuration[0][31] || reached[1]);
        irq_hi_o=!configuration[0][31] && reached[1] && configuration[1][2] && configuration[1][0];
    end

    always @(posedge HCLK or negedge HRESETn)begin
        if(!HRESETn)begin
            reference_samples<=0;
            reached<=0;divider_reached<=0;pause_after_match<=0;
            for(integer channel=0;channel<2;channel=channel+1)begin
                configuration[channel]<=0;comparison[channel]<=0;
                elapsed[channel]<=0;divider_count[channel]<=0;
            end
        end else begin
            reference_samples<={reference_samples[2:0],ref_clk_i};
            for(integer channel=0;channel<2;channel=channel+1)begin
                logic [31:0] proposed_value,proposed_divider;
                configuration[channel]<=updated_configuration[channel];
                comparison[channel]<=updated_comparison[channel];
                if(clock_active[channel])begin
                    if(clear_counter[channel])proposed_value=0;
                    else if(write_counter[channel])proposed_value=PWDATA;
                    else proposed_value=elapsed[channel]+(counter_tick[channel]?1:0);
                    reached[channel]<=counter_tick[channel] && !pause_after_match[channel] && proposed_value==comparison[channel];
                    if(!pause_after_match[channel] || clear_counter[channel] || write_counter[channel])elapsed[channel]<=proposed_value;
                    if(clear_counter[channel] || write_counter[channel] || (pause_after_match[channel] && counter_tick[channel]))pause_after_match[channel]<=0;
                    else if(counter_tick[channel] && proposed_value==comparison[channel])pause_after_match[channel]<=1;
                    if(clear_divider[channel] || divider_reached[channel])proposed_divider=0;
                    else proposed_divider=divider_count[channel]+(divider_tick[channel]?1:0);
                    divider_count[channel]<=proposed_divider;
                    divider_reached[channel]<=divider_tick[channel] && proposed_divider>=divider_limit[channel];
                end
            end
        end
    end
endmodule
