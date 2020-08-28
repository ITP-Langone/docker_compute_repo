<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> 0bc163a43257f6223a60e5d9fc9cc661bbe55756
# Create a MATLAB Container Image
## Requirements
You must perform these steps on a Linux platform.
Before starting, you must install the following on the client platform
- Docker
- Git

## Introduction
<<<<<<< HEAD
The following steps guide you through the process of creating a Docker container image that contains a Linux environment with a MATLAB installation. 
Use the container image as a scalable and reproducible method to deploy MATLAB in a variety of situations including clouds and clusters.

## Step 1. Clone this Repository
1. Clone this repository to your Linux client using 
=======
The following steps guide you through the process of creating a Docker container image that contains a Linux environment with a MATLAB installation.
Use the container image as a scalable and reproducible method to deploy MATLAB in a variety of situations including clouds and clusters.

## Step 1. Clone this Repository
1. Clone this repository to your Linux client using
>>>>>>> 0bc163a43257f6223a60e5d9fc9cc661bbe55756

    `git clone https://github.com/mathworks-ref-arch/matlab-dockerfile.git`
2. Inside the cloned repository, create a subdirectory named `matlab-install`

## Step 2. Choose MATLAB Installation Method
<<<<<<< HEAD
To install MATLAB into the container image, choose a MATLAB installation method. You can use MATLAB installation files or a MATLAB ISO image. 
=======
To install MATLAB into the container image, choose a MATLAB installation method. You can use MATLAB installation files or a MATLAB ISO image.
>>>>>>> 0bc163a43257f6223a60e5d9fc9cc661bbe55756

