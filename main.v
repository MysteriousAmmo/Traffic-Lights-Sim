`timescale 1ns 

module clock_gen(output wire clk_out);
    reg clk;
    initial begin
        clk = 0;
        forever 
            #500 clk = ~clk;
    end

    assign clk_out = clk;

endmodule 
//clock generates 1mhz output when using 1nano second timescale. 



module divide_by_million(input wire clk, output wire out);
    reg [19:0] count; 
    reg clk_out; 
    initial begin
        count = 0; 
        clk_out = 0; 
    end

    always @(posedge clk) begin 
        if (count == 999_999) begin 
            count = 0;
            clk_out = ~clk_out; 
        end else begin
            count = count + 1;
        end
    end

    assign out = (count == 999_999);
endmodule
//getting a 1 second pulse


module control(input wire timer, 
               output wire [1:0] road1_state, road2_state, road3_state, road4_state); 

    reg [7:0] count;  
    reg [1:0] Road1_state, Road2_state, Road3_state, Road4_state;

    localparam GREEN = 2'b11;
    localparam YELLOW = 2'b10;
    localparam RED = 2'b01;

    localparam GREEN_PERIOD = 10;
    localparam YELLOW_PERIOD = 2;  

    initial begin
        count = 0; 
        Road1_state = GREEN; 
        Road2_state = RED;
        Road3_state = RED;
        Road4_state = RED;
    end

    always @(posedge timer) begin
        count <= count + 1;

        case (count)
            GREEN_PERIOD - 1: begin
                Road1_state <= YELLOW;
            end
            GREEN_PERIOD + YELLOW_PERIOD - 1: begin
                Road1_state <= RED;
                Road2_state <= GREEN;
            end
            2 * GREEN_PERIOD + YELLOW_PERIOD - 1: begin
                Road2_state <= YELLOW;
            end
            2 * GREEN_PERIOD + 2 * YELLOW_PERIOD - 1: begin
                Road2_state <= RED;
                Road3_state <= GREEN;
            end
            3 * GREEN_PERIOD + YELLOW_PERIOD - 1: begin
                Road3_state <= YELLOW;
            end
            3 * GREEN_PERIOD + 2 * YELLOW_PERIOD - 1: begin
                Road3_state <= RED;
                Road4_state <= GREEN;
            end
            4 * GREEN_PERIOD + 2 * YELLOW_PERIOD - 1: begin
                Road4_state <= YELLOW;
            end
            4 * GREEN_PERIOD + 3 * YELLOW_PERIOD - 1: begin
                Road4_state <= RED;
                Road1_state <= GREEN;
                count <= 0;
            end
        endcase
    end

    assign road1_state = Road1_state;
    assign road2_state = Road2_state;
    assign road3_state = Road3_state;
    assign road4_state = Road4_state;
    
endmodule

module lightOut(input wire [1:0] state, output wire red, yellow, green); 
    assign red = state == 2'b01; 
    assign yellow = state == 2'b10; 
    assign green = state == 2'b11;
endmodule

module main(output wire red1, yellow1, green1, red2, yellow2, green2, red3, yellow3, green3, red4, yellow4, green4); 

    wire clk;
    wire timer;
    wire [1:0] road1_state, road2_state, road3_state, road4_state;

    clock_gen cg(clk);
    divide_by_million d(clk, timer);

    control c(timer, road1_state, road2_state, road3_state, road4_state);
    
    lightOut l1(road1_state, red1, yellow1, green1); 
    lightOut l2(road2_state, red2, yellow2, green2); 
    lightOut l3(road3_state, red3, yellow3, green3); 
    lightOut l4(road4_state, red4, yellow4, green4); 

endmodule

module testbench;
    wire red1, yellow1, green1, red2, yellow2, green2, red3, yellow3, green3, red4, yellow4, green4;

    main uut (
        .red1(red1),
        .yellow1(yellow1),
        .green1(green1),
        .red2(red2),
        .yellow2(yellow2),
        .green2(green2),
        .red3(red3),
        .yellow3(yellow3),
        .green3(green3),
        .red4(red4),
        .yellow4(yellow4),
        .green4(green4)
    );

    initial begin
        $monitor("Time: %0d, red1: %b, yellow1: %b, green1: %b, red2: %b, yellow2: %b, green2: %b, red3: %b, yellow3: %b, green3: %b, red4: %b, yellow4: %b, green4: %b", 
                 $time, red1, yellow1, green1, red2, yellow2, green2, red3, yellow3, green3, red4, yellow4, green4);

        $display("Starting simulation...");

        $dumpfile("test.vcd");
        $dumpvars(0, testbench);
 
        #120000000000 $finish; 
    end
endmodule