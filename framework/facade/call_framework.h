/*
------------------------------------------------------------------------------
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


#ifndef CALL_FRAMEWORK_H
#define CALL_FRAMEWORK_H

#include "config.h"
#include "parameters.h"
#include "systems.h"




   typedef enum 
         {scheduling_simulation_basics,                              
          scheduling_simulation_time_line,                           
          scheduling_simulation_preemption_number,                   
          scheduling_simulation_response_time,                       
          scheduling_feasibility_response_time,                      
          scheduling_feasibility_basics,                             
          scheduling_set_priorities_according_to_deadline_monotonic, 
          scheduling_set_priorities_according_to_rate_monotonic,     
          buffer_bound,                                              
          buffer_utilization,                                        
          resource_blocking_time,                                    
          random_response_time_density,                              
          dependency_compute_end_to_end_response_time_one_step,      
          dependency_set_end_to_end_response_time_one_step,          
          dependency_compute_end_to_end_response_time,               
          dependency_set_end_to_end_response_time,                   
          dependency_compute_chetto_blazewicz_priority,              
          dependency_compute_chetto_blazewicz_deadline,              
          dependency_set_chetto_blazewicz_priority,                  
          dependency_set_chetto_blazewicz_deadline} framework_statement_type; 


 
  

   /* Store a computing request. 
      If "target" contains something, the computing should only
      done on one processor which is referecendd in "target"
      if "target" is a empty string, we compute for all processors
   */
   
   
   typedef struct framework_request {
        framework_statement_type statement;
	parameter* param;
        char target[MAX_STRING]; 
   } framework_request;

  
   void put_request (framework_request* request);
   void initialize_request(framework_request* request);


   typedef struct framework_request_table {
         int nb_entries;
         framework_request entries[MAX_REQUEST];
   } framework_request_table;

   void add_request(framework_request_table* t, framework_request* r);
   void put_request_table(framework_request_table* t);
   void initialize_request_table(framework_request_table* t);
  
    
   typedef struct framework_response{
      char title[MAX_STRING];
      char text[MAX_STRING]; 
   } framework_response;


   /*  Display a response on the screen */
   void put_response (framework_response* response);
   
   /* Initialize a response table : useful before calling the framewrok */
   void initialize_response(framework_response* response);
   
    
   typedef struct framework_response_table {
         int nb_entries;
         framework_response entries[MAX_REQUEST];
   } framework_response_table;

   void add_response(framework_response_table* t, framework_response* r);
   void put_response_table(framework_response_table* t);
   void initialize_response_table(framework_response_table* t);
  


   typedef enum{ 
          xml_output,   
          string_output} output_format; 

   typedef enum {  
          total_order, 
          causal_order} perform_order; 


   /* Call the framework : the system has to be correctly initialized before ! */  
   void sequential_framework_request (
         system* sys,  
         framework_request_table* request,
         framework_response_table* response,
	 perform_order order,
	 output_format format);
      

 


#endif
