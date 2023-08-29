# visual-stimuli

Codes generating visual stimuli using MATLAB Psychtoolbox
Based on https://github.com/baccuslab/stimuli

Dongsoo Lee

Baccus Laboratory, Stanford University

### Usage
1. Check the hardware (GPU) and OS
2. Write down a `config.json` file
3. Run Psychtoolbox script (e.g., `dotsdraw.m` / `stimdraw.m`). The script will
read `config.json`, draw stimuli, and save additional info into `archive`
directory.

### Disclaimer
The scripts are not efficient (memory, speed) and not clean (intended).
This is because functions were designed for an easy debugging during actual
experiment. Some functions, data structure, and variables were frequently
edited before/during experiments for a temporally precise data acquisition. 

### Timing precision
It is highly recommended to run the scripts on Linux (Ubuntu).
With a proper setup, standard deviation across frames: 0.5 micro seconds.
