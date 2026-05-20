with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
generic
   Tag_Name : Unbounded_String;
package xml_tags is
   procedure wrapContent(Content :in out Unbounded_String);
end xml_tags;