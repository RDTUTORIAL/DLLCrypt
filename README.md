# 🔒 DLLCrypt - DLL Steganography Tool

A PowerShell-based steganography tool that allows you to hide encrypted files inside legitimate DLL files. This project demonstrates how data can be covertly embedded within binary files while maintaining their original functionality.

## ⚠️ Disclaimer

**This project is for educational and research purposes only.** The author does not encourage or condone the use of this tool for any malicious activities. Users are solely responsible for ensuring their use of this tool complies with applicable laws and regulations in their jurisdiction.

- This tool should only be used on systems you own or have explicit permission to test
- Do not use this tool to hide malicious content or bypass security measures
- Always respect privacy and security policies
- The author assumes no liability for any misuse of this software

## 🎯 Features

- **Steganography**: Hide files inside legitimate DLL files
- **AES-256 Encryption**: Strong encryption with PBKDF2 key derivation
- **Minimal Footprint**: Modified DLLs remain functional and appear normal
- **Password Protection**: Files are encrypted with user-defined passwords
- **Easy Extraction**: Simple command-line interface for file recovery

## 🚀 Quick Start

### Prerequisites
- Windows PowerShell 5.0 or later
- Execution policy allowing script execution

### Basic Usage

#### 1. Hide a file inside a DLL
```powershell
.\src\encoder.ps1 -dllPath "samples\dxcorehelper.dll" -secretFilePath "secret.txt" -password "MySecretPassword123" -outputDllPath "output\dxcorehelper_modified.dll"
```

#### 2. Extract the hidden file
```batch
.\src\launcher.bat "output\dxcorehelper_modified.dll" "MySecretPassword123"
```

Or directly with PowerShell:
```powershell
.\src\decoder.ps1 -encodedDllPath "output\dxcorehelper_modified.dll" -password "MySecretPassword123"
```

## 🔧 How it works

Uses AES-256 encryption with PBKDF2 key derivation to hide files inside DLL binaries. The tool appends encrypted data after a signature marker, keeping the original DLL functionality intact.

## 🛡️ Stealth Tips

### System DLL Camouflage
For better stealth, consider using these common system DLL names:
- `msvcr120.dll`, `msvcp140.dll` - Visual C++ redistributables
- `api-ms-win-*.dll` - Windows API sets  
- `d3d11.dll`, `dxgi.dll` - DirectX components
- `kernel32.dll`, `user32.dll` - Core Windows DLLs (⚠️ be careful!)
- `sqlite3.dll`, `libcurl.dll` - Common third-party libraries

### Placement Strategy
- **System32/SysWOW64**: High privilege but heavily monitored
- **Program Files**: Blend with existing applications
- **AppData/Temp**: Less suspicious for "temporary" components
- **Game/Software folders**: Hide among legitimate DLLs

### Additional Stealth
- Match file timestamps with nearby legitimate files
- Keep file sizes reasonable (avoid suspiciously large DLLs)
- Use legitimate DLL signatures when possible
- Consider multiple small files instead of one large payload

## 🔍 Detection and Mitigation

This technique may be detected by:
- File size analysis (comparing with known good DLLs)
- Entropy analysis of the file tail
- Signature-based detection of the marker
- Advanced malware analysis tools

## 🤝 Contributing

This is an experimental project. If you have suggestions for improvements or find bugs, please open an issue or submit a pull request.

## 🙏 Acknowledgments

- Thanks to the cybersecurity community for research on steganography techniques
- Inspired by various file hiding and data exfiltration research

---

**Remember**: Use responsibly and only for legitimate purposes! 🔐
