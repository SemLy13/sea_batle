Unit TasksMod;

Interface
uses Objects, Drivers, Dialogs,MsgBox, BA;

const
  TaskStart = 100;
  cmGoToSecond = 101;
  cmGoToThird = 102;
  cmExit = 103;
  
var
  Slov:array[1..26] of char;

type
  PTaskDialog = ^TTaskDialog; //Предок от которого все наследуется
  TTaskDialog = object(TDialog)
    constructor Init(R : TRect; Caption : string);
    procedure HandleEvent(var Event : TEvent); virtual;
  private
    procedure Action; virtual;
  end;
  
  PFirstTaskDialog = ^TFirstTaskDialog; 
  TFirstTaskDialog = object(TTaskDialog)
    sIn: PInputLine;
    constructor Init;
  private
    procedure Action; virtual;
  end;
  
  PSecondTaskDialog = ^TSecondTaskDialog; 
  TSecondTaskDialog = object(TTaskDialog)
    sInLetter, sInNumber: PInputLine;
    constructor Init;
    procedure HandleEvent(var Event : TEvent); virtual;
  private
    procedure Action; virtual;
    procedure ShowResults(res:integer);
  end;
  


Implementation

function IntToStr(n : integer) : string;
var s : string;
begin
  Str(n, s);
  IntToStr := s;
end;

function StrToInt(s : string) : integer;
var
  i, Code : integer;
begin
  Val(s, i, Code);
  StrToInt := i;
end;

/////////////////////////////////////////////////////////////////////////////////

constructor TTaskDialog.Init(R : TRect; Caption : string);
begin
  inherited Init(R, Caption);
end;

procedure TTaskDialog.Action;
begin
  Abstract;
end;

procedure TTaskDialog.HandleEvent(var Event : TEvent);
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmGoToSecond : begin Action; Close; end;
      cmExit : begin Close; ClearEvent(Event); end;
    end;
  end;
end;

/////////////////////////////////////////////////////////////////////////////////

constructor TFirstTaskDialog.Init; 
var
  R : TRect;
  x,y:integer;
begin
  R.Assign(15, 5, 47, 14);
  inherited Init(R, 'Input: ');
  x:=3;
  y:=3;
  R.Assign(x, y, x+18,y+1);
  Insert(New(PStaticText, Init(R, 'Input Size Grid: ')));
  
  x:=x+18;
  R.Assign(x,y,x+7,y+1);
  sIn := New(PInputLine, Init(R, 2)); 
  Insert(sIn); 
  
  x:=3;
  y:=y+2;
 
  R.Assign(x,y,x+11,y+2);
  Insert(New(PButton, Init(R, 'Close', cmExit, bfNormal)));
  x:=x+15;
  R.Assign(x,y,x+11,y+2);
  Insert(New(PButton, Init(R, 'Continue', cmGoToSecond, bfNormal)));
end;

procedure TFirstTaskDialog.Action;

var
  s:string;
begin
  sIn^.GetData(s);
  GridSize:=StrToInt(s);
  if GridSize = 0
  then GridSize:=10;
  Start();
end;
/////////////////////////////////////////////////////////////////////////////////

constructor TSecondTaskDialog.Init; 
var
  R : TRect;
  i,j,x,y,x1,y1:integer;