### MATLAB Installation Files
To obtain the installation files, you must be an administrator for the license linked with your MathWorks account.
1. From the [MathWorks Downloads](https://www.mathworks.com/downloads/) page, select the desired version of MATLAB.
2. Download the Installer for Linux.
<<<<<<< HEAD
3. Follow the steps at [Download Products Without Installation](https://www.mathworks.com/help/install/ug/download-only.html). 
4. Specify the location of the `matlab-install` subdirectory of the cloned repository as the path to the download folder. 
5. Select the installation files for the Linux (64-bit) version of MATLAB. 
6. Select the products you want to install in the container image.
7. Confirm your selections and complete the download. 

### MATLAB ISO
1. From the [MathWorks Downloads](https://www.mathworks.com/downloads/) page, select the desired version of MATLAB.
2. Under the Related Links heading, click the link to get the ISO image for the chosen MATLAB version. 
=======
3. Follow the steps at [Download Products Without Installation](https://www.mathworks.com/help/install/ug/download-only.html).
4. Specify the location of the `matlab-install` subdirectory of the cloned repository as the path to the download folder.
5. Select the installation files for the Linux (64-bit) version of MATLAB.
6. Select the products you want to install in the container image.
7. Confirm your selections and complete the download.

### MATLAB ISO
1. From the [MathWorks Downloads](https://www.mathworks.com/downloads/) page, select the desired version of MATLAB.
2. Under the Related Links heading, click the link to get the ISO image for the chosen MATLAB version.
>>>>>>> 0bc163a43257f6223a60e5d9fc9cc661bbe55756
3. Download the ISO image for the Linux.
4. Extract the ISO into the `matlab-install` subdirectory of the cloned repository.

## Step 3. Obtain the License File and File Installation Key
1. Log in to your [MathWorks account](https://www.mathworks.com/login). Select the license you wish to use with the container.
2. Select the Install and Activate tab. Select the link “Activate to Retrieve License File”.
<<<<<<< HEAD
3. Click the download link under the Get License File heading. 
=======
3. Click the download link under the Get License File heading.
>>>>>>> 0bc163a43257f6223a60e5d9fc9cc661bbe55756
4. Select the appropriate MATLAB version and click Continue.
5. At the prompt “Is the software installed?” select “No” and click Continue.
6. Copy the File Installation Key into a safe location.

## Step 4. Define Installation Parameters
1. Make a copy of the file `installer_input.txt` in the `matlab-install` folder. Move the copy up one directory level, into the root directory of the cloned repository.
2. Rename the file to `matlab_installer_input.txt`.
3. Open `matlab_installer_input.txt` in a text editor and edit the following sections:
    - `fileInstallationKey` Paste your File Installation Key and uncomment the line.
    - `agreeToLicense` Set the value to yes and uncomment the line.
    - Specify products to install. Uncomment the line `product.MATLAB` to install MATLAB. Uncomment the corresponding line for each additional product you want to install. If you are not licensed to use a product, uncommenting the line does not install the product in the container. Your File installation Key identifies the products you can install.
<<<<<<< HEAD
4.	*(Optional)* Specify required dependencies in the `Dockerfile`. Edit the `Dockerfile` and uncomment the corresponding line for each dependency you want to add. For more information, see [Optional Dependencies](#optional-dependencies).
=======
4.      *(Optional)* Specify required dependencies in the `Dockerfile`. Edit the `Dockerfile` and uncomment the corresponding line for each dependency you want to add. For more information, see [Optional Dependencies](#optional-dependencies).
>>>>>>> 0bc163a43257f6223a60e5d9fc9cc661bbe55756

## Step 5. Build Image
Use the `docker build` command to build the image, using ```.``` to specify this folder. Run the command from the root directory of the cloned repository. Use a command of the form:
```
docker build -t matlab:r2020a --build-arg LICENSE_SERVER=27000@MyServerName .
```
<<<<<<< HEAD
**Note**: The `LICENSE_SERVER` build argument is NOT used during the build but by supplying it here during build it gets
incorporated into the container so that MATLAB in the container knows how to acquire a license when the container is run

To build a previous version of MATLAB, for example `Dockerfile.R2019b`, use a command of the form 
```
docker build -f Dockerfile.R2019b -t matlab:r2019b --build-arg MATLAB_RELEASE=R2019b --build-arg LICENSE_SERVER=27000@MyServerName .
```
You must supply a tag for the image using the `-t` option, for example, `matlab:r2020a`. The tag names the repository for later use and deployment. 
Specify the location of the network licence manager using `--build-arg LICENSE_SERVER=27000@MyServerName`. Replace `27000@MyServerName` with the port and location of your license manager. Alternatively, you can use a `license.dat` or `network.lic` file to provide the location of the license manager. For more information, see [Use a License File to Build Image](#use-a-license-file-to-build-image).

For the R2019b Dockerfile you must also specify the MATLAB release using `--build-arg MATLAB_RELEASE=R20xxx`, where `R20xxx` refers to a MATLAB release you are trying to build. 
=======
```
**Note**: The `LICENSE_SERVER` build argument is NOT used during the build but by supplying it here during build it gets
incorporated into the container so that MATLAB in the container knows how to acquire a license when the container is run

To build a previous version of MATLAB, for example `Dockerfile.R2019b`, use a command of the form
```
docker build -f Dockerfile.R2019b -t matlab:r2019b --build-arg MATLAB_RELEASE=R2019b --build-arg LICENSE_SERVER=27000@MyServerName .
```
You must supply a tag for the image using the `-t` option, for example, `matlab:r2020a`. The tag names the repository for later use and deployment.
Specify the location of the network licence manager using `--build-arg LICENSE_SERVER=27000@MyServerName`. Replace `27000@MyServerName` with the port and location of your license manager. Alternatively, you can use a `license.dat` or `network.lic` file to provide the location of the license manager. For more information, see [Use a License File to Build Image](#use-a-license-file-to-build-image).

For the R2019b Dockerfile you must also specify the MATLAB release using `--build-arg MATLAB_RELEASE=R20xxx`, where `R20xxx` refers to a MATLAB release you are trying to build.
>>>>>>> 0bc163a43257f6223a60e5d9fc9cc661bbe55756

## Step 6. Run Container
Use the `docker run` command to run the container. Use a command of the form:
```
docker run -it --rm matlab:r2020a
```
- `-it` option runs the container interactively.
- `--rm` option automatically removes the container on exit.

Any extra arguments after the container tag are passed directly as command line arguments to the MATLAB process inside the container. For example, the following command prints `hello world` in MATLAB and then exits.
```
docker run -it --rm matlab:r2020a -r "disp('hello world');exit"
```

## Optional Dependencies
For some workflows and toolboxes, you must specify dependencies. You must do this if you want to do any of the following tasks.
- Install extended localization support for MATLAB
- Play media files from MATLAB
- Run a network license manager inside the container
- Generate code from Simulink
- Use mex functions with gcc, g++, or gfortran
- Use the MATLAB Engine API for C and Fortran
- Use the Polyspace 32-bit tcc compiler

Edit the `Dockerfile` and uncomment the relevant lines to install the dependencies.
## Use a License File to Build Image
If you have a `license.dat` file from your license administrator, you can use this file to provide the location of the license manager for the container image.
<<<<<<< HEAD
1. Open the `license.dat` file. Copy the `SERVER` line into a new text file. 
=======
1. Open the `license.dat` file. Copy the `SERVER` line into a new text file.
>>>>>>> 0bc163a43257f6223a60e5d9fc9cc661bbe55756
2. Beneath it, add `USE_SERVER`. The file should now look something like this:
```
SERVER Server1 0123abcd0123 12345
USE_SERVER
```
3. Save the new text file as `network.lic` in the root directory of the cloned repository.
4. Open the `Dockerfile`, and comment the line `ENV MLM_LICENSE_FILE`
5. Uncomment the line `ADD network.lic /usr/local/MATLAB/$MATLAB_RELEASE/licenses/`
6. Run the docker build command without the `--build-arg LICENSE_SERVER=27000@MyServerName` option. Use a command of the form
```
docker build -t matlab:r2020a .
```
For more information about license files, see [What are the differences between the license.lic, license.dat, network.lic, and license_info.xml license files?](https://www.mathworks.com/matlabcentral/answers/116637-what-are-the-differences-between-the-license-lic-license-dat-network-lic-and-license_info-xml-lic)
<<<<<<< HEAD
=======
**Edit a file, create a new file, and clone from Bitbucket in under 2 minutes**

When you're done, you can delete the content in this README and update the file with details for others getting started with your repository.

*We recommend that you open this README in another tab as you perform the tasks below. You can [watch our video](https://youtu.be/0ocf7u76WSo) for a full demo of all the steps in this tutorial. Open the video in a new tab to avoid leaving Bitbucket.*

---

## Edit a file

You’ll start by editing this README file to learn how to edit a file in Bitbucket.

1. Click **Source** on the left side.
2. Click the README.md link from the list of files.
3. Click the **Edit** button.
4. Delete the following text: *Delete this line to make a change to the README from Bitbucket.*
5. After making your change, click **Commit** and then **Commit** again in the dialog. The commit page will open and you’ll see the change you just made.
6. Go back to the **Source** page.

---

## Create a file

Next, you’ll add a new file to this repository.

1. Click the **New file** button at the top of the **Source** page.
2. Give the file a filename of **contributors.txt**.
3. Enter your name in the empty file space.
4. Click **Commit** and then **Commit** again in the dialog.
5. Go back to the **Source** page.

Before you move on, go ahead and explore the repository. You've already seen the **Source** page, but check out the **Commits**, **Branches**, and **Settings** pages.

---

## Clone a repository

Use these steps to clone from SourceTree, our client for using the repository command-line free. Cloning allows you to work on your files locally. If you don't yet have SourceTree, [download and install first](https://www.sourcetreeapp.com/). If you prefer to clone from the command line, see [Clone a repository](https://confluence.atlassian.com/x/4whODQ).

1. You’ll see the clone button under the **Source** heading. Click that button.
2. Now click **Check out in SourceTree**. You may need to create a SourceTree account or log in.
3. When you see the **Clone New** dialog in SourceTree, update the destination path and name if you’d like to and then click **Clone**.
4. Open the directory you just created to see your repository’s files.

Now that you're more familiar with your Bitbucket repository, go ahead and add a new file locally. You can [push your change back to Bitbucket with SourceTree](https://confluence.atlassian.com/x/iqyBMg), or you can [add, commit,](https://confluence.atlassian.com/x/8QhODQ) and [push from the command line](https://confluence.atlassian.com/x/NQ0zDQ).
>>>>>>> cdfd97d96c8855145c38bb35e3d9b50f5a5e5986
=======
>>>>>>> 0bc163a43257f6223a60e5d9fc9cc661bbe55756
