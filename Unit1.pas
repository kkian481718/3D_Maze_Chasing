unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, Card, IdUDPServer, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPClient, winsock, IdSocketHandle, ComCtrls,
  Gauges;

type
  TSIArray = array of ShortInt;
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    L_LX: TLabel;
    L_LY: TLabel;
    L_Dir: TLabel;
    Card1: TCard;
    Card2: TCard;
    Card3: TCard;
    Card4: TCard;
    UDPC: TIdUDPClient;
    UDPS: TIdUDPServer;
    Edit1: TEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Edit2: TEdit;
    Label2: TLabel;
    Button4: TButton;
    Button5: TButton;
    Button_showcard2: TButton;
    Button_showcard1: TButton;
    Button_showcard3: TButton;
    Button_showcard4: TButton;
    Memo1: TMemo;
    Timer1: TTimer;
    Gauge1: TGauge;
    Timer_con: TTimer;
    Timer_shuffle: TTimer;
    DEBUG_btn: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ComboBox1Select(Sender: TObject);
    procedure UDPSUDPRead(Sender: TObject; AData: TStream; ABinding: TIdSocketHandle);
    
    //Button
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button_showcard1Click(Sender: TObject);
    procedure Button_showcard2Click(Sender: TObject);
    procedure Button_showcard3Click(Sender: TObject);
    procedure Button_showcard4Click(Sender: TObject);
    
    //Timer
    procedure Timer_conTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer_shuffleTimer(Sender: TObject);
    
    //自訂函式
    procedure Make3D(Mx, My, Md: Byte; Bmap: TBitmap);
    procedure Make2D(Mx, My, Md: Byte; Bmap: TBitmap);
    procedure updateFrame();
    procedure disconnect();
    procedure conUISetVisible(bool: Boolean);
    procedure shuffleCards();
    procedure collectionCheck(mode: integer);
    procedure damage();
    procedure teleport(var x, y: ShortInt);
    procedure complete_card_selection(x: integer);
    procedure outputBattleResut(battle_result: integer);
    procedure gameOver();

    // 有回傳值的自訂函式
    function GetIPFromHost(var HostName, IPaddr, WSAErr: string): Boolean;
    function getWinner(s: string): string;
    function getAvailableLocation(): TSIArray;
    procedure DEBUG_btnClick(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

const
  horizontal_block = 37; //顯示的橫向圖案數
  vertical_block = 27; //顯示的縱向圖案數
  LW = 12;   //每格牆壁的基本長度
  MMW = 10; // 小地圖中每格牆壁的基本長度 miniMap_Width
  Hmax = 14; //橫向圖像數-1
  Vmax = 14; //縱向圖像數-1
  GAME_NAME = 'D&D v0.1';

var
  Form1: TForm1;
  
  //3D視角中需要處理到的牆壁地圖
  Dmap: array[0..4, 0..4] of Byte; 

  // 完整地圖
  Lmap: array[0..Vmax, 0..Hmax] of Byte = (    
  ($00, $01, $01, $00, $00, $00, $00, $01, $00, $00, $00, $00, $01, $00, $00),
  ($00, $00, $01, $00, $00, $00, $00, $01, $00, $01, $01, $00, $01, $00, $00),
  ($00, $01, $01, $00, $00, $00, $00, $01, $00, $00, $00, $00, $01, $00, $00),
  ($00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $01, $00, $00, $00, $00),
  ($01, $01, $01, $00, $00, $00, $00, $01, $00, $00, $00, $00, $01, $00, $00),
  ($00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $01, $00, $00, $01, $01),
  ($00, $01, $00, $01, $01, $01, $01, $01, $00, $00, $01, $01, $00, $00, $00),
  ($00, $01, $00, $00, $00, $00, $00, $01, $01, $00, $01, $00, $01, $01, $00),
  ($00, $01, $01, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $01, $00),
  ($00, $01, $00, $00, $00, $01, $00, $01, $01, $01, $01, $01, $00, $01, $00),
  ($00, $00, $00, $01, $00, $01, $00, $00, $00, $00, $00, $01, $00, $00, $00),
  ($00, $01, $01, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $01),
  ($00, $01, $00, $00, $00, $01, $00, $00, $00, $01, $00, $00, $00, $00, $00),
  ($00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $01, $01, $00),
  ($00, $00, $00, $01, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00)
  );

  // Bitmap
  Back_Bmap: TBitmap; //線條3D化要用到的點陣圖
  twoD_Bmap: TBitmap; //2D地圖用到的點陣圖

  // 一些變數
  LX, LY, Dir: ShortInt;      // 我的位置
  Rect_B, Rect_M: TRect;

  // 連線用的變數
  con_mode: Byte;             // 連接模式
  con_connected: boolean;     // 檢查是否已連接
  con_loc: array of ShortInt; // 所有玩家的位置
  con_IP: array of string;    // (Server才有) 所有玩家的IP
  con_battling: array of ShortInt;// 所有玩家是否正在戰鬥
  con_num: ShortInt;          // 我的編號 (Server = 0)
  opp_num: ShortInt;          // 對方的連線編號
  opp_card_string: string;    // 對方出的卡（字串）

  // 戰鬥用的變數
  HP: ShortInt;               // 血量
  my_value: ShortInt;         // 我出的卡值
  my_suit_num: ShortInt;      // 我出的卡花色編號
  opp_value: ShortInt;        // 對方出的卡值
  opp_suit_num: ShortInt;     // 對方出的卡花色編號

  // 抓本機IP用的變數
  Host, IP, Err: string;

  // 撲克牌用的變數
  CD: array[0..3] of TCard;

  // DEBUG 開關
  DEBUG: boolean;
implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  DEBUG := false;
  Form1.caption := GAME_NAME;

  //初始化儲存線條3D用的點陣圖
  Back_Bmap := TBitmap.Create;
  Back_Bmap.Width := 30 * LW;
  Back_Bmap.Height := 30 * LW;

  //初始化儲存2D地圖的點陣圖
  twoD_Bmap := Tbitmap.Create;
  twoD_Bmap.width := Hmax * MMW + 10;
  twoD_Bmap.Height := Vmax * MMW + 10;

  //變數初始化
  LX := 1; // 玩家x位置
  LY := 1; // 玩家y位置
  Dir := 1; // 玩家面對的方向

  //戰鬥數值初始化
  HP := 100;
  Gauge1.Progress := HP;
  opp_card_string := '';
  opp_num := -1;

  //初始把UDP關閉
  UDPC.Active := false;
  UDPS.Active := false;
  
  //初始化連線變數
  con_mode := 0; //0:單人、1:Client、2:Server
  setlength(con_loc, 2);
  con_loc[0] := 1;
  con_loc[1] := 1;
  setlength(con_IP, 1);
  con_num := 0;
  setlength(con_battling, 0);
  con_connected := false;
  
  //把四張牌蓋起來
  Card1.Showdeck := true;
  Card2.Showdeck := true;
  Card3.Showdeck := true;
  Card4.Showdeck := true;

  CD[0]:=Card1;
  CD[1]:=Card2;
  CD[2]:=Card3;
  CD[3]:=Card4;

  // 將牌蓋洗牌
  shuffleCards();
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //釋放3D、2D用的點陣圖
  Back_Bmap.free;
  twoD_Bmap.free;
end;

// DEBUG 開關
procedure TForm1.DEBUG_btnClick(Sender: TObject);
begin
  DEBUG := not DEBUG;
  if (DEBUG) then
    memo1.Lines.add('/ DEBUG mode: 啟用 /')
  else
    memo1.Lines.add('/ DEBUG mode: 關閉 /');
end;



// ----------------------------------------------------------------
// 畫面計算
// ----------------------------------------------------------------

// 讓視窗產生後，可以馬上畫第一次地圖
procedure TForm1.Timer1Timer(Sender: TObject);
begin
  updateFrame();
  Timer1.Enabled := false;
end;

// 呼叫Make3D、2D更新畫面
procedure TForm1.updateFrame();
begin
  // > 顯示座標文字 <
  L_LX.caption := 'X: ' + inttostr(LX);
  L_LY.caption := 'Y: ' + inttostr(LY);
  L_Dir.caption := '方向: ' + inttostr(Dir);

  // > 立體化 <
  Make3D(LX, LY, Dir, Back_Bmap);
  Back_Bmap.Canvas.CopyMode := cmSrcCopy;
  Form1.Canvas.Draw(16, 16, Back_Bmap);

  // > 畫2D地圖 <
  Make2D(LX, LY, Dir, twoD_Bmap);
  Form1.Canvas.Draw(Back_Bmap.Width+30, 16, twoD_Bmap);
end;

procedure TForm1.Make3D(Mx, My, Md: Byte; Bmap: TBitmap);
var
  X, Y: ShortInt;
begin
  // > 3D視角中需要處理到的牆壁地圖Dmap <
  for X := 0 to 4 do
    for Y := 0 to 4 do
      Dmap[X, Y] := 1;

  case Md of
    0: begin // 如果朝向東邊
      for X := 4 downto 0 do
        for Y := -2 to 2 do
          if (Mx+X <= Hmax) and (My+Y >= 0) and (My+Y <= Vmax) then Dmap[Y+2, 4-X] := Lmap[Mx+X, My+Y];
    end;

    1: begin // 如果朝向南邊
      for Y := -4 to 0 do
        for X := -2 to 2 do
          if (My+Y >= 0) and (Mx+X >= 0) and (Mx+X <= Hmax) then Dmap[X+2, Y+4] := Lmap[Mx+X, My+Y];
    end;

    2: begin // 如果朝向西邊
      for X := -4 to 0 do
        for Y := 2 downto -2 do
          if (Mx+X >= 0) and (My+Y >= 0) and (My+Y <= Vmax) then Dmap[2-Y, 4+X] := Lmap[Mx+X, My+Y];
    end;

    3: begin // 如果朝向北邊
      for Y := 4 downto 0 do
        for X := 2 downto -2 do
          if (My+Y <= Hmax) and (Mx+X >= 0) and (Mx+X <= Hmax) then Dmap[2-X, 4-Y] := Lmap[Mx+X, My+Y];
    end;
  end;

  // > 將線條3D繪製在點陣圖上 <
  Bmap.Canvas.Pen.Width := 2;
  Bmap.Canvas.Pen.Color := $ffffff;

  // 0) 畫底色
  Bmap.Canvas.Brush.Color := $2f2f2f;
  Bmap.Canvas.Rectangle(0, 0, Bmap.Width, Bmap.Height);

  // 1) 4格遠、正面的牆壁?? (方形、共5個)
  Bmap.Canvas.Brush.Color := $222222;
  for X := 0 to 4 do
    if (Dmap[X, 0] and 1) = 1 then
      Bmap.Canvas.Rectangle(X*6*LW, 12*LW, (X*6 + 6)*LW, 18*LW);
  
  // 2) 3格遠、側面的牆壁? (梯形、共4個)
  Bmap.Canvas.Brush.Color := $282828;
  if (Dmap[0, 1] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(0, 10*LW), Point(0, 20*LW), Point(6*LW, 18*LW), Point(6*LW, 12*LW)]);
  if (Dmap[1, 1] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(10*LW, 10*LW), Point(10*LW, 20*LW), Point(12*LW, 18*LW), Point(12*LW, 12*LW)]);
  if (Dmap[3, 1] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(20*LW, 10*LW), Point(20*LW, 20*LW), Point(18*LW, 18*LW), Point(18*LW, 12*LW)]);
  if (Dmap[4, 1] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(30*LW, 10*LW), Point(30*LW, 20*LW), Point(24*LW, 18*LW), Point(24*LW, 12*LW)]);
  
  // 3) 3格遠、正面的牆壁 (方形、共3個)
  for X := 1 to 3 do
  begin
    Bmap.Canvas.Brush.Color := $303030;
    if (Dmap[X, 1] and 1) = 1 then
    begin
      Bmap.Canvas.Rectangle((X-1)*10*LW, 10*LW, X*10*LW, 20*LW);
    end else
    begin
      Bmap.Canvas.Brush.Color := $141414;
      Bmap.Canvas.Rectangle((X-1)*10*LW, 10*LW, X*10*LW, 20*LW);
    end;
  end;

  // 4) 2格遠、側面的牆壁 (梯形、共2個)
  Bmap.Canvas.Brush.Color := $303030;
  if (Dmap[1, 2] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(7*LW, 7*LW), Point(7*LW, 23*LW), Point(10*LW, 20*LW), Point(10*LW, 10*LW)]);
  if (Dmap[3, 2] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(23*LW, 7*LW), Point(23*LW, 23*LW), Point(20*LW, 20*LW), Point(20*LW, 10*LW)]);

  // 5) 正面
  Bmap.Canvas.Brush.Color := $404040;
  for X := 1 to 3 do
    if (Dmap[X, 2] and 1) = 1 then
      Bmap.Canvas.Rectangle(((X-1)*16 - 9)*LW, 7*LW, ((X-1)*16 + 7)*LW, 23*LW);

  // 6)
  Bmap.Canvas.Brush.Color := $404040;
  if (Dmap[1, 3] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(3*LW, 3*LW), Point(3*LW, 27*LW), Point(7*LW, 23*LW), Point(7*LW, 7*LW)]);
  if (Dmap[3, 3] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(27*LW, 3*LW), Point(27*LW, 27*LW), Point(23*LW, 23*LW), Point(23*LW, 7*LW)]);

  // 7) 正前方牆壁
  Bmap.Canvas.Brush.Color := $505050;
  for X := 1 to 3 do
    if (Dmap[X, 3] and 1) = 1 then
      Bmap.Canvas.Rectangle(((X-1)*24 -21)*LW, 3*LW, ((X-1)*24 + 3)*LW, 27*LW);

  // 8) 左右邊牆壁
  Bmap.Canvas.Brush.Color := $505050;
  if (Dmap[1, 4] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(0, 0), Point(0, 30*LW), Point(3*LW, 27*LW), Point(3*LW, 3*LW)]);
  if (Dmap[3, 4] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(30*LW, 0), Point(30*LW, 30*LW), Point(27*LW, 27*LW), Point(27*LW, 3*LW)]);

  // 9)
  Bmap.Canvas.Brush.Color := $606060;
  Bmap.Canvas.PolyLine([Point(1, 1), Point(1, Bmap.Height-1), Point(Bmap.Width-1, Bmap.Height-1), Point(Bmap.Width-1, 1)]);
  
