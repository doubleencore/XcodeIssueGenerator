# XcodeIssueGenerator

An executable that can be placed in a Run Script build phase that marks comments like ```// TODO:``` or ```// FIXME:``` as warnings or errors so they display in the Xcode Issue Navigator. Warning or error behavior for comments can be configured differently per build configuration—you can have a ```// CRITICAL:``` be a warning in DEBUG and be an error in RELEASE for instance. An upside of using this program as compared to something like warning pragmas is we can keep "treat warnings as errors" on in the host project build settings since this executable runs post-build.

## Setup
Copy XcodeIssueGenerator to the project root or a location of your choosing. Call the XcodeIssueGenerator executable from a Run Script build phase.

### Adding a Run Script Build Phase
Select the target on which to run XcodeIssueGenerator, select Build Phases, and select the + icon to add a new Run Script phase. Then put in a call to XcodeIssueGenrator as in the example below.

## Example
```
# Mark TODOs and WARNINGs as warnings and CRITICALs as errors in Release builds excluding the Vendor and Third Party directories.
./XcodeIssueGenerator -w "TODO, WARNING" -e CRITICAL -b Release -x "Vendor/, Third Party/"
```

### Options

* -w warnings tags list (required if no -e)
* -e error tags list (required if no -w)
* -b build configuration (required)
* -x exclude directories (optional)

Tags can be any string. Multiple tags should be separated by commas. Build configurations should match those in the host Xcode project.