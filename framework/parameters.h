/* ---------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Cheddar is a free real time scheduling tool.
-- This program provides services to automaticly check temporal constraints 
-- of real time tasks.
--
-- Copyright (C) 2002-2005   Frank Singhoff, Jerome Legrand
-- Cheddar is developped by the EA 2215 Team, University of Brest
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
-- Contact : F. Singhoff (singhoff@univ-brest.fr)
--           J. Legrand (jerome.legrand@univ-brest.fr)
------------------------------------------------------------------------------
--------------------------------------------------------------------------- */


#ifndef PARAMETERS_H
#define PARAMETERS_H

 	
   enum parameter_type
          {boolean_parameter, 
          integer_parameter, 
          double_parameter,  
          string_parameter}; 


  typedef struct parameter {
      int dummy;
   } parameter;

 
   void initialize_parameter(parameter* p);
   void put_parameter(parameter* p);
   void allocate_parameter(parameter* p, enum parameter_type t);
   
   void set_parameter_boolean_value(parameter* p, int value);
   void set_parameter_integer_value(parameter* p, int value);
   void set_parameter_double_value(parameter* p, double value);
   void set_parameter_string_value(parameter* p, char* value);

   int get_parameter_boolean_value(parameter* p);
   int get_parameter_integer_value(parameter* p);
   double get_parameter_double_value(parameter* p);
   char* get_parameter_string_value(parameter* p);



#endif

 
 
