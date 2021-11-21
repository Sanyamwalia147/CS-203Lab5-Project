// Code your design here
`timescale 1ns / 1ps
module parking_system( 
 input clk, reset_n,
 input sensor_entrance, sensor_exit, 
 input[1:0] password,
 output wire GREEN_LED, RED_LED, 
 output reg[2:0] state,
 output reg[3:0] number,
 output reg[9:0] fare
 );
 parameter IDLE = 3'b000, WAIT_PASSWORD=3'b001, WRONG_PASS=3'b010, RIGHT_PASS=3'b011, STOP = 3'b100;
 reg[2:0] current_state, next_state;
 //reg[31:0] counter_wait;
 reg red_tmp,green_tmp;
  
  initial begin
   current_state = IDLE;
   number=4'b0000;
   fare=10'b0000000000;
  end

  always @(posedge clk or posedge reset_n)
   begin
    if(reset_n)
     begin
      current_state = IDLE;
      number=4'b0000;
      fare=10'b0000000000;
     end
    else
     begin
      current_state = next_state;      
     end
   end
 
  /*always @(posedge clk or posedge reset_n) 
   begin
    if(reset_n) 
     counter_wait <= 0;
    else if(current_state==WAIT_PASSWORD)
     counter_wait <= counter_wait + 1;
    else 
     counter_wait <= 0;
   end*/
 
 //State Interconnections...
 always @(*)
   begin
    case(current_state)
     IDLE: 
       begin
        if(sensor_entrance==1 && sensor_exit==1)
 		 next_state = STOP;
   		else if(sensor_entrance==1)
 		 next_state = WAIT_PASSWORD;
   		else
     	 next_state = IDLE;
 	   end
     WAIT_PASSWORD: 
       begin
 		//if(counter_wait <= 3)
 		 //next_state = WAIT_PASSWORD;
 		//else 
 	    // begin
          if((password==2'b11))
		   next_state = RIGHT_PASS;
		  else
		   next_state = WRONG_PASS;
	     //end
	   end
 	 WRONG_PASS: 
       begin
        if(password==2'b11)
 		 next_state = RIGHT_PASS;
 		else
		 next_state = WRONG_PASS;
	   end
     RIGHT_PASS: 
       begin
		if(sensor_entrance==1 && sensor_exit==1)
		 next_state = STOP;
		else if(sensor_exit==1)
		 next_state = IDLE;
		else
		 next_state = RIGHT_PASS;
		end
     STOP: 
       begin
		 if(sensor_entrance==1 && sensor_exit==1)
		  next_state = STOP;
		 else
 		  next_state = WAIT_PASSWORD;
 	   end
     default: next_state = IDLE;
    endcase
   end
 
 //Description of States
 always @(posedge clk) 
   begin 
     case(current_state)
 	 IDLE: 
     begin
 	  green_tmp = 1'b0;
 	  red_tmp = 1'b0;
 	  state = 3'b000; 
       fare = fare + (number*(4'b1010));
     end
     WAIT_PASSWORD: 
     begin
	  green_tmp = 1'b0;
	  red_tmp = 1'b1;
	  state = 3'b001;
       fare = fare + (number*(4'b1010));
     end
	 WRONG_PASS: 
     begin
	  green_tmp = 1'b0;
	  red_tmp = ~red_tmp;
	  state = 3'b010;  
       fare = fare + (number*(4'b1010));
	 end
	 RIGHT_PASS: 
     begin
	  green_tmp = 1'b1;
	  red_tmp = 1'b0;
	  state = 3'b011;
      number = number+4'b0001;
       fare = fare + (number*(4'b1010));
	 end
     STOP: 
     begin
	  green_tmp = 1'b0;
	  red_tmp = 1'b1;
	  state = 3'b100; 
      fare = fare + (number*(4'b1010));
     end
   endcase
 end
 assign RED_LED = red_tmp;
 assign GREEN_LED = green_tmp;
  
endmodule