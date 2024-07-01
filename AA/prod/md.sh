#!/usr/bin/env bash
mdpdir='../mdp'

gmx_mpi grompp -v -f $mdpdir/md.mdp -c npt2.gro -r npt2.gro -p topol.top -n index.ndx -o md.tpr
gmx_mpi mdrun -v -deffnm md 


