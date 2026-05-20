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

with Sax.Exceptions;
with Sax.Locators;  use Sax.Locators;
with Sax.Readers;
with Sax.Attributes;
with Unicode.CES;
with systems;       use systems;
with processor_set; use processor_set;
use processor_set.generic_processor_set;
with Scheduling_Analysis;               use Scheduling_Analysis;
with Multiprocessor_Services_Interface; use Multiprocessor_Services_Interface;
use Multiprocessor_Services_Interface.Scheduling_Result_Per_Processor_Package;

package v2_xml_parsers is

   ----------------------------------------------------------------------------
   ------
   ----------------------------------------------------------------------------
   ------
   ----------------    Mandatory code for all XML parser of Cheddar
   ----------------------------------------------------------------------------
   ------
   ----------------------------------------------------------------------------
   ------

   -- Exception raised by clients of Xml_Parses when something goes
   -- wrong during XML parsing
   --
   xml_read_error : exception;

   -- Generic XML parser
   --
   type xml_generic_parser is new Sax.Readers.reader with private;

   -- Methods for all Cheddar XML parsers
   --
   procedure characters
     (handler : in out xml_generic_parser;
      ch      :        Unicode.CES.byte_sequence);
   procedure error
     (handler : in out xml_generic_parser;
      except  :        Sax.Exceptions.sax_parse_exception'class);
   procedure fatal_error
     (handler : in out xml_generic_parser;
      except  :        Sax.Exceptions.sax_parse_exception'class);
   procedure warning
     (handler : in out xml_generic_parser;
      except  :        Sax.Exceptions.sax_parse_exception'class);

   ----------------------------------------------------------------------------
   ------
   ----------------------------------------------------------------------------
   ------
   ----------------    Necessary code to parse XML Cheddar project files
   ----------------------------------------------------------------------------
   ------
   ----------------------------------------------------------------------------
   ------

   -- This tagged type is the parser ...
   --
   type xml_project_parser is new xml_generic_parser with private;

   -- Override methods of the Reader to custom the treatement the
   -- parser have to do
   --
   procedure start_document (handler : in out xml_project_parser);
   procedure start_element
     (handler       : in out xml_project_parser;
      namespace_uri :        Unicode.CES.byte_sequence := "";
      local_name    :        Unicode.CES.byte_sequence := "";
      qname         :        Unicode.CES.byte_sequence := "";
      atts          :        Sax.Attributes.attributes'class);
   procedure end_element
     (handler       : in out xml_project_parser;
      namespace_uri :        Unicode.CES.byte_sequence := "";
      local_name    :        Unicode.CES.byte_sequence := "";
      qname         :        Unicode.CES.byte_sequence := "");

   procedure initialize_project_parser (handler : in out xml_project_parser);
   function get_parsed_system (handler : in xml_project_parser) return system;

   ----------------------------------------------------------------------------
   ------
   ----------------------------------------------------------------------------
   ------
   ----------------    Necessary code to parse XML Cheddar project files
   ----------------------------------------------------------------------------
   ------
   ----------------------------------------------------------------------------
   ------

   -- This tagged type is the parser ...
   --
   type xml_event_table_parser is new xml_generic_parser with private;

   -- Override methods of the Reader to custom the treatement the
   -- parser have to do
   --
   procedure start_document (handler : in out xml_event_table_parser);
   procedure start_element
     (handler       : in out xml_event_table_parser;
      namespace_uri :        Unicode.CES.byte_sequence := "";
      local_name    :        Unicode.CES.byte_sequence := "";
      qname         :        Unicode.CES.byte_sequence := "";
      atts          :        Sax.Attributes.attributes'class);
   procedure end_element
     (handler       : in out xml_event_table_parser;
      namespace_uri :        Unicode.CES.byte_sequence := "";
      local_name    :        Unicode.CES.byte_sequence := "";
      qname         :        Unicode.CES.byte_sequence := "");

   procedure initialize_event_table_parser
     (handler : in out xml_event_table_parser);
   procedure read_time_value (handler : in out xml_event_table_parser);
   procedure set_scheduled_system
     (handler          : in out xml_event_table_parser;
      scheduled_system : in     system);
   function get_parsed_event_table
     (handler : in xml_event_table_parser) return scheduling_table_ptr;

private

   type xml_generic_parser is new Sax.Readers.reader with record
      locator : Sax.Locators.locator;
   end record;

   type xml_project_parser is new xml_generic_parser with record
      -- At the end of the parser execution, the project
      -- is store in the objet below
      --
      parsed_system : system;
   end record;

   type xml_event_table_parser is new xml_generic_parser with record
      -- At the end of the parser execution, the event table
      -- is store in the objet below
      --
      parsed_event_table : scheduling_table_ptr;

      -- At the end of the parser execution, the project
      -- is store in the objet below
      --
      scheduled_system : system;
   end record;

end v2_xml_parsers;
