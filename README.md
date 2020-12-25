# `knitr` language engine for `cling`

Allows writing `C++` code chunks inside `RMarkdown`, compiling the chunks via `cling` and generating RMakrdown documents.


<details open>
<summary>General Info</summary>

TODO

</details>

## Setting up VirtualBox

Note that this is a very barebones guide, which takes less priority, as there is ample info on the web on how to do this.

<details>
<summary>(click to collapse) Installing VirtualBox and Creating an Ubuntu Guest OS:</summary>

+ Start by downloading [VirtualBox](https://www.virtualbox.org/wiki/Downloads) as well as the expansion pack:

    ![](./_img/pic_vb_01.png)

+ Install VirtualBox and the expansion pack.

+ Then, download [Ubuntu Desktop 20.04.1 LTS](https://ubuntu.com/download/desktop) (haven't tested with other Linux versions/distributions).

+ Open VirtualBox and click 'New'. Then, set a name and version for this VM:

    ![](./_img/pic_01.png)

+ Select the amount of RAM that you want to allocate to this machine.
+ Select the type of virtual harddrive (default - VDI). As for the size - I have used 20 GB (might work with 10 GB, unless you want to compile `cling` yourself - then > 50 GB might be needed).
+ When installing Ubuntu, select the minimal installation size and not to download any updates while installing. This will speed up the installation process and we can always update later.

    ![](./_img/pic_vb_04.png)

</details>

<details>
<summary>(click to collapse) Configure VirtualBox guest addons:</summary>

This will allow copy-pasting code between your host machine and the ubuntu guest machine.

Open the terminal and input the following commands:

```
sudo apt-get update && sudo apt-get install -y virtualbox-guest-x11
```

Then, in VirtualBox, in the guest os window, click `Machine -> Settings`:

![](./_img/pic_vb_05.png)

In `General`, select the `Advanced` tab and change `Shared Clipboard`

![](./_img/pic_vb_06.png)

 to be `Bidirectional`:

![](./_img/pic_vb_07.png)

Finally, enable the clipboard between the guest and host os by executing the following command:

```
sudo VBoxClient --clipboard
```

To test this, you can try copying some text from you host machine, and verifying that you can paste in in the guest machine. If it does not work, you might need to `reboot` and again try to enable the clipboard function using ```sudo VBoxClient --clipboard``` .


</details>

<details>
<summary>(click to collapse) Add a Shared Folder:</summary>

<b>Power off your Guest Machine</b>, then select it in VirtualBox and click `Settings`:

![](./_img/pic_vb_10.png)

Click on `Shared Folders` on the left panel and the `+` button on the right side:

![](./_img/pic_vb_11.png)

Select a folder on your Host machine, which you want to share with the guest machine - this will let you directly save and edit files from your own machine, from inside the VM. Make sure that:

![](./_img/pic_vb_12.png)

Note that on your guest OS in ubuntu this will be in `/media/sf_<name_of_folder>`, where `<name_of_folder>` is the folder name that you specified in the above picture.

To access shared folders between the VM and host machine, run the following command from the gues os terminal:

```
sudo adduser $USER vboxsf
```

You will need to reboot the guest OS - you can do this by writing ```sudo reboot``` in the terminal.

Once it finishes rebooting, open the file explorer on the guest machine and click `+ Other Locations` then select `Computer`:

![](./_img/pic_vb_13.png)

Then, go to the `media` folder, where you will see the `sf_<name_of_folder>`:

![](./_img/pic_vb_14_1.png)

Double clicking it should open the folder. 

If you will see the folder with a red `X`:

![](./_img/pic_vb_14_2.png)


It will probably ask you for your guest OS user password - input it and you should see the folder contents. <i>
Note that his might mean that something went wrong and the folders aren't correctly shared, since after reboot it should no longer ask for the password
</i>. 

You can try to create an empty folder there - you should see any new files and folders both in the guest os, as well as the host machine. You can also click `F5` on the keyboard to refresh the folder, in case the files do not appear immediately.


<b>You can copy this repository to the shared folder - this will make it much easier to download and setup cling and such via the provided scripts.</b>

</details>

## Downloading `cling`, `r` and `rstudio`

This repository has a number bash scripts in `_scripts` folder, which dowloads all of the required packages(currently might include some unnecessary ones as well) to install `r`, `rstudio`, `cling`. It also moves `cling` to your `home` directory and adds it to the `PATH`. 

Right-clicking inside the shared folder and selecting `Open in Terminal` allows you to easily open the terminal in that directory

![](./_img/pic_vb_15.png)

and run the scripts as follows (one-by-one):

```
./00_base_packages.sh
./01_get_r_rstudio.sh
./02_get_cling.sh
```

Finally, `reboot` the guest OS. After reboot, open the terminal and verify that you can call `cling` from the terminal:

![](./_img/pic_vb_16.png)

Verify that `C++` code works in `cling`:

```
#include <stdio.h>

printf("Hello World!\n");
```

You can quit the terminal with ```.q```

## The `knitr` language engine for `cling`

The (very preliminary) `knitr` language engine for `cling` is provided in the `src` folder. The example of this engine is provided in the `examples` folder.

 The [custom language engine](https://bookdown.org/yihui/rmarkdown-cookbook/custom-engine.html) is based on `rstudioapi`, which allows passing the input to a terminal, therefore allowing for a persistant `cling` session, i.e. variables persist throughout the different chunks. Optionally, passing `engine.opts = list(cling = 'ClearClingEnv')` tells the `cling` language engine to close the current terminal and open a new one.

 ## <span style="color:red">IMPORTANT!</span> Current Limitations

 See [rstudio#6892](https://github.com/rstudio/rstudio/issues/6892#issuecomment-630267412) - `knitr` creates a new session, therefore `rstudioapi` cannot find an active `rstudio` app. To account for this, use `rmarkdown::render(my_rmd_file.rmd)` (or similar) to render your file in RStudio's `R` command prompt.

 Alternatively, `system2(...)` can be used instead of `rstudioapi`. However, a persistent session will not be available - you would need to find a way to [serialize objects in C++](https://isocpp.org/wiki/faq/serialization). I haven't tried this, so I cannot say how efficient this would be compared to the current setup.

 ## TODO's

 Various TODO's:

 * [ ] Ability to pass the name of the terminal, thereby allowing multiple terminals with different sessions.
 * [ ] Better way to distinguish between errors and output.
 * [ ] Caching. See [ROOT files](https://root.cern.ch/root/html534/guides/users-guide/InputOutput.html) for a possible solution.