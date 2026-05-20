
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
--    $Rev: 4643 $
--    $Date: 2023-11-27 14:47:11 +0100 (lun. 27 nov. 2023) $
--    $Author: singhoff $
------------------------------------------------------------------------------
------------------------------------------------------------------------------

with doubles; use doubles;
with text_io; use text_io;


package body energy_services is

 procedure compute_wctt(
      a_task	     : in  generic_task_ptr;
      a_battery	     : in  battery_ptr;
      S1             : out double;
      S2             : out double;
      S3             : out double;
      E1             : out double;
      Et1             : out double;
      E2             : out double;
      Et2             : out double;
      E3             : out double;
      t1             : out double;
      t2             : out double;
      t3             : out double
	) is

begin
 
  S1:=double'floor(  
     double(a_task.energy_consumption - a_task.capacity * a_battery.e_min)
     /
     double(a_battery.e_max - a_battery.e_min) );
put_line("S1 " & S1'img);

  E1:= S1 * double(a_battery.e_max);
put_line("E1 " & E1'img);

  S3:=double'floor(  
     double(a_task.capacity * a_battery.e_max - a_task.energy_consumption)
     /
     double(a_battery.e_max - a_battery.e_min) );
put_line("S3 " & S3'img);

  E3:= S3 * double(a_battery.e_min);
put_line("E3 " & E3'img);

  E2:= double(a_task.energy_consumption) - E1 - E3;
put_line("E2 " & E2'img);

  S2:= double(a_task.capacity) - S3 - S1; 
put_line("S2 " & S2'img);

  t1:= double'ceiling(E1/double(a_battery.rechargeable_power));
put_line("S1 " & S1'img);

  Et1 := t1*double(a_battery.rechargeable_power) - S1 * double(a_battery.e_max);
put_line("t1 " & t1'img);

  t2:= t1 + double'ceiling( 
	(double'ceiling(E2/double(a_battery.e_max)) * double(a_battery.e_max) -Et1)/double(a_battery.rechargeable_power)
	);
  if t2 < 0.0 then
	t2:=0.0;
  end if;
put_line("t2 " & t2'img);

  Et2 := (t2-t1)*double(a_battery.rechargeable_power) - E2 + Et1;
put_line("Et2 " & Et2'img);

  t3:=t2 + double'ceiling(
	(double'ceiling(E3/(E3+1.0) * (double(a_battery.e_max-a_battery.e_min)) +E3 -Et2)/double(a_battery.rechargeable_power)
	) );
  if t3 < 0.0 then
	t3:=0.0;
  end if;
put_line("t3 " & t3'img);

end compute_wctt;

procedure compute_wctt(
      a_task         : in  generic_task_ptr;
      a_battery      : in  battery_ptr;
      t3             : out double) is 

      S1 : double :=0.0;
      S2 : double :=0.0;
      S3 : double :=0.0;
      E1 : double :=0.0;
      Et1 : double :=0.0;
      E2 : double :=0.0;
      Et2 : double :=0.0;
      E3 : double :=0.0;
      t1 : double :=0.0;
      t2 : double :=0.0;
begin
 compute_wctt(
      a_task,
      a_battery,
      S1, S2, S3,
      E1, Et1, E2, Et2, E3,
      t1, t2, t3);
end compute_wctt;

end energy_services;
