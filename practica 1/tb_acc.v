`timescale 1ns/100ps

module tb_acc ();

    reg [2:0]     i_data1;
    reg [2:0]     i_data2;
    reg [1:0]     i_sel;
    reg          clk;
    reg          i_rst_n;
    wire           o_overflow;
    wire [5:0]     o_data;




    initial begin
        clk = 1'b0;
        i_data1 = 3'b000;
        i_data2 = 3'b000;
        i_sel = 2'b00;
        i_rst_n = 1'b1;



        // espero 5 ciclos de reloj
        #50;
        @(negedge clk);
        i_data1 = 3'd1;
        i_data2 = 3'd0;
        i_sel = 2'b00;
        i_rst_n = 1'b0;


        #50;
        @(negedge clk);
        i_data1 = 3'd1;
        i_data2 = 3'd1;
        i_sel = 2'b00;
        i_rst_n = 1'b1;
        
         #50;
        @(negedge clk);
        i_data1 = 3'd1;
        i_data2 = 3'd1;
        i_sel = 2'b00;
        i_rst_n = 1'b0;
        
           #50;
        @(negedge clk);
        i_data1 = 3'd0;
        i_data2 = 3'd2;
        i_sel = 2'b00;
        i_rst_n = 1'b1;
        
         #50;
        @(negedge clk);
        i_data1 = 3'd5;
        i_data2 = 3'd5;
        i_sel = 2'b01;
        i_rst_n = 1'b0;
        
         #50;
        @(negedge clk);
        i_data1 = 3'd5;
        i_data2 = 3'd5;
        i_sel = 2'b01;
        i_rst_n = 1'b1;
        
         #50;
        @(negedge clk);
        i_data1 = 3'd5;
        i_data2 = 3'd5;
        i_sel = 2'b10;
        i_rst_n = 1'b0;
        
         #50;
        @(negedge clk);
        i_data1 = 3'd5;
        i_data2 = 3'd5;
        i_sel = 2'b10;
        i_rst_n = 1'b1;
        
        
         #100;
        @(negedge clk);
        i_data1 = 3'd1;
        i_data2 = 3'd1;
        i_sel = 2'b01;
        i_rst_n = 1'b0;
        
         #100;
        @(negedge clk);
        i_data1 = 3'd1;
        i_data2 = 3'd1;
        i_sel = 2'b01;
        i_rst_n = 1'b1;
        
         #50;
        @(negedge clk);
        i_data1 = 3'd5;
        i_data2 = 3'd5;
        i_sel = 2'b11;
        i_rst_n = 1'b0;
        
         #50;
        @(negedge clk);
        i_data1 = 3'd5;
        i_data2 = 3'd5;
        i_sel = 2'b11;
        i_rst_n = 1'b1;



    end    
    always #5 clk = ~clk;
    
    
    
acc
u_acc
(
    .i_data1 (i_data1),
    .i_data2 (i_data2),
    .i_sel   (i_sel),
    .clk     (clk),
    .i_rst_n (i_rst_n),
    .o_overflow (o_overflow),
    .o_data     (o_data)

);
    
    // para respodner la pregunta 4 se necesitan 32 ciclos de reloj para disparar el overflow en ese escenario.
   
    
    
    
    
    
    
endmodule