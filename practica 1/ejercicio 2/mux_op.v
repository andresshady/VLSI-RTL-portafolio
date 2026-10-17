module mux_op
(
    input  [15:0]     i_dataA,
    input  [15:0]     i_dataB,
    input  [1:0]     i_sel,

    output [15:0]    o_dataC


);



// systems internal variables

wire [15:0]    add;
wire [15:0]    sub;
wire [15:0]    and_op;
wire [15:0]    or_op;
reg  [15:0]    o_mux;


assign add = i_dataA + i_dataB;
assign sub = i_dataA - i_dataB;
assign and_op = i_dataA & i_dataB;
assign or_op = i_dataA | i_dataB;


always @(*) begin
    case (i_sel)
        2'b00: o_mux = add;
        2'b01: o_mux = sub;
        2'b10: o_mux = and_op;
        2'b11: o_mux = or_op;
        default: o_mux = 16'b0000_0000_0000_0000;
    endcase
end

    assign o_dataC = o_mux;




endmodule