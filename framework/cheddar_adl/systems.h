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


#ifndef SYSTEMS_H
#define SYSTEMS_H


/* 'system' is a hiden type : we do not want show how it is built
    Only pointers are shared between the framework and C user's programs   */
        
   typedef struct system { 
   } system;      


 /* Initialise a system : 
   void initialize_system(system* s);


/* Allocate memory to store a system : should be called before
   every operations on a system */
   system* allocate_system();


/* Display on the screen the content of a system */
   void put_system(system* s);


/* Load a system description from a XML file */
   void read_from_xml_file(system* s, char* file_name);


/* Save a system in a XML file */
   void write_to_xml_file(system* s, char* file_name);


#endif









