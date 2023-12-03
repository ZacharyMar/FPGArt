module memory_controller(
    iClk, 
    iData, 
    iAddress, 
    iWren, 
    iChipSelect, 
    oQ
    );

    input wire iClk, iChipSelect, iWren;
    input wire [2:0] iData;
    input wire [14:0] iAddress;
    output reg [2:0] oQ;
    /*
     Expansion for more RAM instantiations:
     1. Allow for more chip select options
     2. Create separate signals for each memory module with wren
        - Wren is assigned to 0 if not selected, wren assigned to input iWren if selected
     3. Assert each wren to each memory block
     4. To determine output to choose, use case statement (combinational) as below
     */
    wire q0, q1;
    // reg wren0, wren1, wren2;

    // always@(*)
    //     begin
    //         case(iChipSelect)
    //         2'd0:
    //             begin
    //                 wren0 = iWren;
    //                 wren1 = 0;
    //                 wren2 = 0;
    //             end
    //     end
    
    BRAM1 m0 (
        .address(iAddress),
        .clock(iClk),
        .data(iData),
        .wren(iChipSelect? 0:iWren),
	    .q(q0)
    );

    BRAM1 m1(
        .address(iAddress),
	    .clock(iClk),
	    .data(iData),
	    .wren(iChipSelect? iWren: 0),
	    .q(q1)
    );
    
    always@(*)
        begin
            if (iChipSelect) oQ = q1;
            else oQ = q0;
        end

endmodule