end;

procedure TForm1.Make2D(Mx, My, Md: Byte; Bmap: TBitmap);
var
  X, Y, i: ShortInt;
begin
  Bmap.Canvas.Pen.Width := 1;
  Bmap.Canvas.Pen.Color := $ffff00;
  
  // 畫地圖背景
  Bmap.Canvas.Brush.Color := $222222;
  Bmap.Canvas.Rectangle(0, 0, Bmap.Width, Bmap.Height);

  // 畫牆壁
  Bmap.Canvas.Brush.Color := $ffff00;
  for X := 0 to Hmax do
    for Y := 0 to Vmax do
    begin
      if Lmap[X, Y] = 1 then Bmap.Canvas.Rectangle(X*MMW, Y*MMW, (X+1)*MMW, (Y+1)*MMW);
    end;

  // 畫玩家位置
  Bmap.Canvas.Pen.Color := $ff00ff;
  Bmap.Canvas.Brush.Color := $ff00ff;
  Bmap.Canvas.Rectangle(Mx*MMW, My*MMW, (Mx+1)*MMW, (My+1)*MMW);

  // 畫玩家朝向
  case Md of
    // 東
    0: Bmap.Canvas.Rectangle((Mx+1)*MMW +2, My*MMW +2, (Mx+1)*MMW +4, (My+1)*MMW -2); 
    
    // 北
    1: Bmap.Canvas.Rectangle(Mx*MMW +2, My*MMW -2, (Mx+1)*MMW -2, My*MMW -4);
    
    // 西
    2: Bmap.Canvas.Rectangle(Mx*MMW -2, My*MMW +2, Mx*MMW -4, (My+1)*MMW -2);

    // 南
    3: Bmap.Canvas.Rectangle(Mx*MMW +2, (My+1)*MMW +2, (Mx+1)*MMW -2, (My+1)*MMW +4);
  end; 

  // 畫其他玩家位置
  Bmap.Canvas.Pen.Color := $00ffff;
  Bmap.Canvas.Brush.Color := $00ffff;
  i := 0;
  while i < Length(con_loc) do
  begin
    if (i = con_num) or (con_loc[i] = -1) then
    begin
      // 不用畫自己的位置、不用畫斷線玩家的位置
      i := i + 2;
      continue;
    end else
    begin
      X := con_loc[i];
      Y := con_loc[i+1];
      Bmap.Canvas.Rectangle(X*MMW, Y*MMW, (X+1)*MMW, (Y+1)*MMW);
      i := i + 2;
    end;
  end;
