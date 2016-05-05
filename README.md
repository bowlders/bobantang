##The Brand New BoBanTang!!

After you download the project from branch **dev**(latest version will be launched onto this branch), you need to do some work before the project gets ready.

* In the Terminal, run `cd workspace` then `git submodule add https://github.com/pixelglow/ZipZap.git`.
* In the workspace, choose the *File > Add Files to "workspace"* menu item, then within the *ZipZap-master* directory pick the *ZipZap.xcodeproj* Xcode project.
* In *Build Phases > Link Binary With Libraries*, add:
    * libZipZap.a;
    * ImageIO.framework;
    * Foundation.framework;
    * libz.dylib;
* Under *Build Settings > Search Paths > Header Search Paths*, add *../ZipZap*.

**Congratulations!** You can now build, test or analyze our BoBanTang!:)
