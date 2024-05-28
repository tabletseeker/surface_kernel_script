# surface_kernel_script
Automatically applies all patches while merging the appropriate kernel config and building the latest surface_kernel
from the [linux-surface repository](https://github.com/linux-surface/linux-surface).

# Global Variables

|  Variable                                             | Description                                                                                    | Default Value                                                                                
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------------|--------------------------------------------------|
| SOURCE_DIR        | Working directory  		 | `$HOME` |
| KERNEL_BRANCH     | Kernel branch or tag available on [Linux Kernel Source](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git)  | `v6.8.10` |
| SURFACE_KERNEL    | Kernel version directory name in linux-surface/patches/XX/*.patch  | `6.8` | 

# Usage

* clone this repo:
```
git clone https://github.com/tabletseeker/surface_kernel_script
```
* change variables as needed
* execute:
```
bash surface_kernel_script/kernel.sh
```
