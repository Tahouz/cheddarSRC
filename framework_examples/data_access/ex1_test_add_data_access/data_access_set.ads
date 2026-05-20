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
--    $Rev: 3477 $
--    $Date: 2020-07-13 11:43:48 +0200 (lun., 13 juil. 2020) $
--    $Author:  $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Framework_Config;      use Framework_Config;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Data_Accesss;       use Data_Accesss;
with sets;

package Data_Access_Set is

    ----------------------------------------------------------
    -- Definition of a set
    ----------------------------------------------------------

    package Data_Access_Set is new sets (max_element    => Framework_Config.Max_Data_Accesss,
                                            element        => Data_Access_Ptr,
                                            free           => Free,
                                            copy           => Copy,
                                            put            => Put,
                                            xml_string     => XML_String,
                                            xml_ref_string => XML_Ref_String);
    use Data_Access_Set;

    type Data_Accesss_Set is new Data_Access_Set.set with private;

    subtype Data_Accesss_Range is Data_Access_Set.element_range;
    subtype Data_Accesss_Iterator is Data_Access_Set.iterator;

    ----------------------------------------------------------
    -- Exceptions defined in the set package
    ----------------------------------------------------------

    -- Raised when a given Scheduling_Error is not in a Scheduling_Error set
    --
    Data_Access_Not_Found : exception;

    -- Raised when parameters provided to Add_Scheduling_Error are wrong
    --
    Invalid_Parameter : exception;

    ----------------------------------------------------------
    -- Procedure to proceed modification on a set
    ----------------------------------------------------------

    procedure Check_Data_Access
      (My_Data_Accesss         : in Data_Accesss_Set;
       Name                       : in Unbounded_String;
       A_Data_Access_Record    : in Data_Access_Record);

    procedure Add_Data_Access
      (My_Data_Accesss         : in out Data_Accesss_Set;
       A_Data_Access           : in out Data_Access_Ptr;
       Name                       : in Unbounded_String;
       A_Data_Access_Record    : in Data_Access_Record);

    procedure Add_Data_Access
      (My_Data_Accesss         : in out Data_Accesss_Set;
       Name                       : in Unbounded_String;
       A_Data_Access_Record    : in Data_Access_Record);


    ----------------------------------------------------------
    -- Search information from a set
    ----------------------------------------------------------

    
    function Search_Data_Access
     (My_Data_Accesss  : in Data_Accesss_Set;
       Name               : in Unbounded_String)
    return     Data_Access_Ptr;

    function Search_Data_Access_By_Id
      (My_Data_Accesss : in Data_Accesss_Set;
      id                  : in Unbounded_String)
    return      Data_Access_Ptr;

private

    type Data_Accesss_Set is new Data_Access_Set.set with null record;

end Data_Access_Set;
