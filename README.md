# sharedLaravel
This tool Helps you convert your Laravel project to a shared Host project, so you can upload it directly to your remote shared host.


### HOW TO USE

  - If you project folder is `/home/USER/projects/MyLaravelProject`
    Then copy this tool inside `/home/USER/projects`
  - Then in the terminal go to the same folder
    ```sh
    $ cd /home/USER/projects
    ```
  - Then execute this command
    ```sh
    $ ./sharedLaravel.sh
    ```


### Future Features
  - Read the steps from a JSON file to speed up the process
  - Generate sub parts (EXP: Genarate only Controller & dependencies) via commandline
  - Upload the generated files to a server via FTP or SFTP
  - Automatically detect changes and regenerate the Project
  - Export the local Project Database and inject it as migrations in the generated project
