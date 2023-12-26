module InterruptRequestRegister(

    // inputs from control logic
    input level_or_edge_triggered_mode,
    input [7:0] clear_ir_line,
    input freeze,

    // input from I/O devices
    input reg [7:0] ir_req_pin,

    // output
    output wire [7:0] interrupt_req_reg
);
    reg [7:0] ir_req_edge;
    reg [7:0] delayed_ir_req_line;

    genvar ir_bit_no;
    generate
    for(ir_bit_no = 0; ir_bit_no < 8; ir_bit_no = ir_bit_no + 1) begin
        // (Positive) Edge triggered
        always@(ir_req_pin[ir_bit_no], posedge clear_ir_line[ir_bit_no]) begin
            if(clear_ir_line[ir_bit_no]) begin
                delayed_ir_req_line[ir_bit_no] <= 1'b0;
                ir_req_edge[ir_bit_no] <= 1'b0;
              end
            else if(ir_req_pin[ir_bit_no] == 1'b1) begin
                delayed_ir_req_line[ir_bit_no] <= 1'b1;
                ir_req_edge[ir_bit_no] <= (ir_req_pin[ir_bit_no] == 1'b1) & (~delayed_ir_req_line[ir_bit_no] == 1'b1);
              end
            else begin
                delayed_ir_req_line[ir_bit_no] <= delayed_ir_req_line[ir_bit_no];
              end
               end
       
        assign  interrupt_req_reg[ir_bit_no] = (clear_ir_line[ir_bit_no] == 1'b1) ? (1'b0)
                                             : (freeze) ? (interrupt_req_reg[ir_bit_no])
                                             : (level_or_edge_triggered_mode == 1'b0) ? (ir_req_edge[ir_bit_no])
                                             : (ir_req_pin[ir_bit_no]);
                                       
    end
    endgenerate 
endmodule   





