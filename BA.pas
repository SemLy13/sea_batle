
Unit Ba;
Interface 
procedure Start;
procedure PlayerTurn (x,y:integer);
procedure ComputerTurn;
function GameResults:integer;
type TGrid = array[1..18,1..18] of ShortInt;
var
  GridSize,Step,PlayerShipsCount, ComputerShipsCount: integer;
  isPlayerTurn:boolean;
  EnemyPlayingField: TGrid;
  PlayerField: TGrid;
  EnemyTrackingField: TGrid;
    Px, Py, Way: Integer;
    
const d: array[1..8,1..2] of Integer =((0,1),
                                       (1,0),
                                       (0,-1),
                                       (-1,0),
                                       (1,1),
                                       (-1,1),
                                       (1,-1),
                                       (-1,-1));

implementation
 

uses CRT;

procedure Init (var Field: TGrid);
var X, Y: Integer;
begin
  Randomize;
  for X := 1 to GridSize do
    for Y := 1 to GridSize do
      Field[X,Y] := -1;
end;

function IsEmpty (x, y: Integer; Field: TGrid): Boolean;
var i: Integer;
    dx, dy: Integer;
begin
  if (x > 0) and (x < GridSize+1) and (y > 0) and (y < GridSize+1) and (Field[x,y] = -1) then
  begin
    for i := 1 to 8 do
    begin
      dx := x + d[i,1];
      dy := y + d[i,2];
      if (dx > 0) and (dx < GridSize+1) and (dy > 0) and (dy < GridSize+1) and (Field[dx,dy] > -1) then
      begin
        IsEmpty := False;
        Exit;
      end;
    end;
    IsEmpty := True;
  end
  else IsEmpty := False;
end;

procedure DeployShips (var Field: TGrid);
var N, M, i: Integer;
    x, y, kx, ky: Integer;
    CanBeDeployedHere: Boolean;
begin
  Randomize;
  Init (Field);
  for N := 3 downto 0 do
    for M := 0 to 3 - N do
    repeat
      x := Random (GridSize) + 1;
      y := Random (GridSize) + 1;
      kx := Random (2);
      if kx = 0 then ky := 1
      else ky := 0;
      CanBeDeployedHere := True;
      for i := 0 to N do
        if not IsEmpty (x + kx * i, y + ky * i, Field) then CanBeDeployedHere := False;
      if CanBeDeployedHere = true then
        for i := 0 to N do
          Field[x+kx*i,y+ky*i] := 0;
    until CanBeDeployedHere = true;
end;

procedure Start;
begin
  Init (EnemyTrackingField);
  DeployShips (EnemyPlayingField);
  DeployShips (PlayerField);
  Step:=1;
  PlayerShipsCount:=10; 
  ComputerShipsCount:=10;
end;

function GameResults: integer; //1-победил игрок,2 - компьютер
begin
  If (ComputerShipsCount = 0)
  then begin
    GameResults:=1;
    exit;
  end;
  If (PlayerShipsCount = 0)
  then begin
    GameResults:=2;
    exit;
  end;
  GameResults:=0;
end;

function IsEmptyWhenKill (x, y: Integer;var Field:TGrid): Boolean;
var i: Integer;
    dx, dy: Integer;
begin
  if (x > 0) and (x < GridSize+1) and (y > 0) and (y < GridSize+1) then
  begin
    for i := 1 to 8 do
    begin
      dx := x + d[i,1];
      dy := y + d[i,2];
      if (dx > 0) and (dx < GridSize+1) and (dy > 0) and (dy < GridSize+1) and (Field[dx,dy] = 0) then
      begin
        IsEmptyWhenKill := False;
        Exit;
      end;
    end;
    IsEmptyWhenKill := True;
  end
  else IsEmptyWhenKill := False;
end;

procedure InjuryShip (x, y: Integer);
var i: Integer;
    dx, dy: Integer;
begin
  if (x > 0) and (x < GridSize+1) and (y > 0) and (y < GridSize+1) then
  begin
    for i := 1 to 8 do
    begin
      dx := x + d[i,1];
      dy := y + d[i,2];
      If EnemyTrackingField[dx,dy] = -1 
      then EnemyTrackingField[dx,dy]:=2;
    end;
  end;
end;

procedure KillShip (x, y: Integer);
var i,j: Integer;
begin
  For i:=1 to GridSize do
    For j:=1 to GridSize do
      If (EnemyTrackingField[i,j] = 2) 
      then EnemyTrackingField[i,j]:=0;
end;

procedure PlayerTurn (x,y:integer);

begin

    If (GameResults > 0)
    then exit;
    
    If (EnemyPlayingField[x,y] = 0)
    then begin
      EnemyPlayingField[x,y]:=1;
      EnemyTrackingField[x,y]:=1;
      InjuryShip(x,y); //Сначала помечаем все точки вокруг попадания, кроме тех, где находятся корабли, ставим значение 2 в EnemyTrackingField
      If IsEmptyWhenKill(x,y,EnemyPlayingField) //Проверяем убили ли корабль или только ранили
      then begin
        KillShip(x,y); //Все помеченные точки превращаем, тип что туда стрелять уже не надо и пользователь видит, что убил корабль
        ComputerShipsCount:=ComputerShipsCount - 1;
      end;
    end
    else begin
      isPlayerTurn:=false;
    end;

