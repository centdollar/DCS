// synopsys translate_off
`timescale 1 ps / 1 ps
// synopsys translate_on

// Comment this out until you pass the endurance test:
// `define random_test_enable

module vfm_cache_4w_v_tb;

//----------------------------------------------------------------------------
// 4-Way Set Associative Mapped Cache and Memory;
// The maximum memory capacity is 2^16 16-bit words.
// There are 2^5=32 words per block, and therefore 2^11 total blocks in MEM.
// The cache has 32 block locations.
// The address structure is: TAG=8-bit | Group=3-bit | Word=5-bit
//----------------------------------------------------------------------------

localparam address_width    = 14 ; // this is 12 instead of 16 to speed up compilation
localparam word_addr_width  =  3 ; // 2^5=32 words per block
localparam group_addr_width =  2 ;
localparam tag_addr_width   =  9 ; // this is 4 instead of 8 to speed up compilation
localparam set_addr_width   =  2 ; // 4-way set associative

reg  [ 13:0]                      MEM_in_tb        ;
reg  [ tag_addr_width   - 1 : 0 ] tag_addr_tb      ;
reg  [ group_addr_width - 1 : 0 ] group_addr_tb    ;
reg  [ word_addr_width  - 1 : 0 ] word_addr_tb     ;
reg                               Resetn_tb        ;
reg                               WR_tb            ;
reg                               Clock_tb         ;
reg                               Clock_dut        ;
reg  [511:0]                      Wave_Message     ;
wire [ 13:0]                      MEM_address_tb   ;
wire [ 13:0]                      MEM_out_tb       ;
wire [ 13:0]                      MEM_out_check_tb ;
wire                              Done_tb          ;

integer i           ;
integer j           ;
integer error_count ;

/**********************************************************************
*       Device Under Test                                             *
**********************************************************************/
vfm_cache_4w_v2 dut (
    .Resetn      ( Resetn_tb             ), // input
    .MEM_address ( MEM_address_tb [13:0] ), // input   // Address coming from the CPU
    .MEM_in      ( MEM_in_tb      [13:0] ), // input   // Write-Back data from the CPU
    .WR          ( WR_tb                 ), // input   // Write-Enable from the CPU
    .Clock       ( Clock_dut             ), // input
    .MEM_out     ( MEM_out_tb     [13:0] ), // output  // Data Stored at the Address pointed to by MEM_address
    .Done        ( Done_tb               )  // output  // Data out is valid
);
defparam dut.main_mem.altsyncram_component.init_file = "vfmRISC521_rom1.mif"; // Override mif selection -> Take note of this for your future labs!

/**********************************************************************
*       TB Reference Memory                                           *
**********************************************************************/
// We will use this memory to verify that the cache operates as intended
//      Remember, the cache replaces your monolithic memory, so it must behave like one
vfmRISC521_ram1 mem_model (
    .address ( MEM_address_tb   [13:0] ), // input  [ma_max-1:0]  // Address coming from CPU
    .clock   ( Clock_dut               ), // input
    .data    ( MEM_in_tb        [13:0] ), // input  [md_max-1:0]  // Write-Back data from the CPU
    .wren    ( WR_tb                   ), // input                // Write-Enable from the CPU
    .q       ( MEM_out_check_tb [13:0] )  // output [md_max-1:0]  // Data Stored at the Address pointed to by MEM_address
);
defparam mem_model.altsyncram_component.init_file = "vfmRISC521_rom1.mif";

// Setup Free-Running Clock
always #10000 Clock_tb = ~(Clock_tb === 1'd1); // 50 MHz
always @(Clock_tb) #20 Clock_dut = Clock_tb;

// Assign address = components
assign MEM_address_tb = {tag_addr_tb, group_addr_tb, word_addr_tb};

/**********************************************************************
*       Simulation Watchdog                                           *
**********************************************************************/
initial begin
    // In case the done signal never comes up:
    repeat (1000000) @(posedge Clock_tb);
    $display ("\n\n------------------------------------------------------------");
    $display ("ERROR: Watchdog tripped, check for hanging test sequence");
    $display ("------------------------------------------------------------\n\n");
    $stop; // Normally we would use $finish, but modelsim prefers $stop
end

