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
--    $Rev: 4589 $
--    $Date: 2023-09-29 16:02:19 +0200 (ven., 29 sept. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------



with text_io;
use text_io;
with ada.strings.unbounded;
use ada.strings.unbounded;



procedure dfg is 


---------------------------
-- Constates
---------------------------

NB_MAX_BLOCKS_CFG : natural := 30;
MAX_NB_STATEMENTS_BLOCK : natural :=10;
MAX_NB_USED_VAR_STATEMENT : natural :=10;
MAX_NB_NEXT_NODES_STATEMENT : natural := 10;
MAX_NB_PREVIOUS_NODES_STATEMENT : natural := 10;
MAX_DEF : natural := (MAX_NB_STATEMENTS_BLOCK*NB_MAX_BLOCKS_CFG);
MAX_USE : natural := (MAX_NB_USED_VAR_STATEMENT*MAX_NB_STATEMENTS_BLOCK);
MAX_DEF_USE : natural := (MAX_USE*MAX_DEF*NB_MAX_BLOCKS_CFG);


---------------------------
-- Types
---------------------------

type cfg_graph_type is (start_node, middle_node, terminate_node);

type variable is record 
  name : unbounded_string;
end record;
type variable_ptr is access variable;

type variable_table is array (1..MAX_NB_USED_VAR_STATEMENT) of variable_ptr;

type statement is record 
  name : unbounded_string;
  defined_variable : variable_ptr;
  used_variable : variable_table;
end record;
type statement_ptr is access statement;



---------------------------
-- Subprograms
---------------------------

procedure print_statement(stmt : in statement_ptr) is 
begin
  put_line("---------- Statement : " & to_string(stmt.name));
  put_line("               with def_var : ");
  if (stmt /= NULL) 
     then if (stmt.defined_variable /= NULL) 
	then put(to_string(stmt.defined_variable.name));
     end if;
  end if;
  put_line("               with used_vars : ");
  if (stmt /= NULL) 
  	then for i in variable_table'range loop
  		if (stmt.used_variable(i) /= NULL) 
			then put(to_string(stmt.used_variable(i).name));
		end if;
  	end loop; 
   end if;
end print_statement;


begin
	text_io.put_line("bonjour valou :-) ");
end dfg;



