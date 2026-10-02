
module shiftreg 
#(
    parameter NB_LED = 4

)
(
    output [NB_LED -1:0] o_led,
    input        i_valid,
    input        i_reset,
    input        clock
);

    reg [NB_LED -1:0] shiftreg;
    integer            ptr;

    always @(posedge clock) begin
        if(i_reset) begin
            shiftreg <= {{NB_LED-1{1'b0}},1'b1};
        end

        else if (i_valid) begin
            //option 1
        //   shiftreg[1] <= shiftreg[0];
        //   shiftreg[2] <= shiftreg[1];
        //   shiftreg[3] <= shiftreg[2];
        //   shiftreg[0] <= shiftreg[3]; 


        //   //option 2

        //   shiftreg <= shiftreg << 1;
        //   shiftreg[0] <= shiftreg[3];

        //   // opcion 3
        //   for(ptr = 0; ptr < NB_LED -1;ptr = ptr+1)begin:sh
        //       shiftreg[ptr+1] <= shiftreg[ptr];
        //       
        //   end
        //   shiftreg[0] <= shiftreg[NB_LED-1];

            //opcion 4

                shiftreg <= {shiftreg[NB_LED-2:0], shiftreg[NB_LED-1]};

        end
        else begin
            shiftreg <= shiftreg;
        end
        
    end

    assign o_led = shiftreg;
    
endmodule