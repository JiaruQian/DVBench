task send_short_reset();
            cq_item item=cq_item::type_id::create("short_reset");
            if(vif.stop_requested) return;
            start_item(item);
            item.reset_request=1;
            item.short_reset=1;
            finish_item(item);
        endtask
        task short_reset_witnesses();
            int completed_cases;
            completed_cases=0;
            for(int prior_writes=1;prior_writes<=256;prior_writes++)begin
                if(vif.stop_requested) return;
                send_reset();
                for(int write_index=0;write_index<prior_writes;write_index++)
                    send_cycle(1,1,write_index%128,0);
                repeat(3) send_cycle(0,1,0,0);
                if(vif.expected_valid !== 1'b0 || vif.expected_ready !== 1'b1)
                    `uvm_error("PROBE_VACUITY","Independent queue failed to drain before short reset")
                send_short_reset();
                send_cycle(1,0,7'h7f,32'hffffffff);
                send_cycle(0,0,0,0);
                if(!vif.stop_requested && (vif.expected_valid !== 1'b1 || vif.expected_data !== 7'h7f))
                    `uvm_error("PROBE_VACUITY","Independent queue failed post-reset isolated readback")
                send_cycle(0,1,0,0);
                completed_cases++;
            end
            if(!vif.stop_requested && completed_cases!=256)
                `uvm_error("PROBE_VACUITY","Short reset pointer matrix incomplete")
        endtask
        