end;  

function TestShotComp(x,y:integer): Boolean;
Begin
  If PlayerField[x,y] = 0
  then begin
    TestShotComp:=true;
    PlayerField[x,y]:=2;
  end
  else begin
    TestShotComp:=false;
    If PlayerField[x,y] = -1
    then PlayerField[x,y]:=1;
  end;
end;

procedure Step1(var x,y:integer; var flag:boolean);
Begin
  Repeat
    Randomize;
    x:=Random(GridSize) + 1;
    y:=Random(GridSize) + 1;
  until PlayerField[x,y] < 1;
  
  If TestShotComp(x,y)
  then begin
    if not IsEmptyWhenKill(x,y,PlayerField)
    then Step:=2
    else PlayerShipsCount:=PlayerShipsCount - 1;
  end
  else flag:=false;
end;

procedure Step2(var x,y:integer; var flag:boolean);
Begin
  If (x > 1)
  then if (PlayerField[x-1,y] < 1)
    then begin
      If TestShotComp(x-1,y)
      then begin
          Step:=3;
          Px:=x-2;
          Py:=y;
          Way:=1;
      end
      else flag:=false;
      exit;
    end;
   
  If (y < GridSize)
  then if (PlayerField[x,y+1] < 1)
    then begin
      If TestShotComp(x,y+1)
      then begin
          Step:=3;
          Px:=x;
          Py:=y+2;
          Way:=2;
      end
      else flag:=false;
      
      exit;
    end;
    
  If (x < GridSize)
  then if (PlayerField[x+1,y] < 1)
    then begin
      If TestShotComp(x+1,y)
      then begin
          Step:=3;
          Px:=x+2;
          Py:=y;
          Way:=1;  
      end
      else flag:=false;
      
      exit;
    end;
    
  If (y > 1)
  then if (PlayerField[x,y-1] < 1)
    then begin
      If TestShotComp(x,y-1)
      then begin
          Step:=3;
          Px:=x;
          Py:=y-2;
          Way:=2;
      end
      else flag:=false;
      
      exit;
    end;
end;

procedure Way1 (x,y:integer; var flag:boolean);
Begin
  If (x < 1) or (x > GridSize) or (y < 1) or (y >GridSize)
  then begin
    Way:=3;
    exit;
  end;
  
  If (PlayerField[x,y] < 1)
  then begin
    If TestShotComp(x,y)
    then Way1(x-1,y,flag)
    else flag:=false;
  end;
  way:=3;
end;

procedure Way2 (x,y:integer; var flag:boolean);
Begin
  If (x < 1) or (x > GridSize) or (y < 1) or (y >GridSize)
  then begin
    Way:=4;
    exit;
  end;
  
  If (PlayerField[x,y] < 1)
  then begin
    If TestShotComp(x,y)
    then Way2(x,y+1,flag)
    else flag:=false;
  end;
  way:=4;
end;

procedure Way3 (x,y:integer);
Begin
  If (x < 1) or (x > GridSize) or (y < 1) or (y >GridSize)
  then begin
    Step:=1;
    exit;
  end;
  
  If (PlayerField[x,y] = 0) or (PlayerField[x,y] = 2)
  then begin
    PlayerField[x,y]:=2;
    If (x+1 < GridSize)
    then If (PlayerField[x+1,y] = 0) or (PlayerField[x+1,y] = 2)
      then begin
        Way3(x+1,y);
        exit;
      end;
  end;
  Step:=1;
end;

procedure Way4 (x,y:integer);
Begin
  If (x < 1) or (x > GridSize) or (y < 1) or (y >GridSize)
  then begin
    Step:=1;
    exit;
  end;
  
  If (PlayerField[x,y] = 0) or (PlayerField[x,y] = 2)
  then begin
    PlayerField[x,y]:=2;
    If (y > 1)
    then If (PlayerField[x,y-1] = 0) or (PlayerField[x,y-1] = 2)
      then begin
        Way4(x,y-1);
        exit;
      end;
  end;
  Step:=1;
end;

procedure Step3(var x,y:integer; var flag:boolean);
Begin
  Case Way of
    1: Way1(x,y,flag);
    2: Way2(x,y,flag);
    3: Way3(x+1,y);
    4: Way4(x,y-1);
  end;
  If Step = 1
  then PlayerShipsCount:=PlayerShipsCount - 1;
end;

procedure ComputerTurn();
Var
flag:boolean;
begin
  flag:=true;
  While flag do
  begin
    
    If (GameResults > 0)
    then exit;
    Case Step of
      1: Step1(Px,Py,flag);
      2: Step2(Px,Py,flag);
      3: Step3(Px,Py,flag);
    end;
  end;
end;

end.