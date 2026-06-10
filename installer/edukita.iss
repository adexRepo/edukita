#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif

#define MyAppName "Edukita"
#define MyAppPublisher "Ecnics"
#define MyAppExeName "edukita.exe"

[Setup]
AppId={{8FE51C2F-8AE1-49F4-96D6-7E4D5B503B8B}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=output
OutputBaseFilename=EdukitaSetup_v{#MyAppVersion}
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
PrivilegesRequired=admin
CloseApplications=yes
RestartApplications=no
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional shortcuts:"; Flags: unchecked

[Dirs]
Name: "{commonappdata}\Edukita"
Name: "{commonappdata}\Edukita\database"
Name: "{commonappdata}\Edukita\backup"
Name: "{commonappdata}\Edukita\exports"
Name: "{commonappdata}\Edukita\logs"
Name: "{commonappdata}\Edukita\attachments"
Name: "{commonappdata}\Edukita\attachments\student_photos"
Name: "{commonappdata}\Edukita\attachments\documents"
Name: "{commonappdata}\Edukita\updates"

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent
