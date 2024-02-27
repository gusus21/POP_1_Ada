with Ada.Text_IO; use Ada.Text_IO;

procedure Main is
   can_stop : Boolean := false;

   threads_count : Integer := 5;

   pragma Atomic(can_stop);

   task type working_thread is
      entry Start(id, step : in Integer);
   end;

   task type break_controller;


   task body break_controller is
   begin
         delay 10.0;
         can_stop := True;
   end break_controller;


   task body working_thread is
      sum : Long_Integer := 0;
      id : Integer;
      step : Integer;
      count : Integer := 0;
   begin
      accept Start (id, step : in Integer) do
         working_thread.id := id;
         working_thread.step :=step;
      end Start;
      loop
         sum := sum + Long_Integer(step);
         count := count+1;
         exit when can_stop;
      end loop;
      delay 1.0;
      Put_Line(id'Img & " - " & sum'Img & ", count: " & count'Img);
   end working_thread;

   tasks : array(1..threads_count) of working_thread;

   breaker : break_controller;
begin
   for i in tasks'range loop
      tasks(i).Start(i, 3);
   end loop;

end Main;
