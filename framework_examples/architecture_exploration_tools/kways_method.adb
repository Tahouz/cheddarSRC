with kl_partitioning;       use kl_partitioning;
with Text_IO;               use Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with unbounded_strings;     use unbounded_strings;
with Parameters;            use Parameters;
with Parameters.extended;   use Parameters.extended;
use Parameters.Framework_Parameters_Table_Package;
with systems;          use systems;
with framework;        use framework;
with GNAT.Command_Line;
with Ada.Command_Line; use Ada.Command_Line;
with debug;            use debug;
procedure kways_method is
   n, k, e, cut : Integer;
   costs        : matrice;
   graph_sys    : matrice;
   chromosome   : chrom_array;

   task_set_file_name : Unbounded_String;
   dir1               : unbounded_string_list;
   sys                : system;
   sys2               : system;
begin
   n                  := Integer'value (Argument (1));
   k                  := Integer'value (Argument (2));
   task_set_file_name := To_Unbounded_String (Argument (3));

   initialize (sys);
   read_from_xml_file (sys, dir1, task_set_file_name);

   for i in 1 .. n loop
      for j in 1 .. n loop
         costs (i, j) := 0;
      end loop;
      chromosome (i) := 0;
   end loop;

   --fill the graph
   e := genGraph (sys, graph_sys, k, n);
   put_debug ("nb_edges " & e'img);
   cut := kl (k, n, costs, graph_sys, chromosome);
   put_debug ("final cut " & cut'img);

end kways_method;
