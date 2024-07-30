// Custom Module

module Pwm_In
    #(parameter R = 8, TimerBits = 15)(
    input clk,
    input reset_n,
    input [R:0] duty, // Control the Duty Cylce
    input [TimerBits - 1:0] Final_Value, // Control the switching frequency
    output pwm_out
    );
    
    
    reg [R - 1:0] Q_Reg, Q_Next;
    reg D_Reg, D_Next;
    wire done;
    
    // Up Counter 
    always @(posedge clk, negedge reset_n)
    begin
        if (~reset_n)
        begin
            Q_Reg <= 'b0;
            D_Reg <= 1'b0;
        end
        else if (done)
        begin
            Q_Reg <= Q_Next;
            D_Reg <= D_Next;
        end
        else
        begin
            Q_Reg <= Q_Reg;
            D_Reg <= D_Reg;
        end                  
    end
    
    // Next state logic
    always @(Q_Reg, duty)
    begin
        Q_Next = Q_Reg + 1;
        D_Next = (Q_Reg < duty);
    end
    
    assign pwm_out = D_Reg;
    
    // Prescalar Timer

    Timer_In #(.Bits(TimerBits)) timer0 (
        .clk(clk),
        .reset_n(reset_n),
        .enable(1'b1),
        .Final_Value(Final_Value),
        .done(done)
    );
    
        
endmodule