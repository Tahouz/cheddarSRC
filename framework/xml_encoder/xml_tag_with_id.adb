with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
package body xml_tag_with_id is
   procedure wrapContent_withID(Content :in out Unbounded_String ; Id : Unbounded_String) is 
   S_Tag_Name :Unbounded_String := To_Unbounded_String ("<")&Tag_Name & To_Unbounded_String (" ")& Id_Name& To_Unbounded_String ("=""")& Id & To_Unbounded_String ("""")  &To_Unbounded_String (">");
   E_Tag_Name :Unbounded_String := To_Unbounded_String ("</")&Tag_Name & To_Unbounded_String (">");
   begin
   Content :=
   S_Tag_Name &
   Content &
   E_Tag_Name;
   end;

end xml_tag_with_id;