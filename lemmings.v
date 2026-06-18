module top_module(
    input clk,
    input areset,    // Freshly brainwashed Lemmings walk left.
    input bump_left,
    input bump_right,
    input ground,
    input dig,
    output walk_left,
    output walk_right,
    output aaah,
    output digging ); 
    
    
    parameter left=0,right=1,fall_l=2,fall_r=3,dig_l=4,dig_r=5,die=6;
    
    reg [2:0] state,next_state;
    reg [9:0] count = 5'd0;
    
    always@(*)begin       
        case(state)
            left[2:0] : next_state = ground ? (dig ? dig_l[2:0] : (bump_left ? right[2:0] : left[2:0] )) : fall_l[2:0];
            right[2:0] : next_state = ground ? (dig ? dig_r[2:0] : (bump_right ? left[2:0] : right[2:0] )) : fall_r[2:0];
            fall_l[2:0] : next_state = ground ? (count >= 5'd20 ? die[2:0] : left[2:0]) : fall_l[2:0];
            fall_r[2:0] : next_state = ground ? (count >= 5'd20 ? die[2:0] : right[2:0]) : fall_r[2:0];
            dig_l[2:0] : next_state = ground ? dig_l[2:0] : fall_l[2:0];
            dig_r[2:0] : next_state = ground ? dig_r[2:0] : fall_r[2:0];
            die[2:0] : next_state = die[2:0] ;
        endcase
    end
    
    always@(posedge clk,posedge areset)
        begin
            if(areset)
                state <= left[2:0];
            else
                state <= next_state;
        end
    
    
    always@(posedge clk,posedge areset)
        begin
            if(areset)
                count <= 5'd0;
            else if(state == fall_l || state == fall_r)
                count <= count + 5'd1 ;
            else 
                count <= 5'd0;
        end
            
    
    assign walk_left =(~(state == die) && (state == left));
    assign walk_right =(~(state == die) && (state == right));
    assign aaah = (~(state == die) && ((state == fall_l) || (state == fall_r)));
    assign digging = (~(state == die) && ((state == dig_l) || (state == dig_r)));

endmodule
