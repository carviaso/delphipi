unit CompilationData;
interface
uses Classes, PackageInfo, JclBorlandTools;

type
  TCompilationData = class(TInterfacedObject)
  private
    fBaseFolder: String;
    fInstallation: TJclBorRADToolInstallation;
    fPackageList: TPackageList;
    fHelpFiles: TStringList;
    fSourceFilePaths: TStringList;
    fPattern: String;
    fDCPOutputFolder: string;
    fBPLOutputFolder: string;

    procedure SetPackageList(const aPackageList: TPackageList);
    procedure SetSourceFilePaths(const aPathList: TStringList);
  public
    constructor Create;
    destructor Destroy; override;
    //TODO: can be moved
    procedure ResolveSourcePaths;
    procedure AddSourcePathsToIDE;
    
    property Pattern: String read fPattern write fPattern;
    property Installation: TJclBorRADToolInstallation read fInstallation write fInstallation;
    property BaseFolder: String read fBaseFolder write fBaseFolder;
    property HelpFiles: TStringList read fHelpFiles;
    property PackageList: TPackageList read fPackageList write SetPackageList;
    property SourceFilePaths : TStringList read fSourceFilePaths write SetSourceFilePaths;
    property DCPOutputFolder: string read fDCPOutputFolder write fDCPOutputFolder;
    property BPLOutputFolder: string read fBPLOutputFolder write fBPLOutputFolder;
  end;

implementation

uses JclFileUtils,SysUtils;

constructor TCompilationData.Create;
begin
  fPattern := '*.dpk';
  fPackageList := TPackageList.Create;
  fHelpFiles := TStringList.Create;
  fSourceFilePaths := TStringList.Create;
end;

destructor TCompilationData.Destroy;
begin
  fPackageList.Free;
  fHelpFiles.Free;
  fSourceFilePaths.Free;
  inherited;
end;

procedure TCompilationData.SetPackageList(const aPackageList: TPackageList);
begin
  fPackageList.Free;
  fPackageList := aPackageList;
end;

procedure TCompilationData.SetSourceFilePaths(const aPathList: TStringList);
begin
  fSourceFilePaths := aPathList;
end;

procedure TCompilationData.ResolveSourcePaths;
var
  i : integer;
  j: Integer;
  files, containedFiles  : TStringList;
begin
  Assert(assigned(SourceFilePaths));
  fSourceFilePaths.Clear;

  files := TStringList.Create;
  files.Sorted := true;
  files.Duplicates := dupIgnore;

  containedFiles := TStringList.Create;
  containedFiles.Sorted := true;
  containedFiles.Duplicates := dupIgnore;

  SourceFilePaths.Sorted := true;
  SourceFilePaths.Duplicates := dupIgnore;
     
  for i := 0 to fPackageList.Count - 1 do begin
    SourceFilePaths.Add(ExtractFilePath(fPackageList[i].FileName));
    for j := 0 to fPackageList[i].ContainedFileList.Count - 1 do
      containedFiles.Add(ExtractFileName(fPackageList[i].ContainedFileList[j]));
  end;

  AdvBuildFileList(fPackageList.InitialFolder+'\*.pas',
           faAnyFile,
           files,
           amAny,
           [flFullnames, flRecursive],
           '', nil);

  for I := 0 to files.count - 1 do begin
    if containedFiles.IndexOf(ExtractFileName(files[i])) > 0 then
      SourceFilePaths.Add(ExtractFilePath(files[i]));
  end;
end;


procedure TCompilationData.AddSourcePathsToIDE;
var
  path : string;
begin
  Assert(assigned(SourceFilePaths));
  for path in SourceFilePaths do
    Installation.AddToLibrarySearchPath(path);
end;

end.