#!/bin/csh
set mils = ~illham/cheddar/trunk/src/generator_model_v2
set nb = 19
set tab = (-1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1 -1)

# pour les tests puis commenter et mettre les deux lignes du dessus
#set nb = 4
#set tab = (-1 -1 -1 -1)

set s = 1

while (1)

	 @ tab[$s]++
        if ($tab[$s] == 2 && $s > 1) then
                set tab[$s] =  -1
                @ s--
        else
        if  ($tab[$s] == 2 && $s == 1) then
                exit
        else
        if  ($tab[$s] != 2 && $s < $nb) then
                @ s++
        else
                set st = `echo $tab | sed -e 's/ //g'`

        #enlever le echo en debut de ligne et les guillemets
        cd ~illham/cheddar/trunk/src/
                $mils -i 0000000000000000000 -c $st -a bell
        endif
        endif
        endif

	
end
	
