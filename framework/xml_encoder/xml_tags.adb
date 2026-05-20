with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
package body xml_tags is
   procedure wrapContent(Content :in out Unbounded_String) is 
   S_Tag_Name :Unbounded_String := To_Unbounded_String ("<")&Tag_Name & To_Unbounded_String (">");
   E_Tag_Name :Unbounded_String := To_Unbounded_String ("</")&Tag_Name & To_Unbounded_String (">");
   begin
   Content :=
   S_Tag_Name &
   Content &
   E_Tag_Name; 
   end;

end xml_tags;