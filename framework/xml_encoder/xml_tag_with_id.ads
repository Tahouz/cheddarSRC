with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
generic
   Tag_Name : Unbounded_String;
   Id_Name : Unbounded_String ;
package xml_tag_with_id is
   
   procedure wrapContent_withID(Content :in out Unbounded_String;Id :Unbounded_String);

end xml_tag_with_id;