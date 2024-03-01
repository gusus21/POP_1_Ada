with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers.Generic_Array_Sort;

procedure Main is
   can_stop : Boolean := false;

   threads_count : Integer := 5;
   current_duration : Integer := 0;

   type Int_Array is array(1..threads_count) of Integer;
   threads_durations : Int_Array;

   pragma Atomic(can_stop);

   task type working_thread is
      entry Start(id, step, dur : in Integer);
   end;

   task type break_controller is
      entry Start(durations : in Int_Array);
   end;

   task body break_controller is
      durations : Int_Array;

      t : Integer;

   begin
      accept Start (durations : in Int_Array) do
         break_controller.durations := durations;
      end Start;

      for i in durations'Range loop
         if i > 1 then
            t := durations(i) - durations(i - 1);
         else
            t := durations(i);
         end if;
         delay duration(t);
         current_duration := durations(i);
      end loop;
   end break_controller;

   task body working_thread is
      sum : Long_Integer := 0;
      id : Integer;
      step : Integer;
      count : Integer := 0;
      dur : Integer;
   begin
      accept Start (id, step, dur : in Integer) do
         working_thread.id := id;
         working_thread.step := step;
         working_thread.dur := dur;
      end Start;

      loop
         sum := sum + Long_Integer(step);
         count := count + 1;
         exit when dur = current_duration;
      end loop;

      Put_Line(id'Img & " - " & sum'Img & ", count: " & count'Img);
   end working_thread;

   tasks : array(1..threads_count) of working_thread;

   -- Declare current_duration as a shared variable

   breaker : break_controller;
begin
   for i in 1..threads_count loop
      threads_durations(i) := i;
   end loop;

   breaker.Start(threads_durations);

   for i in tasks'range loop
      tasks(i).Start(i, 3, threads_durations(i));
   end loop;

end Main;