/**********************************************************************
*       Reference Memory vs Cache Assertion                           *
**********************************************************************/
always @(negedge Clock_dut) begin
    #10;
    if(Done_tb) begin
        if(MEM_out_tb != MEM_out_check_tb) begin
        // Look in the transcript to see if this assertion is tripped
            $display("Model check failed for address: %d, expected data: %d, recieved data: %d, at time: %t", MEM_address_tb, MEM_out_check_tb, MEM_out_tb, $time());
            error_count = error_count + 1;
        end
    end
end

/**********************************************************************
*       Test Sequence                                                 *
**********************************************************************/
initial begin
    // Initialize TB variables
    Wave_Message   = "Reset";
    error_count    = 0;
    // reset the dut
    Resetn_tb      = 1'd0  ;
    MEM_in_tb      = 16'd0 ;
    WR_tb          = 1'd0  ;
    tag_addr_tb    = 0     ;
    group_addr_tb  = 0     ;
    word_addr_tb   = 0     ;

    repeat (10) @(posedge Clock_tb);
    Resetn_tb = 1'd1;
    $display ("\n\n------------------------------------------------------------");
    $display ("Start of Basic Test Sequence:");
    $display ("------------------------------------------------------------");

// Demo a read miss:
    // -> when the device comes out of reset it will immediately miss and populate address/block 0
    Wave_Message = "Basic Test Start";
    @(posedge Clock_tb);
    Wave_Message = "Basic Test: Expect Startup Miss";
    if(Done_tb) begin 
        $display ("Simulation failed, should miss on startup at time: %t", $time());
        error_count = error_count + 1;
    end
    else begin
        $display ("Read miss on startup pass");
        wait (Done_tb);
    end
// Now block 0 is loaded

