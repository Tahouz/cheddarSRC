
------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Cheddar is a GNU GPL real-time scheduling analysis tool.
-- This program provides services to automatically check schedulability and
-- other performance criteria of real-time architecture models.
--
-- Copyright (C) 2002-2023, Frank Singhoff, Alain Plantec, Jerome Legrand,
--                          Hai Nam Tran, Stephane Rubini
--
-- The Cheddar project was started in 2002 by 
-- Frank Singhoff, Lab-STICC UMR CNRS 6285, Universite de Bretagne Occidentale
-- 
-- Cheddar has been published in the "Agence de Protection des Programmes/France" in 2008. 
-- Since 2008, Ellidiss technologies also contributes to the development of 
-- Cheddar and provides industrial support.
--
-- The full list of contributors and sponsors can be found in README.md
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
--
--
-- Contact : cheddar@listes.univ-brest.fr
--           
------------------------------------------------------------------------------
-- Last update : 
--    $Rev: 1249 $
--    $Date: 2014-08-28 07:02:15 +0200 (Fri, 28 Aug 2014) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Text_IO; use Ada.Text_IO;

with Gtk;                               use Gtk;
with Gtk.Main;                          use Gtk.Main;
with Glib.Error;                        use Glib.Error;
with Gtk.Widget;                        use Gtk.Widget;
with Gtk.Window;                        use Gtk.Window;
with Gtkada.Dialogs;                    use Gtkada.Dialogs;
with Gtkada.Builder;                    use Gtkada.Builder;
with Glib; use Glib;
with Glib.Error;
with Glib.Object; use Glib.Object;
with Gtk.Drawing_Area;    use Gtk.Drawing_Area;
with Gtkada.Handlers;  use Gtkada.Handlers;
with Gdk.Event;        use Gdk.Event;

with simple_cairo; use simple_cairo;


procedure test_cairo1 is 



   builder           : gtkada_builder;
   error             : aliased Glib.Error.gerror;
   diag              : guint;

begin

   Gtk.Main.Init;
   Gtk_New (builder);
   diag := Add_From_File (builder, "test_cairo.glade", error'access);
   if diag = 0 then
      Ada.Text_IO.Put_Line ("Error : " & Get_Message (error));
      Error_Free (Error);
      return;
   end if;

   Win_Widget :=
     Gtk.Widget.Gtk_Widget (Get_Object (Builder, "window1"));
   Area_Widget :=
     Gtk_Drawing_Area (Get_Object (Builder, "drawingarea1"));

   Area_Widget.Set_Size_Request (500, 500);

   Area_Widget.On_Draw (draw_cb'Access);
   Area_Widget.On_Configure_Event (configure_event_cb'Access);
   Area_Widget.On_Button_Press_Event (button_press_event_cb'Access);
   Area_Widget.Set_Events (Area_Widget.Get_Events or Button_Press_Mask or Pointer_Motion_Mask);



   Do_Connect (builder);


   Gtk.Widget.Show_All (Win_Widget);

   Gtk.Main.Main;


end test_cairo1;