end;



// ----------------------------------------------------------------
// 移動、對戰
// ----------------------------------------------------------------

// 前進
procedure TForm1.Button1Click(Sender: TObject);
var
  i, pt_battling_list, battling_num, len_XY_list: ShortInt;
  battling_X_list, battling_Y_list: array of ShortInt;
  can_move: boolean;
begin
  setlength(battling_X_list, 0);
  setlength(battling_Y_list, 0);

  // 製造出正在對戰的格子清單
  i := 0;
  pt_battling_list := 0;
  len_XY_list := length(con_battling) div 2;
  setlength(battling_X_list, len_XY_list);
  setlength(battling_Y_list, len_XY_list);
  while i < length(con_battling) do
  begin
    battling_num := con_battling[i];
    battling_X_list[pt_battling_list] := con_loc[battling_num*2];
    battling_Y_list[pt_battling_list] := con_loc[battling_num*2 + 1];

    pt_battling_list := pt_battling_list + 1;
    i := i + 2;
  end;
  
  Dir := Dir or 16;
  can_move := true;
  // > 如果可以移動，就改變座標 <
  if Dir > 15 then
  begin
    // 確認 1.玩家在迷宮範圍內 2.沒有碰到牆壁
    Dir := Dir and 15; // ???
    case Dir of
      0: if (LX + 1 <= Hmax) and (Lmap[LX+1, LY] = 0) then
      begin
        for i:=0 to (len_XY_list-1) do
        begin
          if battling_X_list[i] = (LX + 1) then
          begin
            can_move := false;
            break;
          end;
        end;

        if (can_move = true) then LX := LX + 1; // 東 
      end;

      1: if (LY - 1 >= 0   ) and (Lmap[LX, LY-1] = 0) then
      begin
        for i:=0 to (len_XY_list-1) do
        begin
          if battling_Y_list[i] = (LY - 1) then
          begin
            can_move := false;
            break;
          end;
        end;

        if (can_move = true) then LY := LY - 1; // 南
      end;

      2: if (LX - 1 >= 0   ) and (Lmap[LX-1, LY] = 0) then
      begin
        for i:=0 to (len_XY_list-1) do
        begin
          if battling_X_list[i] = (LX - 1) then
          begin
            can_move := false;
            break;
          end;
        end;

        if (can_move = true) then LX := LX - 1; // 西
      end;

      3: if (LY + 1 <= Vmax) and (Lmap[LX, LY+1] = 0) then
      begin
        for i:=0 to (len_XY_list-1) do
        begin
          if battling_Y_list[i] = (LY + 1) then
          begin
            can_move := false;
            break;
          end;
        end;

        if (can_move = true) then LY := LY + 1; // 北
      end;
    end;
  end;

  // > 更新玩家的位置給所有人 <
  con_loc[con_num*2] := LX;
  con_loc[con_num*2 + 1] := LY;

  case con_mode of
    1: // Client
    UDPC.send('L' + inttostr(con_num) + 'X' + inttostr(LX) + 'Y' + inttostr(LY));
    
    2: // Server
    begin
      // 傳送給所有人
      i := 1;

      while i <= (Length(con_IP)-1) do
      begin
        if (con_IP[i] <> '-1') then UDPC.Host := con_IP[i];
        UDPC.Port := 8787; 
        UDPC.Send('L' + inttostr(con_num) + 'X' + inttostr(LX) + 'Y' + inttostr(LY));
        i := i+1;
      end;
    end;
  end;

  updateFrame(); // 更新2D、3D地圖
  collectionCheck(1); // 檢查是否有遇到人