// Demo a read hit in block 0:
    @(posedge Clock_tb);
    Wave_Message = "Basic Test: Expect Read Hit";
    word_addr_tb = {word_addr_width{1'd1}};
    @(posedge Clock_tb);
    if(!Done_tb) begin 
        $display ("Simulation failed, should read hit on block 0 at time: %t", $time());
        error_count = error_count + 1;
        wait (Done_tb);
    end
    else begin
        $display ("Read hit on block 0 pass");
    end

    @(posedge Clock_tb);

// Demo a write miss:
    @(posedge Clock_tb);
    Wave_Message = "Basic Test: Expect Write Miss";
    word_addr_tb   = 0 ;
    group_addr_tb  = 1 ;
    MEM_in_tb = {tag_addr_tb, group_addr_tb, word_addr_tb};
    WR_tb = 1'd1;
    @(posedge Clock_tb);
    if(Done_tb) begin 
        $display ("Simulation failed, should write miss on block 1 at time: %t", $time());
        error_count = error_count + 1;
    end
    else begin
        $display ("write miss on block 1 pass");
        wait (Done_tb);
    end
    @(posedge Clock_tb);
    MEM_in_tb = 14'd0;
    WR_tb = 1'd0;
    @(posedge Clock_tb);

// Demo a write hit:
    @(posedge Clock_tb);
    Wave_Message = "Basic Test: Expect Write Hit";
    group_addr_tb  = 1 ;
    word_addr_tb = {word_addr_width{1'd1}};
    MEM_in_tb = {tag_addr_tb, group_addr_tb, word_addr_tb};
    WR_tb = 1'd1;
    @(posedge Clock_tb);
    if(!Done_tb) begin 
        $display ("Simulation failed, should write hit on block 1 at time: %t", $time());
        error_count = error_count + 1;
        wait (Done_tb);
    end
    else begin
        $display ("Write hit on block 1 pass");
    end
    @(posedge Clock_tb);
    MEM_in_tb = 14'd0;
    WR_tb = 1'd0;
    @(posedge Clock_tb);

// Start of Endurance test
    Wave_Message = "Endurance Test Start";
    @(posedge Clock_tb);
    $display ("\n\n------------------------------------------------------------");
    $display ("Start of Endurance Test Sequence:");
    $display ("------------------------------------------------------------");

// Fully populate cache with 'new' blocks -> should be all 'read miss'
    Wave_Message = "Endurance Test: Populating Cache New Blocks";
    $display ("Populating Cache with all new blocks:\n");
    @(posedge Clock_tb);
    for (i = 0; i < ((2**group_addr_width)); i = i + 1 )begin
        for (j = 0; j < ((2**set_addr_width)); j = j + 1 )begin
            tag_addr_tb    = j+1 ;
            group_addr_tb  = i ;
            word_addr_tb   = 0 ;
            @(posedge Clock_tb);
            if(Done_tb) begin 
                $display ("Simulation failed, should write miss on group %d, set %d at time: %t",i,j, $time());
                error_count = error_count + 1;
            end
            else begin
                wait (Done_tb);
                @(posedge Clock_tb);
            end
        end
    end

// Read/write to blocks in cache -> should be all 'hits'
    Wave_Message = "Endurance Test: Read & Write Expect All Hits";
    $display ("Reading and Writing to all blocks in cache, expect all hits:\n");
    @(posedge Clock_tb);
    for (i = 0; i < ((2**group_addr_width)); i = i + 1 )begin
        for (j = 0; j < ((2**set_addr_width)); j = j + 1 )begin
            tag_addr_tb    = j+1 ;
            group_addr_tb  = i ;
            word_addr_tb   = 0 ;
            MEM_in_tb = {tag_addr_tb, group_addr_tb, word_addr_tb};
            WR_tb = 1'd1;
            @(posedge Clock_tb);
            if(!Done_tb) begin 
                $display ("Simulation failed, should write hit on group %d, set %d at time: %t",i,j, $time());
                error_count = error_count + 1;
                wait (Done_tb);
                @(posedge Clock_tb);
            end
            word_addr_tb   = {word_addr_width{1'd1}};
            MEM_in_tb      = 0;
            WR_tb          = 1'd0;
            @(posedge Clock_tb);
            if(!Done_tb) begin 
                $display ("Simulation failed, should read hit on group %d, set %d at time: %t",i,j, $time());
                error_count = error_count + 1;
                wait (Done_tb);
                @(posedge Clock_tb);
            end
        end
    end

// Fully populate cache with 'new' blocks -> should be all 'miss with writeback'
    Wave_Message = "Endurance Test: Miss with Writeback";
    $display ("Populating Cache with all new blocks, writing back dirty blocks:\n");
    @(posedge Clock_tb);
    for (i = 0; i < ((2**group_addr_width)); i = i + 1 )begin
        for (j = 0; j < ((2**set_addr_width)); j = j + 1 )begin
            tag_addr_tb    = j+(2**set_addr_width)+1 ;
            group_addr_tb  = i ;
            word_addr_tb   = 0 ;
            @(posedge Clock_tb);
            if(Done_tb) begin 
                $display ("Simulation failed, should write miss on group %d, set %d at time: %t",i,j, $time());
                error_count = error_count + 1;
            end
            else begin
                wait (Done_tb);
                @(posedge Clock_tb);
            end
        end
    end

// Read back 'written to' blocks -> should be all 'miss'
    Wave_Message = "Endurance Test: Read Back Modified, Expecting Miss";
    $display ("Reading back 'written to' blocks, expect miss:\n");
    @(posedge Clock_tb);
    for (i = 0; i < ((2**group_addr_width)); i = i + 1 )begin
        for (j = 0; j < ((2**set_addr_width)); j = j + 1 )begin
            tag_addr_tb    = j+1 ;
            group_addr_tb  = i ;
            word_addr_tb   = 0 ;
            @(posedge Clock_tb);
            if(Done_tb) begin 
                $display ("Simulation failed, should write miss on group %d, set %d at time: %t",i,j, $time());
                error_count = error_count + 1;
            end
            else begin
                wait (Done_tb);
                @(posedge Clock_tb);
                if (MEM_out_tb != {tag_addr_tb, group_addr_tb, word_addr_tb}) begin
                    $display ("Simulation failed, should read data from write on group %d, set %d at time: %t",i,j, $time());
                    error_count = error_count + 1;
                end
            end

        end
    end

// Read back 'written to' blocks -> should be all 'hits'
    Wave_Message = "Endurance Test: Read Back Modified, Expecting Hit";
    $display ("Reading back 'written to' blocks, expect Hit:\n");
    @(posedge Clock_tb);
    for (i = 0; i < ((2**group_addr_width)); i = i + 1 )begin
        for (j = 0; j < ((2**set_addr_width)); j = j + 1 )begin
            tag_addr_tb    = j+1 ;
            group_addr_tb  = i ;
            word_addr_tb   = 0 ;
            @(posedge Clock_tb);
            if(!Done_tb) begin 
                $display ("Simulation failed, should write miss on group %d, set %d at time: %t",i,j, $time());
                error_count = error_count + 1;
                wait (Done_tb);
            end
            else if (MEM_out_tb != {tag_addr_tb, group_addr_tb, word_addr_tb}) begin
                $display ("Simulation failed, should read data from write on group %d, set %d at time: %t",i,j, $time());
                error_count = error_count + 1;
            end
        end
    end

    repeat (10) @(posedge Clock_tb);

// Random read/write test:
`ifdef random_test_enable
    $display ("\n\n------------------------------------------------------------");
    $display ("Random read/write test sequence enabled, running 20000 iterations");
    $display ("------------------------------------------------------------");
    Wave_Message = "Random Test Start";
    repeat (40000) apply_random_test();
`else
    $display ("\n\n------------------------------------------------------------");
    $display ("Random read/write test sequence disabled -> design verification is not done");
    $display ("------------------------------------------------------------");
`endif
    WR_tb          = 1'd0;
    check_memory_contents();
    if(error_count > 0) begin
        $display ("\n\n------------------------------------------------------------");
        $display ("Test sequence ended, review failures in waves");
    end
    else begin
        $display ("\n\n------------------------------------------------------------");
        $display ("Test sequence ended, no errors detected, note that DUT may still not be perfect");
    end
    $display ("Number of errors: %d",error_count);
    $display ("------------------------------------------------------------\n\n");
    $stop; // Normally we would use $finish, but modelsim prefers $stop
end


/**********************************************************************
*       Random Test Sequencer                                         *
**********************************************************************/
task apply_random_test;
// This task will do random reads/writes in an attempt to improve coverage and find any weird edge cases
begin
    @(posedge Clock_tb)
    tag_addr_tb    = $random;
    group_addr_tb  = $random;
    word_addr_tb   = $random;
    MEM_in_tb      = {tag_addr_tb, group_addr_tb, word_addr_tb};
    WR_tb          = $random;
    @(posedge Clock_tb);
    wait (Done_tb);
    @(posedge Clock_tb);
end
endtask
/*-------------------------------------------------------------------------------------------------------------------------------
// If I have a bug that only occurs 1 in 1000 times, I would need to run >> 1000 iterations of random tests in order to find it
// Snippet of code from the CAM:
    if (rd == 1) begin
        if ($random%1000 >= 998) dout = 0; // <- this is me injecting a weird code bug for an example of a 2 in 1000 error
        else dout = cam_mem[int_addrs];
// Resulting simulation output:
    # ------------------------------------------------------------
    # Start of Test Sequence:
    # Model check failed for address     6 expected data   503 recieved data     0
    # Model check failed for address     6 expected data   503 recieved data     0
    # Model check failed for address    13 expected data 11776 recieved data     0
    # Model check failed for address    13 expected data 11776 recieved data     0
    # Model check failed for address 15961 expected data     0 recieved data 15415
    # Model check failed for address 15961 expected data     0 recieved data 15415
    # Test sequence ended, check failed assertions
    # Number of failed assertions:           6
    # ------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------*/
task check_memory_contents;
begin
// We need to force the cache to writeback any blocks that might be dirty
// Fully populate cache with 'new' blocks
    Wave_Message = "Forcing Writeback for Memory Check";
    $display ("\n\n------------------------------------------------------------");
    $display ("Starting check of memory contents at end of test:");
    $display ("------------------------------------------------------------");
    $display ("Populating Cache with all new blocks, to force write back of dirty blocks:\n");
    @(posedge Clock_tb);
    for (i = 0; i < (2**address_width); i = i + 1 )begin
        {tag_addr_tb,group_addr_tb,word_addr_tb} = i;
        @(posedge Clock_tb);
        wait (Done_tb);
        @(posedge Clock_tb);
    end
    $display ("Comparing memory contents:\n");
    for(i=0;i<(2**address_width);i=i+1) begin
        if( mem_model.altsyncram_component.m_default.altsyncram_inst.mem_data[i] != 
            dut.main_mem.altsyncram_component.m_default.altsyncram_inst.mem_data[i] ) begin
            $display("Model check failed for address: %d, expected data: %d, recieved data: %d, at time: <EOT>", i, 
                mem_model.altsyncram_component.m_default.altsyncram_inst.mem_data[i], 
                dut.main_mem.altsyncram_component.m_default.altsyncram_inst.mem_data[i]);
            error_count = error_count + 1;
        end
    end
end
endtask
endmodule
