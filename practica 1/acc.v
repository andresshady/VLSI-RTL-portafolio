module acc 
(
    input  [2:0]     i_data1,
    input  [2:0]     i_data2,
    input  [1:0]     i_sel,
    input            clk,
    input            i_rst_n,

    output           o_overflow,
    output [5:0]     o_data

);


// systems internal variables

wire [3:0]    o_add1;
wire [6:0]    o_add2;
wire [3:0]    mux_result;
reg  [3:0]    o_mux;
reg  [6:0]    o_reg;



//sum1 behavioral
assign o_add1 = i_data1 + i_data2;

//mux behavioral
always @(*) begin
    case (i_sel)
        2'b00: o_mux = {1'b0, i_data2};
        2'b01: o_mux = o_add1;
        2'b10: o_mux = {1'b0, i_data1};
        default: o_mux = 4'b0000;
    endcase
end
assign mux_result = o_mux;


//sum2 behavioral
assign o_add2 = mux_result + o_reg[5:0];


//register behavioral
always @(posedge clk or negedge i_rst_n) begin

    if(!i_rst_n) begin
        o_reg <= 7'b0;
    end 
    else begin
        o_reg <= o_add2;
    end


end

assign o_data = o_reg[5:0];
assign o_overflow = o_reg[6];

endmodule