end;

// 左轉
procedure TForm1.Button2Click(Sender: TObject);
begin
  Dir := (Dir + 1) and 3;
  updateFrame();
end;

// 右轉
procedure TForm1.Button3Click(Sender: TObject);
begin
  Dir := (Dir + 3) and 3;
  updateFrame();
end;

// 出牌
procedure TForm1.Button_showcard1Click(Sender: TObject);
begin
  complete_card_selection(1);
end;
procedure TForm1.Button_showcard2Click(Sender: TObject);
begin
  complete_card_selection(2);
end;
procedure TForm1.Button_showcard3Click(Sender: TObject);
begin
  complete_card_selection(3);
end;
procedure TForm1.Button_showcard4Click(Sender: TObject);
begin
  complete_card_selection(4);
end;

// 洗牌
procedure TForm1.shuffleCards();
var
  i, j: integer;
  is_vaild_card: boolean;
begin

  randomize; 

  for i:=0 to 3 do
  begin
    repeat
      is_vaild_card := true;
      CD[i].Value := 1 + random(13);
      CD[i].Suit := Tcardsuit(random(4));

      if(i <> 0) then
      begin
        j := 0;
        while (j <= i-1) do
        begin
          if (CD[i].Value = CD[j].Value) and (CD[i].suit = CD[j].suit) then
          begin
            is_vaild_card := false;
            break;
          end;

          j := j + 1;
        end;
      end;
    until is_vaild_card = true;
  end;
end;

// 瘋狂洗牌動畫
procedure TForm1.Timer_shuffleTimer(Sender: TObject);
var
  times: ShortInt;
begin
  times := 0;
  while (times < 50) do // <--改這裡可以更改洗牌時間
  begin
    shuffleCards();
    times := times + 1;
  end;
  
  Timer_shuffle.Enabled := false;
  Button_showcard1.Visible := true;
  Button_showcard2.Visible := true;
  Button_showcard3.Visible := true;
  Button_showcard4.Visible := true;
  Button_showcard1.Caption := '出這張';
  Button_showcard4.Caption := '出這張';  
end;

// 檢查是否有遇到人
procedure TForm1.collectionCheck(mode: integer);
var
  i, k, player_count: integer;
begin
  player_count := (length(con_loc) div 2); // 目前伺服器內總人數
  for i := 0 to (player_count - 1) do
  begin
    if (con_loc[i*2] = LX) and (con_loc[i*2 + 1] = LY) and (i <> con_num) then
    begin
      Button1.Enabled := false;
      Button2.Enabled := false;
      Button3.Enabled := false;
      Button_showcard1.Visible := false;
      Button_showcard2.Visible := false;
      Button_showcard3.Visible := false;
      Button_showcard4.Visible := false;
      opp_num := i;

      memo1.Lines.add('');
      memo1.Lines.add('> 發生戰鬥！ <');
      memo1.Lines.add('');

      case mode of
        1: // 主動撞人
        begin
          Button_showcard1.Enabled := true;
          Button_showcard2.Enabled := true;
          Button_showcard3.Enabled := true;
          Button_showcard4.Enabled := true;
          card1.ShowDeck := false;
          card2.ShowDeck := false;
          card3.ShowDeck := false;
          card4.ShowDeck := false;

          memo1.Lines.add('你逮到 ' + inttostr(opp_num) + ' 號玩家了！');
          memo1.Lines.add('你具有優勢！');
          memo1.Lines.add('快選一張數字大的牌攻擊！');
          memo1.Lines.add('');

          // 發訊息給非戰鬥的人，讓他們更新自己的 con_battling
          // A[攻擊方]D[防守方]
          case con_mode of
          1: // Client
          UDPC.send('A' + inttostr(con_num) + 'D' + inttostr(opp_num));
          
          2: // Server
          begin
            // 傳送給所有人
            k := 1;
            while k <= (Length(con_IP)-1) do
            begin
              if (k <> opp_num) and (con_IP[k] <> '-1') then
              begin
                UDPC.Host := con_IP[k];
                UDPC.Port := 8787; 
                UDPC.Send('A0' + 'D' + inttostr(opp_num));
              end;
              k := k+1;
            end;
          end;
        end;
        end;

        2: // 被撞
        begin
          Button_showcard1.Enabled := true;
          Button_showcard2.Enabled := true;
          Button_showcard3.Enabled := false;
          Button_showcard4.Enabled := false;
          card1.ShowDeck := false;
          card2.ShowDeck := false;
          card3.ShowDeck := true;
          card4.ShowDeck := true;
          
          memo1.Lines.add('你被 ' + inttostr(opp_num) + ' 號玩家伏擊了！');
          memo1.Lines.add('你處於劣勢...');
          memo1.Lines.add('快選一張數字大的牌反制！');
          memo1.Lines.add('');
        end;
      end;

      Timer_shuffle.Enabled := true;
      break;
    end;
  end;
end;

// 出牌後：1.把自己的牌儲存 2.確認對方是否已出牌
procedure TForm1.complete_card_selection(x: integer);
var
  i: integer;
  s: string;
