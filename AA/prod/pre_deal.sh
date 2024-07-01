#!/bin/sh

mdpdir='../mdp'

deal_pre=1
deal_em=1
deal_nvt=1
deal_npt=1
deal_nvt2=1
deal_npt2=1
deal_clean=1


if [ $deal_pre == 1 ];then
    gmx_mpi pdb2gmx -f ssb.pdb -ff amber14sb -water tip3p -ignh
    gmx_mpi editconf -f conf.gro -o box2.gro -c -d 1.0 -bt cubic
    gmx_mpi solvate -cp box2.gro -cs spc216.gro -o solv.gro -p topol.top
    gmx_mpi grompp -f $mdpdir/ions.mdp -c solv.gro -p topol.top -o ions.tpr -maxwarn 1
    echo SOL |gmx_mpi genion -s ions.tpr -o solv_ions.gro -p topol.top -pname NA -nname CL -neutral -conc 0.500
    gmx_mpi make_ndx -f solv_ions.gro <<EOF
"Protein"|"Ion"
q
EOF
fi

if [ $deal_em == 1 ];then
    gmx_mpi grompp -f $mdpdir/em.mdp -c solv_ions.gro -p topol.top -o em.tpr -r solv_ions.gro
    gmx_mpi mdrun -v -deffnm em 
fi

if [ $deal_nvt == 1 ];then
    gmx_mpi grompp -v -f $mdpdir/nvt.mdp -c em.gro -r em.gro -p topol.top -n index.ndx -o nvt.tpr
    gmx_mpi mdrun -v -deffnm nvt 
fi

if [ $deal_npt == 1 ];then
    gmx_mpi grompp -v -f $mdpdir/npt.mdp -c nvt.gro -r nvt.gro -p topol.top -n index.ndx -o npt.tpr
    gmx_mpi mdrun -v -deffnm npt 
fi

if [ $deal_nvt2 == 1 ];then
    gmx_mpi grompp -v -f $mdpdir/nvt2.mdp -c npt.gro -r npt.gro -p topol.top -n index.ndx -o nvt2.tpr
    gmx_mpi mdrun -v -deffnm nvt2 
fi

if [ $deal_npt2 == 1 ];then
    gmx_mpi grompp -v -f $mdpdir/npt2.mdp -c nvt2.gro -r nvt2.gro -p topol.top -n index.ndx -o npt2.tpr
    gmx_mpi mdrun -v -deffnm npt2 
fi

if [ $deal_clean == 1 ];then
    rm -rf \#*
fi

