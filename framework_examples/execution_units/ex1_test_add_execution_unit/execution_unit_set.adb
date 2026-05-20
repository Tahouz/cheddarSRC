
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
--    $Author: $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with Ada.Exceptions;       use Ada.Exceptions;
with Translate;            use Translate;
with Objects;              use Objects;
with Objects.extended;     use Objects.extended;
with unbounded_strings;    use unbounded_strings;
with initialize_framework; use initialize_framework;
with Debug;                use Debug;

package body Execution_Unit_Set is

    procedure Check_Execution_Unit
      (My_Execution_Units         : in Execution_Units_Set;
       Name                       : in Unbounded_String;
       A_Execution_Unit_Record    : in Execution_Unit_Record)
    is
        A_Execution_Unit  : Execution_Unit_Ptr;
        My_Iterator         : Execution_Units_Iterator;
    begin
        if (get_number_of_elements (My_Execution_Units) > 0) then

            reset_iterator (My_Execution_Units, My_Iterator);

            loop
                current_element (My_Execution_Units, A_Execution_Unit, My_Iterator);
                if (Name = A_Execution_Unit.name) then
                    Raise_Exception
                      (Invalid_Parameter'Identity,
                       To_String
                         (Lb_Scheduling_Error(Current_Language) &
                            " " &
                            Name &
                            " : " &
                            Lb_Scheduling_Error_Name (Current_Language) &
                            Lb_Already_Defined (Current_Language)));
                end if;

                exit when is_last_element (My_Execution_Units, My_Iterator);

                next_element (My_Execution_Units, My_Iterator);
            end loop;
        end if;

        if (Name = "") then
            Raise_Exception
              (Invalid_Parameter'Identity,
               To_String
                 (Lb_Scheduling_Error_Name (Current_Language) &
                    Lb_Mandatory (Current_Language)));
        end if;

        if not Is_A_Valid_Identifier (Name) then
            Raise_Exception
              (Invalid_Parameter'Identity,
               To_String
                 (Lb_Scheduling_Error (Current_Language) &
                    " " &
                    Name &
                    " : " &
                    Lb_Scheduling_Error_Name (Current_Language) &
                    Lb_Colon &
                    Lb_Invalid_Identifier (Current_Language)));
        end if;

    end Check_Execution_Unit;

    procedure Add_Execution_Unit
      (My_Execution_Units         : in out Execution_Units_Set;
       Name                       : in Unbounded_String;
       A_Execution_Unit_Record    : in Execution_Unit_Record)
    is
        Dummy : Execution_Unit_Ptr;
    begin
        Add_Execution_Unit(My_Execution_Units,
                             Dummy,
                             Name,
                             A_Execution_Unit_Record);
    end Add_Execution_Unit;

    procedure Add_Execution_Unit
      (My_Execution_Units           : in out Execution_Units_Set;
       A_Execution_Unit             : in out Execution_Unit_Ptr;
       Name                         : in Unbounded_String;
       A_Execution_Unit_Record      : in Execution_Unit_Record)
    is

    begin
        Check_Initialize;
        Check_Execution_Unit(My_Execution_Units, Name, A_Execution_Unit_Record);

        A_Execution_Unit                            := new Execution_Unit;
        A_Execution_Unit.name                       := Name;
        A_Execution_Unit.Unit_type                  := A_Execution_Unit_Record.Unit_type;
        A_Execution_Unit.Time_Constraint_Name       := A_Execution_Unit_Record.Time_Constraint_Name;
        A_Execution_Unit.Capacity                   := A_Execution_Unit_Record.Capacity;
        -- A_Execution_Unit.Next_Execution_Unit_Name   := A_Execution_Unit_Record.Next_Execution_Unit_Name;
        A_Execution_Unit.Order                      := A_Execution_Unit_Record.Order;

        add (My_Execution_Units, A_Execution_Unit);

    exception
        when full_set =>
            Raise_Exception
              (Invalid_Parameter'Identity,
               To_String (Lb_Can_Not_Define_More_Scheduling_Errors (Current_Language)));
    end Add_Execution_Unit;

function Search_Execution_Unit
      (My_Execution_Units   : in Execution_Units_Set;
       Name                 : in Unbounded_String)
       return      Execution_Unit_Ptr
    is
        My_Iterator         : Iterator;
        A_Execution_Unit    : Execution_Unit_Ptr;
        Result              : Execution_Unit_Ptr;

        Found : Boolean := False;
    begin
        if not is_empty(My_Execution_Units) then

            reset_iterator (My_Execution_Units, My_Iterator);

            loop
                current_element (My_Execution_Units, A_Execution_Unit, My_Iterator);

                if (A_Execution_Unit.name = Name) then
                    Found  := True;
                    Result := A_Execution_Unit;
                end if;

                exit when is_last_element (My_Execution_Units, My_Iterator);

                next_element (My_Execution_Units, My_Iterator);

            end loop;

        end if;

        if not Found then
            Raise_Exception
              (Execution_Unit_Not_Found'Identity,
               To_String (Lb_Scheduling_Error_Name (Current_Language) & "=" & Name));
        end if;

        return Result;
    end Search_Execution_Unit;

    function Search_Execution_Unit_By_Id
      (My_Execution_Units : in Execution_Units_Set;
       id                   : in Unbounded_String)
       return      Execution_Unit_Ptr
    is
        My_Iterator         : Iterator;
        A_Execution_Unit    : Execution_Unit_Ptr;
        Result              : Execution_Unit_Ptr;

        Found : Boolean := False;
    begin
        if not is_empty(My_Execution_Units) then

            reset_iterator (My_Execution_Units, My_Iterator);

            loop
                current_element (My_Execution_Units, A_Execution_Unit, My_Iterator);

                if (A_Execution_Unit.cheddar_private_id = id) then
                    Found  := True;
                    Result := A_Execution_Unit;
                end if;

                exit when is_last_element (My_Execution_Units, My_Iterator);

                next_element (My_Execution_Units, My_Iterator);

            end loop;

        end if;

        if not Found then
            Raise_Exception
              (Execution_Unit_Not_Found'Identity,
               To_String (Lb_Scheduling_Error_Id (Current_Language) & "=" & id));
        end if;

        return Result;
    end Search_Execution_Unit_By_Id;


end Execution_Unit_Set;
