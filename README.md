# XcodeIssueGenerator

An executable that can be called from a Run Script Build Phase that makes comments such as ```// TODO:``` or ```// SERIOUS:``` appear in Xcode's Issue Navigator giving them project-wide visibility.

- Works in Swift files.
- An upside of using this program as compared to ```#warning``` pragmas available to Objective-C is we can keep "treat warnings as errors" on in the host project build settings since this executable runs post-build.
- Comments can be configured as warnings or errors. Error-producing comments stop the build from succeeding.
- Warning or error behavior for comments can be configured differently per build configuration—you can have a ```// TODO:``` be a warning in DEBUG and be an error in RELEASE for instance.


## Setup
Download the latest [release](https://github.com/doubleencore/XcodeIssueGenerator/releases) or build the project yourself. Copy the XcodeIssueGenerator executable to your ```/usr/local/bin``` directory and make it executable: ```chmod +x /usr/local/bin/XcodeIssueGenerator```. Call the XcodeIssueGenerator executable from a Run Script build phase.

### Adding a Run Script Build Phase
Select the target on which to run XcodeIssueGenerator, select Build Phases, and select the "+" icon to add a new Run Script phase. Then put in a call to XcodeIssueGenerator as in the example below.

### Example Run Script
```
if which XcodeIssueGenerator >/dev/null; then
    # Mark WARNINGs, SERIOUSs, and TODOs as warnings in DEBUG builds excluding the Vendor and Third Party directories.
    XcodeIssueGenerator -b DEBUG -w "WARNING, SERIOUS, TODO" -x "Vendor/, Third Party/"

    # Mark WARNINGs and SERIOUSs as warnings and TODOs as errors in RELEASE builds excluding the Vendor and Third Party directories.
    XcodeIssueGenerator -b RELEASE -w "WARNING, SERIOUS" -e TODO -x "Vendor/, Third Party/"
else
    echo "warning: XcodeIssueGenerator is not installed."
fi
```

With the Run Script above, we'll show all comments in Issue Navigator as warnings in DEBUG builds. In RELEASE builds, we'll mark TODOs as errors as a way to block unfinished work from becoming part of a release build.

### Options

* -w warnings tags list (required if no -e)
* -e error tags list (required if no -w)
* -b build configuration (required)
* -x exclude directories (optional)

Tags can be any string. Multiple tags should be separated by commas. Build configurations should match those in the host Xcode project.

## License

XcodeIssueGenerator is released under the MIT license. See LICENSE for details.
