; Inno Setup 6 script for Simple Live.
; The workflow passes MyAppVersion and DistDir via /D defines.

#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif
#ifndef DistDir
  #define DistDir "..\..\..\..\dist"
#endif

[Setup]
AppId={{B5E5D6B2-6F1A-4C2E-9D3A-7C8B1E2F4A60}
AppName=Simple Live
AppVersion={#MyAppVersion}
AppVerName=Simple Live {#MyAppVersion}
AppPublisher=xiaoyaocz
AppPublisherURL=https://github.com/xiaoyaocz/dart_simple_live
DefaultDirName={autopf}\Simple Live
DefaultGroupName=Simple Live
DisableProgramGroupPage=yes
OutputDir={#DistDir}
OutputBaseFilename=SimpleLive-{#MyAppVersion}-windows-x64-setup
SetupIconFile=..\..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\simple_live_app.exe
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
MinVersion=10.0
PrivilegesRequired=admin
PrivilegesRequiredOverridesAllowed=dialog

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Simple Live"; Filename: "{app}\simple_live_app.exe"
Name: "{autodesktop}\Simple Live"; Filename: "{app}\simple_live_app.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\simple_live_app.exe"; Description: "{cm:LaunchProgram,Simple Live}"; Flags: nowait postinstall skipifsilent
