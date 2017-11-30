unit IconChanger;

interface

uses windows, Classes;

var
  PVFile : PByte;

type
  ICONINFORMATION = packed record
  width  : Byte;
  height : Byte;
  colorc : Byte;
  res    : Byte;
  planes : Word;
  bitcnt : Word;
  bytes  : DWORD;
  offset : DWORD;
  end;

  ICONHEADER = packed record
  res    : Word;
  restype: Word;
  count  : Word;
  end;

  ICONDIRENTRYCOMMON = packed record
  width  : Byte;
  height : Byte;
  colorc : Byte;
  res    : Byte;
  planes : Word;
  bitcnt : Word;
  bytes  : DWORD;
  id     : Word;
  end;

function UpdateApplicationIcon(srcicon : string; destexe : string) : Boolean;

implementation

function UpdateApplicationIcon(srcicon : string; destexe : string) : Boolean;
var
  i : Integer;
  Src, grpic : TMemoryStream;
  id : ICONINFORMATION;
  ih : ICONHEADER;
  ic : ICONDIRENTRYCOMMON;
  hinst : LongInt;
  oldentry : Int64;
begin
  Result := False;
  Src := TMemoryStream.Create;
  grpic := TMemoryStream.Create;
  Src.LoadFromFile(srcicon);
  Src.Read(ih, SizeOf(ICONHEADER));
  grpic.Write(ih, SizeOf(ih));
  oldentry := Src.Position;
  for i := 0 to ih.count - 1 do
  begin
    Src.Position := oldentry;
    hinst := BeginUpdateResource(PChar(destexe), False);
    Src.Read(id, SizeOf(ICONINFORMATION));
    ic.width := id.width;
    ic.height := id.height;
    ic.colorc := id.colorc;
    ic.res := id.res;
    ic.planes := id.planes;
    ic.bitcnt := id.bitcnt;
    ic.id := i;
    ic.bytes := id.bytes;
    grpic.Write(ic, SizeOf(ic));
    GetMem(PVFile, id.bytes);
    oldentry := Src.Position;
    Src.Seek(id.offset, soFromBeginning);
    Src.Read(PVFile^, id.bytes);
    UpdateResource(hinst, RT_ICON, MAKEINTRESOURCE(i), LANG_NEUTRAL, PVFile, id.bytes);
    EndUpdateResource(hinst, False);
  end;
  hinst := BeginUpdateResource(PChar(destexe), False);
  UpdateResource(hinst, RT_GROUP_ICON, MAKEINTRESOURCE(0), LANG_NEUTRAL, grpic.Memory, grpic.Size);
  EndUpdateResource(hinst, False);
  grpic.Free;
  Src.Free;
end;

end.
