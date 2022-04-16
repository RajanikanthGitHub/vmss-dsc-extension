Configuration MMAgent {
 
    # Import the module that contains the File resource.
    Import-DscResource -ModuleName PsDesiredStateConfiguration
 
    Node 'localhost' {
 
        # The File resource can ensure the state of files, or copy them from a source to a destination with persistent updates.
        File HelloWorld {
            DestinationPath = "C:\Temp\HelloWorld.txt"
            Ensure = "Present"
            Contents   = "Hello World from DSC!"
        }
    }
}