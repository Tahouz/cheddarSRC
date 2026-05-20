
with Glib;       use Glib;
with Gdk.Types;  use Gdk.Types;
with Gdk.Window;
with Gtk.Main;
with Cairo; use Cairo;


package body simple_cairo is


   surface : Cairo_Surface;

   procedure draw
     (Self : access Gtk_Widget_Record'Class)
   is
      Cr : Cairo_Context;
   begin
      Cr := Create (surface);

      --Scale(Cr, 0.75, 0.75);
      --Scale(Cr, 2.0, 2.0);

      Set_Source_rgb(Cr, 1.0, 0.0, 0.0);
      Rectangle (Cr, 10.0, 10.0, 50.0, 50.0);
      Stroke (Cr);

      Set_Source_rgb (Cr, 0.0, 0.0, 1.0);
      Rectangle (Cr, 50.0, 50.0, 100.0, 100.0);
      Fill(Cr);

      Move_To (Cr, 150.0, 150.0);
      Line_To (Cr, 250.0, 250.0);
      Stroke (Cr);

      Set_Source_rgb(Cr, 1.0, 1.0, 0.0);
      Move_To (Cr, 0.0, 250.0);
      Line_To (Cr, 500.0, 250.0);
      Stroke (Cr);

      Set_Source_rgb(Cr, 0.0, 0.0, 0.0);
      Move_To (Cr, 0.0, 300.0);
      Show_Text(Cr, "First sentence to show");
      Set_Source_rgb(Cr, 0.5, 0.5, 0.5);
      Move_To (Cr, 0.0, 320.0);
      Show_Text(Cr, "Second sentence to show");
      Set_Source_rgb(Cr, 0.25, 0.25, 0.25);
      Move_To (Cr, 0.0, 340.0);
      Show_Text(Cr, "Third sentence to show");
      Stroke (Cr);

      Destroy (Cr);

      Self.Queue_Draw_Area (0, 0, 500, 500);
   end draw;


   procedure Clear_Surface is
      Cr : Cairo.Cairo_Context;
   begin
      Cr := Cairo.Create (surface);
      Cairo.Set_Source_Rgb (Cr, 1.0, 1.0, 1.0);
      Cairo.Paint (Cr);
      Cairo.Destroy (Cr);
   end Clear_Surface;


   function draw_cb
     (Self : access Gtk_Widget_Record'Class;
      Cr   : Cairo.Cairo_Context)
      return Boolean
   is
   begin
      Cairo.Set_Source_Surface (Cr, surface, 0.0, 0.0);
      Cairo.Paint (Cr);
      return False;
   end draw_cb;


   function configure_event_cb
     (Self  : access Gtk_Widget_Record'Class;
      Event : Gdk.Event.Gdk_Event_Configure)
      return  Boolean
   is
   begin
      surface :=
         Gdk.Window.Create_Similar_Surface
           (Self.Get_Window,
            Cairo.Cairo_Content_Color,
            Self.Get_Allocated_Width,
            Self.Get_Allocated_Height);
      Clear_Surface;

      return True;
   end configure_event_cb;


   function button_press_event_cb
     (Self  : access Gtk_Widget_Record'Class;
      Event : Gdk.Event.Gdk_Event_Button)
      return  Boolean
   is
   begin
      draw (Self);
      return True;
   end button_press_event_cb;


end simple_cairo;