begin
  For i:=1 to 26 do
    slov[i]:=char(64+i);
  R.Assign(1, 2, 77, 33);
  inherited Init(R, 'Results');
  x:=3;
  y:=3;
  
  R.Assign(x, y, x+18,y+1);
  Insert(New(PStaticText, Init(R, 'Input Coord: ')));
  
  x:=x+18;
  R.Assign(x,y,x+4,y+1);
  sInLetter := New(PInputLine, Init(R, 1)); 
  Insert(sInLetter); 
  
  x:=x+5;
  R.Assign(x,y,x+5,y+1);
  sInNumber := New(PInputLine, Init(R, 2)); 
  Insert(sInNumber); 
  
  x:=x+8;
  R.Assign(x,y,x+7,y+2);
  Insert(New(PButton, Init(R, 'Go', cmGoToThird, bfNormal)));
  

  y:=y+4;
  y1:=y;
  x:=3;
  R.Assign(x, y, x+2,y+1);
  Insert(New(PStaticText, Init(R, ' ')));
  x:=x+3;
  For i:=1 to GridSize do
  begin
    R.Assign(x, y, x+2,y+1);
    Insert(New(PStaticText, Init(R, IntToStr(i))));
    x:=x+3;
  end;
  
  For j:=1 to GridSize do
  begin
    y:=y+2;
    x:=3;
    R.Assign(x, y, x+2,y+1);
    Insert(New(PStaticText, Init(R, Slov[j])));
    x:=x+3;
    For i:=1 to GridSize do
    begin
      R.Assign(x, y, x+2,y+1);
      case PlayerField[j,i] of
        -1: Insert(New(PStaticText, Init(R, ' '))); //Ничего
        0: Insert(New(PStaticText, Init(R, '#'))); //0 Значит там корабль
        1: Insert(New(PStaticText, Init(R, '*'))); //1 куда стреляли (мимо)
        2: Insert(New(PStaticText, Init(R, '-'))); //2 куда стреляли (попали)
      end;
      x:=x+3;
    end;
  end;
  
  /////////
  
  y:=y1;
  x:=x+5;
  x1:=x;
  R.Assign(x, y, x+2,y+1);
  Insert(New(PStaticText, Init(R, ' ')));
  x:=x+3;
  For i:=1 to GridSize do
  begin
    R.Assign(x, y, x+2,y+1);
    Insert(New(PStaticText, Init(R, IntToStr(i))));
    x:=x+3;
  end;
  
  For j:=1 to GridSize do
  begin
    y:=y+2;
    x:=x1;
    R.Assign(x, y, x+2,y+1);
    Insert(New(PStaticText, Init(R, Slov[j])));
    x:=x+3;
    For i:=1 to GridSize do
    begin
      R.Assign(x, y, x+2,y+1);
      case EnemyTrackingField[j,i] of
        -1: Insert(New(PStaticText, Init(R, ' '))); //Ничего
        0: Insert(New(PStaticText, Init(R, '*'))); //0 Значит мимо
        1: Insert(New(PStaticText, Init(R, '+'))); //1 Попали в корабль
      end;
      x:=x+3;
    end;
  end;
end;

procedure TSecondTaskDialog.HandleEvent(var Event : TEvent);
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand then
  begin
    case Event.Command of
      cmGoToThird: begin Action; Close; end;
    end;
  end;
end;

procedure TSecondTaskDialog.Action;
var
  x,y,i:integer;
  s:string;
begin
  sInLetter^.GetData(s);
  For i:=1 to GridSize do
    If s = Slov[i]
    then x:=i;
  sInNumber^.GetData(s);
  y:=StrToInt(s);
  
  If (x > 0) and (y>0) and (x <= GridSize) and (y <= GridSize)
  then begin
    isPlayerTurn:=true;
    PlayerTurn(x,y);
    If (GameResults() = 1)
    then ShowResults(1);
  end
  else isPlayerTurn:=false;
  
  If not isPlayerTurn 
  then begin
    ComputerTurn();
    If (GameResults() = 2)
      then ShowResults(2);
  end;
  
end;

procedure TSecondTaskDialog.ShowResults(res:integer); //Процедура алерта, вызывается, когда время вышло
begin
  if (res = 1)
  then
    MessageBox(
      #3'Results:'#13+#13+
      #3'You Win!',
      nil,mfInformation or mfOkButton)
  else
    MessageBox(
      #3'Results:'#13+#13+
      #3'You Lose!',
      nil,mfInformation or mfOkButton)
end;

end.