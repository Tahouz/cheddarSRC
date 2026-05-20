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
-- Frank Singhoff, Lab-STICC UMR 6285, Université de Bretagne Occidentale
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

package body Statements.extended is

   procedure recursive_put (s : in generic_statement_ptr) is

   begin

      Put (s.all);

      if (s.statement_type = while_statement_type) then
         if (while_statement_ptr (s).included_statement /= null) then
            Put ("Included statement : ");
            New_Line;
            recursive_put (while_statement_ptr (s).included_statement);
         end if;
      end if;
      if (s.statement_type = for_statement_type) then
         if (for_statement_ptr (s).included_statement /= null) then
            Put ("Included statement : ");
            New_Line;
            recursive_put (for_statement_ptr (s).included_statement);
         end if;
      end if;

      if (s.statement_type = if_statement_type) then
         if (if_statement_ptr (s).then_statement /= null) then
            Put ("Then statement : ");
            New_Line;
            New_Line;
            recursive_put (if_statement_ptr (s).then_statement);
         end if;
         if (if_statement_ptr (s).else_statement /= null) then
            Put ("Else statement : ");
            New_Line;
            New_Line;
            recursive_put (if_statement_ptr (s).else_statement);
         end if;

      else
         if (s.next_statement /= null) then
            Put ("Next statement  : ");
            New_Line;
            New_Line;
            recursive_put (s.next_statement);
         end if;

      end if;

   end recursive_put;
end Statements.extended;