begin
  // 1. 關閉出牌按鈕
  Button_showcard1.Enabled := false;
  Button_showcard2.Enabled := false;
  Button_showcard3.Enabled := false;
  Button_showcard4.Enabled := false;
  
  // 讓一、四個按鈕文字顯示雙方出牌狀況
  Button_showcard1.Visible := true;
  Button_showcard1.Caption := '你的牌'; 
  Button_showcard4.Visible := true;
  Button_showcard4.Caption := '對方的牌';
  Button_showcard2.Visible := false;
  Button_showcard3.Visible := false;

  // 蓋牌
  for i:=0 to 3 do
  begin
    CD[i].ShowDeck := true;
  end;
  
  {
    Tcardsuit(0) : 黑桃
    Tcardsuit(1) : 方塊
    Tcardsuit(2) : 梅花
    Tcardsuit(3) : 紅心
  }
  // 2. 把牌存進 my_value 和 my_suit_num
  my_value := CD[x-1].value;
  
  if (CD[x-1].Suit = Tcardsuit(2)) then
  begin
    my_suit_num := 1;
    CD[0].Suit := Tcardsuit(2);
  end
  else if (CD[x-1].suit = Tcardsuit(1)) then
  begin 
    my_suit_num := 2;
    CD[0].Suit := Tcardsuit(1);
  end
  else if (CD[x-1].suit = Tcardsuit(3)) then
  begin 
    my_suit_num := 3;
    CD[0].Suit := Tcardsuit(3);
  end
  else if (CD[x-1].suit = Tcardsuit(0)) then
  begin 
    my_suit_num := 4;
    CD[0].Suit := Tcardsuit(0);
  end;

  // 3. 輸出自己出的牌
  s := '> 你出了 ';
  case my_suit_num of
    1: s := s + '[ 梅花 ' + inttostr(my_value) + ' ]';
    2: s := s + '[ 方塊 ' + inttostr(my_value) + ' ]';
    3: s := s + '[ 紅心 ' + inttostr(my_value) + ' ]';
    4: s := s + '[ 黑桃 ' + inttostr(my_value) + ' ]';
  end;
  memo1.Lines.add(s);
  CD[0].value := my_value; // 讓第一張牌顯示自己的值
  CD[0].ShowDeck := false;

  // 4. 確認對方是否已出牌
  if opp_card_string = '' then
  // 4-1. 對方未出：傳自己的牌過去
  begin
    memo1.Lines.add('> 正在等待對手出牌...');

    // 送出 P[自己的序號]O[對方的編號]S[自己的花色編號]V[自己的牌值]
    case con_mode of
      1: // Client
      begin
        UDPC.send('P' + inttostr(con_num) + 'O' + inttostr(opp_num) + 'S' + inttostr(my_suit_num) + 'V' + inttostr(my_value)); //寄給server轉發
      end;

      2: // Server
      begin
        // 廣播給O[對手編號]
        UDPC.Host := con_IP[opp_num];
        UDPC.Port := 8787; 
        UDPC.send('P' + inttostr(con_num) + 'O' + inttostr(opp_num) + 'S' + inttostr(my_suit_num) + 'V' + inttostr(my_value)); //寄給server轉發
      end;
    end;
  end
  
  // 4-2. 對方已出：比較結果，並傳送結果
  else begin 
    // 傳 R[贏家編號]O[收件人編號]S[自己的花色編號]V[自己的牌值] 給對手
    // 廣播 F[攻擊方]O[防守方] 表示結束對戰
    case con_mode of
      1: // Client
      begin
        UDPC.send('R' + getWinner(opp_card_string) + 'O' + inttostr(opp_num) + 'S' + inttostr(my_suit_num) + 'V' + inttostr(my_value)); //寄給server轉發
        UDPC.send('F' + inttostr(con_num) + 'O' + inttostr(opp_num));
      end;

      2: // Server
      begin
        UDPC.Host := con_IP[opp_num];
        UDPC.Port := 8787; 
        UDPC.send('R' + getWinner(opp_card_string) + 'O' + inttostr(opp_num) + 'S' + inttostr(my_suit_num) + 'V' + inttostr(my_value)); //寄給server轉發
        
        // 廣播傳送結束對戰訊息
        i := 1;
        while i < Length(con_IP) do
        begin
          if (i <> opp_num) and (con_IP[i] <> '-1') then
          begin
            UDPC.Host := con_IP[i];
            UDPC.send('F0' + 'O' + inttostr(opp_num));
          end;

          i := i + 1;
        end;
      end;
    end;
  end;
end;

function TForm1.getWinner(s: string): string;
var
  winner_num: ShortInt;
  // 解析資料用
  temp: TStringList;
  s_p: PChar;
begin
  // 解析資料
  temp := TStringList.Create;
  s_p := PChar(opp_card_string);
  ExtractStrings(['P', 'O', 'S', 'V'], [], s_p, temp);
  opp_suit_num := strtoint(temp[2]);
  opp_value := strtoint(temp[3]);

  // 判斷贏家：先比牌值
  winner_num := -1;
  if (my_value > opp_value) then
  begin
    winner_num := con_num;
    outputBattleResut(1); // 贏
  end
  else if (my_value < opp_value) then
  begin
    winner_num := opp_num;
    outputBattleResut(0); // 輸
  end
  else if (my_value = opp_value) then
  begin
    // 牌值相同，再比花色
    if (my_suit_num > opp_suit_num) then
    begin
      winner_num := con_num;
      outputBattleResut(1); // 贏
    end
    else if (my_suit_num < opp_suit_num) then
    begin
      winner_num := opp_num;
      outputBattleResut(0); // 輸
    end
    else
    begin
      winner_num := -1;
      outputBattleResut(-1); // 平手
    end;
  end;

  Result := inttostr(winner_num);
  
  temp.free;
end;

procedure TForm1.outputBattleResut(battle_result: integer);
var
  new_loc: TSIArray;
  s: string;
begin
  s := '> 對手出了 ';
  case opp_suit_num of
    1: begin
      s := s + '[ 梅花 ' + inttostr(opp_value) + ' ]';
      CD[3].Suit := Tcardsuit(2);
    end;

    2: begin
      s := s + '[ 方塊 ' + inttostr(opp_value) + ' ]';
      CD[3].Suit := Tcardsuit(1);
    end;

    3: begin
      s := s + '[ 紅心 ' + inttostr(opp_value) + ' ]';
      CD[3].Suit := Tcardsuit(3);
    end;

    4: begin
      s := s + '[ 黑桃 ' + inttostr(opp_value) + ' ]';
      CD[3].Suit := Tcardsuit(0);
    end;
  end;
  memo1.Lines.add(s);
  CD[3].value := opp_value;
  CD[3].ShowDeck := false;

  // 輸出贏家
  memo1.Lines.add('－－－－－－－－－－－－');
  s := '> 對戰結果：';
  if (battle_result = 0) then
  begin
    s := s + ' 你輸了...';
    memo1.Lines.add(s);
    damage();
  end else
  if (battle_result = 1) then
  begin
    s := s + ' 你贏了！';
    memo1.Lines.add(s);
    memo1.Lines.add('');
    memo1.Lines.add('（你脫離了戰鬥！）');
    memo1.Lines.add('');

    setlength(new_loc, 2);
    new_loc := getAvailableLocation();
    teleport(new_loc[0], new_loc[1]);
  end else
  if (battle_result = -1) then
  begin
    s := s + ' 平手';
    memo1.Lines.add(s);
    damage();
  end;

  opp_card_string := '';
  Button1.Enabled := true;
  Button2.Enabled := true;
  Button3.Enabled := true;
end;

// 扣血
procedure TForm1.damage();
var
  HPdamage: integer;
  new_loc: TSIArray;
begin
  HPdamage := 20 + random(20);
  HP := HP - HPdamage;
  if (HP < 0) then HP := 0;
  Gauge1.Progress := HP;

  memo1.Lines.add('');
  memo1.Lines.add('（受到 ' + inttostr(HPdamage) + ' 點傷害）');

  if (HP = 0) then
  begin
    gameOver();
  end
  else begin
    memo1.Lines.add('（你狼狽地脫離了戰鬥...）');
    memo1.Lines.add('');
    setlength(new_loc, 2);
    new_loc := getAvailableLocation();
    teleport(new_loc[0], new_loc[1]);
  end;
end;

