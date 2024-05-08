'default_nettype none

module user_proj_example #(
    parameter BITS = 32
    parameter BASE Address = 32'h30000000,
) (
    'ifdef USE_POWER_PINS
        inout vccd1 ,
        inout vssd1,
    endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output reg wbs_ack_o,
    output reg [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [8:0] io_in,
    output [8:0] io_out,
    output [8:0] io_oeb,

    // IRQ
    output [2:0] irq        
);
    reg [7:0]a,b;
    wire [8:0]sum;
    
    wire [3:0] wsb;
    wire [9:0] rdata;

    assign io_out = sum;
  //  assign io_eb = {{9{1'b0}},{16{1'b1}}}
   assign io_eb = 9'd0;
    assign wsb = wbs_sel_i & {4{wbs_we_i}};
    assign wbs_dat_o = {{(23){1'b0}}, rdata};
    
//write
    always@(posedge wb_clk_i) begin
        if(wb_rst_i) begin
            wbs_ack_o <= 1'b0;
            {a,b} = 16'd0;
        end  else  begin
            wbs_ack_o = 1'b0;
            if (wbs_stb_i && wbs_cyc_i &&  wbs_we_i && !wbs_ack_o && wbs_adr_i == BASE Address) begin
                wbs_ack_o=1'b1;
                if(wsb[0]) a = wbs_dat_i[7:0];
                if(wsb[1]) b = wbs_dat_i[15:8];
            end
    end
    end
//read
    always@(posedge wb_clk_i) begin
            if(wb_rst_i) wbs_ack_o <= 0;

            else  begin
                wbs_ack_o = 1'b0;
                if(wbs_cyc_i && wbs_stb_i && !wbs_ack_o && wbs_adr_i = BASE Address)
                    wbs_ack_o = 1'b1;
                    wbs_dat_o  = {{23'd0},sum};                
            end

    end


    adder uut(wb_clk_i,wb_rst_i,a,b,sum[7:0],sum[8]);

endmodule


module adder (
    clk,rst,a,b,cin,sum,cout
);

    input clk;
    input rst;
    input [7:0]a;
    input [7:0]b;
    
    output reg [7:0]sum;
    output reg cout;

    always@(posedge clk or posedge rst) begin
        {cout,sum} = a + b ;

    end

    
endmodule
