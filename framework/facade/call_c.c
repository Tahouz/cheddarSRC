/* ---------------------------------------------------------------------------
------------------------------------------------------------------------------
-- Cheddar is a real time simulator mainly designed for educational purpose. 
-- This program provides services to automaticly check temporal constraints 
-- of real time tasks.
--
-- Copyright (C) 2002   Frank Singhoff, Jerome Legrand
-- Cheddar is developped by the LIMI Team/EA 2215, University of Brest
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
---------------------------------------------------------------------------- */


#include "systems.h"
#include "call_framework.h"



extern void adainit( void );
extern void adafinal( void );



system* sys;
framework_request a_request;
framework_request_table request_list;
framework_response_table response_list;


int main( int argc, char *argv[]) {

 
   adainit();

printf("p1\n");
   /* Allocating a system */
   sys=allocate_system();

printf("p2\n");
   initialize_system(sys);
   
printf("p3\n");
   /* Reading the file */
   read_from_xml_file(sys, "call_framework.xml");


printf("p4\n");

   /*  Call the framework  */
   initialize_request(&a_request);
   initialize_request_table(&request_list);
   initialize_response_table(&response_list);

printf("p5\n");
   a_request.statement=scheduling_feasibility_basics;
printf("p6\n");
   put_request(&a_request);
printf("p7\n");
  put_response_table(&response_list);
printf("p8\n");

printf("p9\n");
   add_request(&request_list, &a_request);
printf("p10\n");
  put_request_table(&request_list);
printf("p11\n");
   sequential_framework_request (
      sys, &request_list, &response_list, total_order, xml_output);
printf("p12\n");


   /* Display the result */
   put_response_table(&response_list);
 
printf("p13\n");

   adafinal();
 
printf("p14\n");

  return 0;
}