// 傳送到指定的位置
procedure TForm1.teleport(var x, y: ShortInt);
var i: ShortInt;
begin
  LX := x;
  LY := y;
  con_loc[con_num*2] := LX;
  con_loc[con_num*2 + 1] := LY;

  // Client
  if con_mode = 1 then
  begin
    UDPC.send('L' + inttostr(con_num) + 'X' + inttostr(LX) + 'Y' + inttostr(LY));
  end
  
  // Server
  else if con_mode = 2 then
  begin
    i := 1;
    while i < length(con_IP) do
    begin
      UDPC.Host := con_IP[con_num];
      UDPC.Port := 8787;
      UDPC.send('L' + inttostr(con_num) + 'X' + inttostr(LX) + 'Y' + inttostr(LY));

      i := i + 1;
    end;
  end;

  memo1.Lines.add('你已經傳送到 (' + inttostr(x) + ', ' + inttostr(y) + ')。');
  updateFrame();
end;

// 尋找空白的位置
function TForm1.getAvailableLocation(): TSIArray;
var
  validate_loc: boolean;
  i: ShortInt;
  new_XY: TSIArray;

begin
  randomize; // 隨機化亂數種子
  setlength(new_XY, 2); // 設定回傳array長度

  repeat
    validate_loc := true;
    new_XY[0] := random(Hmax + 1); // 0 ~ Hmax
    new_XY[1] := random(Vmax + 1); // 0 ~ Vmax
    
    // 檢查格子是否為牆壁
    if (Lmap[new_XY[0], new_XY[1]] = 1) then
    begin
      validate_loc := false;
    end else
    begin
      i := 0;
      while i < length(con_loc) do
      begin
        if (new_XY[0] = con_loc[i]) and (new_XY[1] = con_loc[i+1]) then
        begin
          validate_loc := false;
          break;
        end;

        i := i + 2;
      end;
    end;
  until validate_loc = true;

  Result := new_XY;
end;

procedure TForm1.gameOver();
begin
  // 臭嘴程式要放在這裡
  memo1.Lines.add('（你已失去全部血量）');
  memo1.Lines.add('（已與伺服器斷開連線）');
  disconnect();
end;
// ----------------------------------------------------------------
// 連線設定
// ----------------------------------------------------------------

// 選擇網路模式
procedure TForm1.ComboBox1Select(Sender: TObject);
begin
  if ComboBox1.ItemIndex = 0 then
  begin
    Form1.Caption := GAME_NAME + '：單人模式';
    con_mode := 0;
    // 隱藏IP、PORT、連線按鈕組
    conUISetVisible(false); 
  end
  else begin
    // 顯示IP、PORT、連線按鈕組
    conUISetVisible(true); 

    // 嘗試得到自己的IP
    IP := '';
    if GetIPFromHost(Host, IP, Err) then
    begin
      Edit1.Text := IP;
    end else
      MessageDlg(Err, mtError, [mbOk], 0);

    // 設定連線按鈕文字
    if ComboBox1.ItemIndex = 1 then // Client
    begin 
      Form1.Caption := GAME_NAME + '：多人模式（Client｜未連線）';
      con_mode := 1;

      Edit1.Enabled := true;
      Edit2.Enabled := true;
      Button4.Enabled := true;
      Button5.Enabled := false;
      Button4.Caption := '連線！';
    end else
    if ComboBox1.ItemIndex = 2 then // Server
    begin
      Form1.Caption := GAME_NAME + '：多人模式（Server｜未創建）';
      con_mode := 2;

      Edit1.Enabled := false;
      Edit2.Enabled := true;
      Button4.Enabled := true;
      Button5.Enabled := false;
      Button4.Caption := '建立伺服器！';
    end;
  end;
end;

// 按下建立連線
procedure TForm1.Button4Click(Sender: TObject);
begin

  Edit1.Enabled := false;
  Edit2.Enabled := false;
  Button4.Enabled := false;
  Button5.Enabled := false;
  ComboBox1.Enabled := false;
  opp_card_string := '';
  opp_num := -1;
  
  // 判斷連線模式
  // 連線模式為：
  case con_mode of
    1: //1. Client 嘗試連線
    begin
      Form1.Caption := GAME_NAME + '：多人模式（Client｜正在連線至主機...）';

      UDPC.Host := Edit1.Text;
      UDPC.Port := strtoint(Edit2.Text);

      UDPS.DefaultPort := 8787;
      UDPS.Active := true;

      Form1.Caption := GAME_NAME + '：多人模式（Client｜正在傳送你的IP：' + IP + '...）';
      con_connected := false;
      UDPC.Send('C' + IP); // 送出C[IP]嘗試連接，並得到一個序號

      // 等待確認是否有收到序號
      Timer_con.Interval := 3000; //3s
      Timer_con.Enabled := true;
      Timer_con.Tag := 1;
    end;

    2: //2. 嘗試建立 Server
    begin
      Form1.Caption := GAME_NAME + '：多人模式（Server｜正在嘗試建立新伺服器...）';

      UDPS.DefaultPort := strtoint(Edit2.Text);
      UDPS.Active := true;

      con_IP[0] := Edit1.Text;
      
      Form1.Caption := GAME_NAME + '：多人模式（Server｜就緒）';
      Button5.Enabled := true;
    end;
  end;

end;

// Client連線後，等待確認是否有接到連線成功的訊息
procedure TForm1.Timer_conTimer(Sender: TObject);
begin
  if con_connected = false then
  begin
    //允許玩家停止嘗試
    Button5.Enabled := true;

    Timer_con.Tag := Timer_con.Tag + 1;
    UDPC.Send('C' + IP); // 送出C[IP]嘗試連接，並得到一個序號
    Form1.Caption := GAME_NAME + '：多人模式（Client｜連線失敗，正在嘗試第' + inttostr(Timer_con.Tag) + '次...）';
  end;
end;

// 按下斷開連接
procedure TForm1.Button5Click(Sender: TObject);
begin
  disconnect();
end;

procedure TForm1.disconnect();
begin
  UDPC.Send('D' + inttostr(con_num));
  UDPC.Active := false;
  UDPS.Active := false;

  Timer_con.Enabled := false;
  ComboBox1.ItemIndex := 0;

  // 把出牌功能禁用
  CD[0].ShowDeck := true;
  CD[1].ShowDeck := true;
  CD[2].ShowDeck := true;
  CD[3].ShowDeck := true;
  Button_showcard1.Visible := false;
  Button_showcard2.Visible := false;
  Button_showcard3.Visible := false;
  Button_showcard4.Visible := false;
  
  // 開啟移動功能
  Button1.Enabled := true;
  Button2.Enabled := true;
  Button3.Enabled := true;

  // 初始化連線變數
  con_mode := 0; //0:單人、1:Client、2:Server
  setlength(con_IP, 1);
  con_num := 0;
  setlength(con_battling, 0);
  con_connected := false;

  // 重置血條
  HP := 100;
  Gauge1.Progress := HP;

  // 洗白小地圖
  setlength(con_loc, 2);
  con_loc[0] := LX;
  con_loc[1] := LY;
  updateFrame();
  
  ComboBox1.Enabled := true;
  conUISetVisible(false);
  Form1.Caption := GAME_NAME + '：單人模式';
end;

// 顯示/隱藏連線欄
procedure TForm1.conUISetVisible(bool: Boolean);
begin
  Label1.Visible := bool;
  Label2.Visible := bool;
  Edit1.Visible := bool;
  Edit2.Visible := bool;
  Button4.Visible := bool;
  Button5.Visible := bool;
end;

// 得到自己電腦的IP
function TForm1.GetIPFromHost (var HostName, IPaddr, WSAErr: string): Boolean;
type
    Name = array[0..100] of Char;     // Delphi 7(D7) 的寫法
    // Name = array[0..100] of AnsiChar;    // Delphi2009 以後的寫法
    PName = ^Name;
var
    HEnt: pHostEnt;
    HName: PName;
    WSAData: TWSAData;
    i: Integer;
begin
    Result := False;
    if WSAStartup($0101, WSAData)<>0 then
    begin
        WSAErr := 'Winsock is not responding."';
        Exit;
    end;

    IPaddr := '';
    New(HName);
    if GetHostName(HName^, SizeOf(Name)) = 0 then
      begin
        HostName := StrPas(HName^);
        HEnt := GetHostByName(HName^);
        for i:=0 to (HEnt^.h_length-1) do
          IPaddr := Concat(IPaddr, IntToStr(Ord(HEnt^.h_addr_list^[i])) + '.');
        SetLength(IPaddr, Length(IPaddr) - 1);
        Result := True;
      end
    else
      begin
        case WSAGetLastError of
          WSANOTINITIALISED:  WSAErr := 'WSANotInitialised';
          WSAENETDOWN      :  WSAErr := 'WSAENetDown';
          WSAEINPROGRESS   :  WSAErr := 'WSAEInProgress';
        end;
      end;
    Dispose(HName);
    WSACleanup;
end;

// UDPS接收資訊
procedure TForm1.UDPSUDPRead(Sender: TObject; AData: TStream; ABinding: TIdSocketHandle);
var
  s: string;
  len, i: integer;

  // 得到玩家新位置用
  X, Y, num, opp_num, move_num: ShortInt;
  newLoc: TSIArray;

  // 把字串分割用
  temp: TStringList;
  s_p: PChar;
