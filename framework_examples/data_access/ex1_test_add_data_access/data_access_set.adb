
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

package body Data_Access_Set is

    procedure Check_Data_Access
      (My_Data_Access        : in Data_Access_Set;
       Name                       : in Unbounded_String;
       A_Data_Access_Record    : in Data_Access)
    is
        A_Data_Access  : Data_Access_Ptr;
        My_Iterator         : Data_Access_Iterator;
    begin
        if (get_number_of_elements (My_Data_Access) > 0) then

            reset_iterator (My_Data_Access, My_Iterator);

            loop
                current_element (My_Data_Access, A_Data_Access, My_Iterator);
                if (Name = A_Data_Access.name) then
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

                exit when is_last_element (My_Data_Access, My_Iterator);

                next_element (My_Data_Access, My_Iterator);
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

    end Check_Data_Access;

    procedure Add_Data_Access
      (My_Data_Access         : in out Data_Access_Set;
       Name                       : in Unbounded_String;
       A_Data_Access_Record    : in Data_Access_Record)
    is
        Dummy : Data_Access_Ptr;
    begin
        Add_Data_Access(My_Data_Access,
                             Dummy,
                             Name,
                             A_Data_Access_Record);
    end Add_Data_Access;

    procedure Add_Data_Access
      (My_Data_Access           : in out Data_Access_Set;
       A_Data_Access             : in out Data_Access_Ptr;
       Name                         : in Unbounded_String;
       A_Data_Access_Record      : in Data_Access_Record)
    is

    begin
        Check_Initialize;
        Check_Data_Access(My_Data_Access, Name, A_Data_Access_Record);

        A_Data_Access                            := new Data_Access;
        A_Data_Access.name                       := Name;
        A_Data_Access.Access_Type                  := A_Data_Access_Record.Access_Type;
        A_Data_Access.Time_Constraint_Name       := A_Data_Access_Record.Time_Constraint_Name;
        A_Data_Access.Adresse_memoire                   := A_Data_Access_Record.Adresse_memoire;
        -- A_Data_Access.Next_Data_Access_Name   := A_Data_Access_Record.Next_Data_Access_Name;
        A_Data_Access.Size                      := A_Data_Access_Record.Size;

        add (My_Data_Access, A_Data_Access);

    exception
        when full_set =>
            Raise_Exception
              (Invalid_Parameter'Identity,
               To_String (Lb_Can_Not_Define_More_Scheduling_Errors (Current_Language)));
    end Add_Data_Access;

function Search_Data_Access
      (My_Data_Access   : in Data_Access_Set;
       Name                 : in Unbounded_String)
       return      Data_Access_Ptr
    is
        My_Iterator         : Iterator;
        A_Data_Access    : Data_Access_Ptr;
        Result              : Data_Access_Ptr;

        Found : Boolean := False;
    begin
        if not is_empty(My_Data_Access) then

            reset_iterator (My_Data_Access, My_Iterator);

            loop
                current_element (My_Data_Access, A_Data_Access, My_Iterator);

                if (A_Data_Access.name = Name) then
                    Found  := True;
                    Result := A_Data_Access;
                end if;

                exit when is_last_element (My_Data_Access, My_Iterator);

                next_element (My_Data_Access, My_Iterator);

            end loop;

        end if;

        if not Found then
            Raise_Exception
              (Data_Access_Not_Found'Identity,
               To_String (Lb_Scheduling_Error_Name (Current_Language) & "=" & Name));
        end if;

        return Result;
    end Search_Data_Access;

    function Search_Data_Access_By_Id
      (My_Data_Access : in Data_Access_Set;
       id                   : in Unbounded_String)
       return      Data_Access_Ptr
    is
        My_Iterator         : Iterator;
        A_Data_Access    : Data_Access_Ptr;
        Result              : Data_Access_Ptr;

        Found : Boolean := False;
    begin
        if not is_empty(My_Data_Access) then

            reset_iterator (My_Data_Access, My_Iterator);

            loop
                current_element (My_Data_Access, A_Data_Access, My_Iterator);

                if (A_Data_Access.cheddar_private_id = id) then
                    Found  := True;
                    Result := A_Data_Access;
                end if;

                exit when is_last_element (My_Data_Access, My_Iterator);

                next_element (My_Data_Access, My_Iterator);

            end loop;

        end if;

        if not Found then
            Raise_Exception
              (Data_Access_Not_Found'Identity,
               To_String (Lb_Scheduling_Error_Id (Current_Language) & "=" & id));
        end if;

        return Result;
    end Search_Data_Access_By_Id;


end Data_Access_Set;
