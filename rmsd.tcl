#change input files accordingly

set myPDB gS_5_allh_water_ions.pdb
set totalrun 10
set step 1
set trajFileType dcd
set datafile rmsd.dat

#actions start here

#load pdb file
set molid [mol new $myPDB waitfor all]

#gather all dcd files
set trajfiles ""
for {set i 1} {$i <= $totalrun} {incr i} {
	if {$i==1} {
		lappend trajfiles npt_eq01.dcd
	} elseif {$i<10} {
		    lappend trajfiles npt0${i}.dcd
	} else {
       lappend trajfiles npt${i}.dcd
    }
}
#delete the crystal structure

animate delete all

#load all dcd files
foreach trajfile $trajfiles {
	animate read $trajFileType $trajfile beg 0 end -1 skip 1 waitfor all $molid
}

#open doc for output
set outfile [open $datafile "w"]

#select reference with backbone
set ref [atomselect top "protein and name C CA N" frame 0]
#set ref_sel [atomselect top "protein" frame 0]

#frame by frame, align and compute rmsd
for {set i 0} {$i < [molinfo top get numframes]} {incr i} {
#select comparison, same selection as reference, but in different frame
	set sel1 [atomselect top "protein and name C CA N" frame $i]
#measure transformation matrix for allignment
	set  transformation_matrix [measure fit $sel1 $ref]
#select the whole protein, and move according to transformation matrix for allignment 
	set move_sel [atomselect top "protein" frame $i]
	$move_sel move $transformation_matrix
#measure rmsd
	set rmsdv [measure rmsd $ref $sel1]
#set up vector in the format of {frame rmsd}
	set opv "$i"
	lappend opv $rmsdv 
#write the vector to output file
	puts $outfile $opv
 }

exit

 
