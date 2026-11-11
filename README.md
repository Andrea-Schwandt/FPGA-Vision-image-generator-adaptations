# FPGA-Vision-image-generator-adaptations
This repository is based on Marco Winzker's video generator repository (https://github.com/Marco-Winzker)

## Instructions for using the Arty Z7 board in the remote lab:

To setup a project for the lane detection or FIR filter, please follow these steps:
1. install the board files from digilent (see https://digilent.com/reference/programmable-logic/guides/vitis-unified-installation for instructions)
2. download and implement the ip-cores from digilent (https://github.com/Digilent/vivado-library)
3. download the files from this repository and unpack them
4. setup a project for the image generator
5. add *street_adapted_to_arty_z7.vhd* and *street_image_720p.vhd* to your project
6. add the *Arty-Z7-20-Master_RL.xdc* from this repository (root) to your constraints
7. go to the tcl console in Vivado, go into the "FPGA-Vision-image-generator-adaptations-main" directory with *cd "x:/your_path/FPGA-Vision-image-generator-adaptations-main"* and execute
   * *source ../all_ips_image_generator_Arty_Z7.tcl*
  
8. check, if all dependencies are resolved and run synthesis, implementation and generate bitfile. You will find you bitstream under "X:\your_project_directory_path\your_project_name.runs\impl_1\street_arty_z7.bit""
9. go to https://fpga-vision-test-lab.h-brs.de/, register or, if already registered, sign in and access the video experiment from the Arty Z7 lab, upload your bitfile and test it with real hardware!
