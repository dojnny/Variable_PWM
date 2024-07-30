// Custom Module

module Pwm_In
    #(parameter R = 8, TimerBits = 15)(
    input clk,
    input reset_n,
    input [R:0] duty, // Control the Duty Cycle
    input [TimerBits - 1:0] Final_Value, // Control the switching frequency
    output pwm_out
    );

    reg [R:0] duty_reg;
    reg [R - 1:0] Q_Next, Q_Reg;
    reg D_Reg;
    reg D_Next;
    wire step;

    // Up Counter 
    always @(posedge clk or negedge reset_n)
    begin
        if (!reset_n) // NB: ~ is bitswise negation, ! is boolean inversion.
        begin
        	Q_Reg <= {R{1'b1}}; // first run of timer starts at 0 which isn't taking new duty cycle value until complete value of timer done
            //Q_Reg <= 'b0;
            D_Reg <= 1'b0;
            duty_reg <= 'b0;
        end
        else
        begin
            if (step)
            begin
                Q_Reg <= Q_Next;
                D_Reg <= D_Next;
            end
            else
            begin
                Q_Reg <= Q_Reg;
                D_Reg <= D_Reg;
            end

            if ((Q_Next == 0) && step) // Test if the counter would overflow in this cycle, and we're being asked to update the counter
                duty_reg <= duty; // load new duty
            else
                duty_reg <= duty_reg;
        end
    end

    // Next state logic
    always @*
    begin
        Q_Next = Q_Reg + 1;
        D_Next = (Q_Reg < duty_reg);
    end
    
    assign pwm_out = D_Reg;

    // Prescalar Timer
    Timer_In #(.Bits(TimerBits)) timer0 (
        .clk(clk),
        .reset_n(reset_n),
        .enable(1'b1),
        .Final_Value(Final_Value),
        .done(step)
    );

endmodule

   
