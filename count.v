module count
#(
    parameter NB_SW = 3,
    parameter NB_COUNTER = 32


)
(
    output             o_valid,

    input [NB_SW -1:0] i_sw,
    input              i_reset,
    input              clock


);

// Local parameters
    localparam R0 = (2**(NB_COUNTER - 10))-1;
    localparam R1 = (2**(NB_COUNTER -  9))-1; 
    localparam R2 = (2**(NB_COUNTER -  8))-1;
    localparam R3 = (2**(NB_COUNTER -  7))-1;




    wire [NB_COUNTER-1: 0] limit_sh;
    reg [NB_COUNTER-1: 0] counter;
    reg                  valid; 
    assign limit_sh =   (i_sw[2:1] == 2'b00)? R0:
                        (i_sw[2:1] == 2'b01)? R1:
                        (i_sw[2:1] == 2'b10)? R2: R3;



    always @(posedge clock or posedge i_reset) begin
        if (i_reset) begin
            counter <= {NB_COUNTER{1'b0}};
            valid <= 1'b0;
        end
        else if (i_sw[0]) begin
            
            if (counter >= limit_sh) begin
                counter <= {NB_COUNTER{1'b0}};
                valid <= 1'b1;
            end
            else begin
                counter <= counter + 1;
                valid <= 1'b0;
            end

        end
        else begin
            counter <= counter;
            valid <= valid;
        end
        
    end

    assign o_valid = valid;

endmodule