begin
  // > 下載資料 <
  len := AData.Size;
  setlength(s, len);
  Adata.Read(s[1], len);
  if (DEBUG) then memo1.Lines.add('[UDPS] ' + s); // DEBUG

  // > 解析資料 <
  // 1) Client & Server: 接收地圖更新 L[玩家編號]X[座標]Y[座標]
  if copy(s, 1, 1) = 'L' then
  begin
    // (得到玩家編號、新的X和Y)
    temp := TStringList.Create;
    s_p := PChar(s);
    ExtractStrings(['L', 'X', 'Y'], [], s_p, temp);
    move_num := strtoint(temp[0]); //送出移動訊號的玩家編號
    X := strtoint(temp[1]);   //新的X值
    Y := strtoint(temp[2]);   //新的Y值
    temp.free;

    // (更新自己的con_loc[][])
    if length(con_loc) < ((move_num+1)*2) then
      setlength(con_loc, (move_num+1)*2);
    con_loc[move_num*2] := X;
    con_loc[move_num*2 + 1] := Y;

    //更新畫面
    updateFrame();

    //確認碰撞
    collectionCheck(2);
    
    // 如果是伺服器，要協助轉發訊息
    if con_mode = 2 then
    begin
      i := 1;
      while i < Length(con_IP) do
      begin
        if (i <> move_num) and (con_IP[i] <> '-1') then
        begin
          UDPC.Host := con_IP[i];
          UDPC.Port := 8787; 
          UDPC.Send(s);
        end;
        i := i+1;
      end; 
    end;
  end

  // 2) Client & Server: 接收 玩家離開連線 'D[編號]'
  else if copy(s, 1, 1) = 'D' then
  begin
    // 把地圖擦掉
    num := strtoint(copy(s, 2, 10));
    con_loc[num*2] := -1;
    con_loc[num*2 + 1] := -1;

    updateFrame();

    // 如果是伺服器，要協助轉發訊息
    if con_mode = 2 then
    begin
      con_IP[num] := '-1'; // 只有Server會存大家的IP

      i := 1;
      while i < Length(con_IP) do
      begin
        if (i <> num) and (con_IP[i] <> '-1') then
        begin
          UDPC.Host := con_IP[i];
          UDPC.Port := 8787; 
          UDPC.Send(s);
        end;
        i := i + 1;
      end; 
    end;
  end
  
  // 3) Client & Server: （慢出的人）接收 出牌結果 'P[出牌者編號]O[收件人編號]S[花色編號]V[牌值]'
  else if copy(s, 1, 1) = 'P' then
  begin
    // 如果是Client：存結果進opp_card_string內
    if con_mode = 1 then
    begin
      opp_card_string := s;
      memo1.Lines.add('> 對手已出牌！');
    end

    // 如果是Server：確認收件人（是否寄給自己）、轉寄
    else if con_mode = 2 then
    begin
      // 解析資料
      temp := TStringList.Create;
      s_p := PChar(s);
      ExtractStrings(['P', 'O', 'S', 'V'], [], s_p, temp);

      // 確認是否寄給自己
      if (temp[1] = '0') then
      begin
        opp_card_string := s; //寄給自己
        memo1.Lines.add('> 對手已出牌！');
      end
      else begin
        // 轉送給收件人
        UDPC.Host := con_IP[strtoint(temp[1])];
        UDPC.Port := 8787;
        UDPC.send(s);
      end;

      temp.free;
    end;
  end

  // 4) Client & Server: (先出的人) 接收 贏家 'R[贏家編號]O[收件人編號]S[自己的花色編號]V[自己的牌值]'
  else if copy(s, 1, 1) = 'R' then
  begin
    // 拆解資料
    temp := TStringList.Create;
    s_p := PChar(s);
    ExtractStrings(['R', 'O', 'S', 'V'], [], s_p, temp);

    opp_suit_num := strtoint(temp[2]);
    opp_value := strtoint(temp[3]);

    // Client 直接拿R值output結果
    if con_mode = 1 then
    begin
      if temp[0] = inttostr(con_num) then
        outputBattleResut(1)  // 贏
      else if temp[0] = '-1' then
        outputBattleResut(-1) // 平手
      else
        outputBattleResut(0); // 輸
    end

    // Server 先確認收件人（是否寄給自己）、轉寄
    else if con_mode = 2 then
    begin
      // 寄給自己
      if (temp[1] = '0') then
      begin
        if temp[0] = inttostr(con_num) then
          outputBattleResut(1)  // 贏
        else if temp[0] = '-1' then
          outputBattleResut(-1) // 平手
        else
          outputBattleResut(0); // 輸
      end

      // 要轉送給收件人
      else begin
        UDPC.Host := con_IP[strtoint(temp[1])];
        UDPC.Port := 8787;
        UDPC.send(s);
      end;
    end;

    temp.free;
  end
  
  // 5) Client: 接收 伺服器給的序號 'N[序號]X[傳送位置]Y[傳送位置]'
  else if copy(s, 1, 1) = 'N' then
  begin
    // (讓計時器停止，不再檢查是否有連上)
    con_connected := true;

    // (得到自己的玩家編號、新的X和Y)
    temp := TStringList.Create;
    s_p := PChar(s);
    ExtractStrings(['N', 'X', 'Y'], [], s_p, temp);
    num := strtoint(temp[0]); //送出移動訊號的玩家編號
    X := strtoint(temp[1]);   //新的X值
    Y := strtoint(temp[2]);   //新的Y值
    temp.free;

    // 把自己傳送到指定的位置
    con_num := num;
    teleport(X, Y);
    
    Form1.Caption := GAME_NAME + '：多人模式（Client｜已連線！ [' + inttostr(con_num) + ']）';
    Button5.Enabled := true;
  end

  // 6) Server: 接收 新連線 'C[IP]'
  else if copy(s, 1, 1) = 'C' then
  begin
    //(紀錄新人IP)
    setlength(con_IP, length(con_IP)+1); // 重新設定con_IP陣列長度
    num := length(con_IP)-1; // 新人編號 (=IP清單長度-1)
    con_IP[num] := copy(s, 2, 10000);

    //(設定新人位置)
    setlength(newLoc, 2);
    newLoc := getAvailableLocation();
    
    {
    //(紀錄新人位置)
    setlength(con_loc, length(con_loc) + 2); // 重新設定con_loc陣列長度
    con_loc[length(con_loc)-2] := newLoc[0]; // X
    con_loc[length(con_loc)-1] := newLoc[1]; // Y
    updateFrame();
    }

    //(把"玩家編號、位置"傳給新人)
    UDPC.Host := con_IP[num];
    UDPC.Port := 8787;
    UDPC.send('N' + inttostr(num) + 'X' + inttostr(newLoc[0]) + 'Y' + inttostr(newLoc[1]));
    
    //(把"所有人的位置"傳給新人)
    i := 0;
    while i < num do
    begin
      UDPC.Send('L' + inttostr(i) + 'X' + inttostr(con_loc[i*2]) + 'Y' + inttostr(con_loc[i*2 + 1]));
      i := i + 1;
    end;

    //(把"新人位置"傳給其他人)
    // 寫在 teleport() 裡面了！

    //DEBUG
    if (DEBUG) then
    begin
      memo1.Lines.add('[_C] loc ' + inttostr(con_loc[length(con_loc)-1]) + inttostr(con_loc[length(con_loc)-2]));
      memo1.Lines.add('[_C] IP ' + UDPC.Host);
      memo1.Lines.add('[_C] Port ' + inttostr(UDPC.Port));
      memo1.Lines.add('[_C] client_num ' + inttostr(num));
    end;

    memo1.Lines.add('玩家 ' + inttostr(num) + ' 已加入。');
  end

  // 7) Client & Server: 接收 戰鬥開始 'A[攻擊方]D[防守方]'
  else if copy(s, 1, 1) = 'A' then
  begin
    // (得到自己的玩家編號、新的X和Y)
    temp := TStringList.Create;
    s_p := PChar(s);
    ExtractStrings(['A', 'D'], [], s_p, temp);
    num := strtoint(temp[0]);     // 攻擊方的編號
    opp_num := strtoint(temp[1]); // 防守方的編號
    temp.free;

    setlength(con_battling, length(con_battling) + 2);
    con_battling[length(con_battling)-2] := num;
    con_battling[length(con_battling)-1] := opp_num;

    if con_mode = 2 then // 如果是Server，要把戰鬥方發送給所有人
    begin
      i := 1;
      while i < length(con_IP) do
      begin
        if (i <> num) and (i <> opp_num) then
        begin
          UDPC.Host := con_IP[i];
          UDPC.Port := 8787; 
          UDPC.Send(s);
        end;
        
        i := i + 1;
      end;
    end;

    if (DEBUG) then
    begin
      memo1.Lines.add('發生了戰鬥！');
      memo1.Lines.add('正在戰鬥的玩家：');

      i := 0;
      while i < length(con_battling) do
      begin
        memo1.Lines.add(inttostr(con_battling[i]) + ' 和 ' + inttostr(con_battling[i+1]));
        i := i + 2;
      end;
    end;
  end

  // 8) Client & Server: 接收 戰鬥結束 'F[攻擊方]O[防守方]'
  else if copy(s, 1, 1) = 'F' then
  begin
    // (得到自己的玩家編號、新的X和Y)
    temp := TStringList.Create;
    s_p := PChar(s);
    ExtractStrings(['F', 'O'], [], s_p, temp);
    num := strtoint(temp[0]);     // 攻擊方的編號
    opp_num := strtoint(temp[1]); // 防守方的編號
    temp.free;

    // (尋找結束戰鬥的人位置在哪)
    i := 0;
    while i < length(con_battling) do
    begin
      if con_battling[i] = num then
        break
      else
        i := i + 1;
    end;

    // 把該位置刪掉(一次移兩筆資料)
    if length(con_battling) > 2 then
    begin
      while i < length(con_battling)-2 do
      begin
        con_battling[i] := con_battling[i+2];
        con_battling[i+1] := con_battling[i+3];
        i := i + 2;
      end;
    end;

    // 重設清單長度
    setlength(con_battling, length(con_battling) - 2);
    
    // 如果是Server，要把戰鬥結束資訊發送給所有人
    if con_mode = 2 then
    begin
      i := 1;
      while i < length(con_IP) do
      begin
        if (i <> num) and (i <> opp_num) then
        begin
          UDPC.Host := con_IP[i];
          UDPC.Port := 8787; 
          UDPC.Send(s);
        end;
        
        i := i + 1;
      end;
    end;

    if (DEBUG) then
    begin
      memo1.Lines.add('某個戰鬥結束了！');
      memo1.Lines.add('正在戰鬥的玩家：');

      i := 0;
      while i < length(con_battling) do
      begin
        memo1.Lines.add(inttostr(con_battling[i]) + ' 和 ' + inttostr(con_battling[i+1]));
        i := i + 2;
      end;
    end;
  end;
end;

end.