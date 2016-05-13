# XcodeIssueGenerator

An executable that can be placed in a Run Script Build Phase that marks comments like ```// TODO:``` or ```// SERIOUS:``` as warnings or errors so they display in the Xcode Issue Navigator. Warning or error behavior for comments can be configured differently per build configuration—you can have a ```// TODO:``` be a warning in DEBUG and be an error in RELEASE for instance. An upside of using this program as compared to something like ```#warning``` pragmas is we can keep "treat warnings as errors" on in the host project build settings since this executable runs post-build.

## Setup
Download the latest [release](https://github.com/doubleencore/XcodeIssueGenerator/releases) or build the project yourself. Copy the XcodeIssueGenerator executable to your ```/usr/local/bin``` directory and make it executable: ```chmod +x /usr/local/bin/XcodeIssueGenerator```. Call the XcodeIssueGenerator executable from a Run Script build phase.

### Adding a Run Script Build Phase
Select the target on which to run XcodeIssueGenerator, select Build Phases, and select the "+" icon to add a new Run Script phase. Then put in a call to XcodeIssueGenerator as in the example below.

### Example Run Script
```
# Mark WARNINGs and SERIOUSs as warnings and TODOs as errors in RELEASE builds excluding the Vendor and Third Party directories.

if which XcodeIssueGenerator >/dev/null; then
    /usr/local/bin/XcodeIssueGenerator -b RELEASE -w "WARNING, SERIOUS" -e TODO -x "Vendor/, Third Party/"
else
    echo "warning: XcodeIssueGenerator is not installed."
fi
```

### Options

* -w warnings tags list (required if no -e)
* -e error tags list (required if no -w)
* -b build configuration (required)
* -x exclude directories (optional)

Tags can be any string. Multiple tags should be separated by commas. Build configurations should match those in the host Xcode project.

## License

XcodeIssueGenerator is released under the MIT license. See LICENSE for details.
