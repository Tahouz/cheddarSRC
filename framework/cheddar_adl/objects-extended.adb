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

with Tasks;           use Tasks;
with Buffers;         use Buffers;
with Processors;      use Processors;
with Caches;          use Caches;
with Resources;       use Resources;
with Address_Spaces;  use Address_Spaces;
with Messages;        use Messages;
with Networks;        use Networks;
with Core_Units;      use Core_Units;
with event_analyzers; use event_analyzers;
with Task_Groups;     use Task_Groups;


package body Objects.extended is

   function is_a_valid_identifier (id : Unbounded_String) return Boolean is
      char : Character;

   begin

      for i in 1 .. Length (id) loop

         char := Element (id, i);
         if char /= 'a' and
           char /= 'b' and
           char /= 'c' and
           char /= 'd' and
           char /= 'e' and
           char /= 'f' and
           char /= 'g' and
           char /= 'h' and
           char /= 'i' and
           char /= 'j' and
           char /= 'h' and
           char /= 'k' and
           char /= 'l' and
           char /= 'm' and
           char /= 'n' and
           char /= 'o' and
           char /= 'p' and
           char /= 'q' and
           char /= 'r' and
           char /= 's' and
           char /= 't' and
           char /= 'u' and
           char /= 'v' and
           char /= 'w' and
           char /= 'x' and
           char /= 'y' and
           char /= 'z' and
           char /= 'A' and
           char /= 'B' and
           char /= 'C' and
           char /= 'D' and
           char /= 'E' and
           char /= 'F' and
           char /= 'G' and
           char /= 'H' and
           char /= 'I' and
           char /= 'J' and
           char /= 'K' and
           char /= 'L' and
           char /= 'M' and
           char /= 'N' and
           char /= 'O' and
           char /= 'P' and
           char /= 'Q' and
           char /= 'R' and
           char /= 'S' and
           char /= 'T' and
           char /= 'U' and
           char /= 'V' and
           char /= 'W' and
           char /= 'X' and
           char /= 'Y' and
           char /= 'Z' and
           char /= '0' and
           char /= '1' and
           char /= '2' and
           char /= '3' and
           char /= '4' and
           char /= '5' and
           char /= '6' and
           char /= '7' and
           char /= '8' and
           char /= '9' and
           char /= '.' and
           char /= '/' and
           char /= '\' and
           char /= '-' and
           char /= ':' and
           char /= '_'
         then
            return False;
         end if;
      end loop;

      return True;

   end is_a_valid_identifier;

   function get_name_of_generic_object
     (obj : generic_object_ptr) return Unbounded_String
   is
   begin
      return named_object (obj.all).name;
   end get_name_of_generic_object;

end Objects.extended;

