unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, Card, IdUDPServer, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPClient, winsock, IdSocketHandle, ComCtrls,
  Gauges;

type
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
    Button7: TButton;
    Button6: TButton;
    Button8: TButton;
    Button9: TButton;
    Memo1: TMemo;
    Timer1: TTimer;
    Gauge1: TGauge;
    Timer_con: TTimer;
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
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    
    //Timer
    procedure Timer_conTimer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    
    //自訂函式
    procedure Make3D(Mx, My, Md: Byte; Bmap: TBitmap);
    procedure Make2D(Mx, My, Md: Byte; Bmap: TBitmap);
    procedure updateFrame();
    procedure disconnect();
    procedure conUISetVisible(bool: Boolean);
    function GetIPFromHost(var HostName, IPaddr, WSAErr: string): Boolean;

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
  GAME_NAME = 'D&D';

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
  con_loc: array of ShortInt; // 所有玩家的位置
  con_IP: array of string;    // 所有玩家的IP
  con_num: ShortInt;          // 我的編號 (Server = 0)
  con_connected: boolean;     // 檢查是否已連接

  // 抓本機IP用的變數
  Host, IP, Err: string;

  // 撲克牌用的變數
  CD: array[0..3] of TCard;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var i, j, k : integer;

begin
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
  
  CD[0].Value := 1+random(13);
  CD[0].Suit := tcardsuit(random(4));
  for i:=1 to 3 do
  begin
    k:=0;
    repeat
      CD[i].Value:=1+random(13);
      CD[i].Suit:=tcardsuit(random(4));
      for j:=0 to i-1 do
      begin
        if (CD[i].Value=CD[j].Value)and(CD[i].suit=CD[j].suit) then
        begin
          k:=1; break;
        end;
      end;
    until k=0;
  end;
end;

// 讓視窗產生後，可以馬上畫第一次地圖
procedure TForm1.Timer1Timer(Sender: TObject) ;
begin
  updateFrame();
  Timer1.Enabled := false;
end;

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
  Bmap.Canvas.Brush.Color := $2a2a2a;
  Bmap.Canvas.Rectangle(0, 0, Bmap.Width, Bmap.Height);

  // 1) 4格遠、正面的牆壁?? (方形、共5個)
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
  Bmap.Canvas.Brush.Color := $262626;
  if (Dmap[1, 2] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(7*LW, 7*LW), Point(7*LW, 23*LW), Point(10*LW, 20*LW), Point(10*LW, 10*LW)]);
  if (Dmap[3, 2] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(23*LW, 7*LW), Point(23*LW, 23*LW), Point(20*LW, 20*LW), Point(20*LW, 10*LW)]);

  // 5) 正面
  for X := 1 to 3 do
    if (Dmap[X, 2] and 1) = 1 then
      Bmap.Canvas.Rectangle(((X-1)*16 - 9)*LW, 7*LW, ((X-1)*16 + 7)*LW, 23*LW);

  // 6)
  Bmap.Canvas.Brush.Color := $242424;
  if (Dmap[1, 3] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(3*LW, 3*LW), Point(3*LW, 27*LW), Point(7*LW, 23*LW), Point(7*LW, 7*LW)]);
  if (Dmap[3, 3] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(27*LW, 3*LW), Point(27*LW, 27*LW), Point(23*LW, 23*LW), Point(23*LW, 7*LW)]);

  // 7) 正面
  for X := 1 to 3 do
    if (Dmap[X, 3] and 1) = 1 then
      Bmap.Canvas.Rectangle(((X-1)*24 -21)*LW, 3*LW, ((X-1)*24 + 3)*LW, 27*LW);

  // 8)
  Bmap.Canvas.Brush.Color := $222222;
  if (Dmap[1, 4] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(0, 0), Point(0, 30*LW), Point(3*LW, 27*LW), Point(3*LW, 3*LW)]);
  if (Dmap[3, 4] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(30*LW, 0), Point(30*LW, 30*LW), Point(27*LW, 27*LW), Point(27*LW, 3*LW)]);

  // 9)
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
    if i = con_num then
    begin
      // 不用畫自己的位置
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

// 前進
procedure TForm1.Button1Click(Sender: TObject);
var
  i: ShortInt;
begin
  Dir := Dir or 16;

  // > 如果可以移動，就改變座標 <
  if Dir > 15 then
  begin
    // 確認 1.玩家在迷宮範圍內 2.沒有碰到牆壁
    Dir := Dir and 15; // ???
    case Dir of
      0: if (LX + 1 <= Hmax) and (Lmap[LX+1, LY] and 1 = 0) then
        LX := LX + 1; // 東

      1: if (LY - 1 >= 0   ) and (Lmap[LX, LY-1] and 1 = 0) then
        LY := LY - 1; // 南

      2: if (LX - 1 >= 0   ) and (Lmap[LX-1, LY] and 1 = 0) then
        LX := LX - 1; // 西

      3: if (LY + 1 <= Vmax) and (Lmap[LX, LY+1] and 1 = 0) then
        LY := LY + 1; // 北
    end;
  end;

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
        UDPC.Host := con_IP[i];
        UDPC.Port := 8787; 
        UDPC.Send('L' + inttostr(con_num) + 'X' + inttostr(LX) + 'Y' + inttostr(LY));
        i := i+1;
      end;
    end;
  end;
  updateFrame();
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

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //釋放3D、2D用的點陣圖
  Back_Bmap.free;
  twoD_Bmap.free;
end;

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
  Timer_con.Enabled := false;
  ComboBox1.ItemIndex := 0;
  UDPC.Send('D' + inttostr(con_num));
  
  //初始化連線變數
  con_mode := 0; //0:單人、1:Client、2:Server
  setlength(con_loc, 2);
  con_loc[0] := 1;
  con_loc[1] := 1;
  setlength(con_IP, 1);
  con_num := 0;
  con_connected := false;
  
  UDPC.Active := false;
  UDPS.Active := false;

  ComboBox1.Enabled := true;
  conUISetVisible(false);
  Form1.Caption := GAME_NAME + '：單人模式';
end;

// UDPS接收資訊
procedure TForm1.UDPSUDPRead(Sender: TObject; AData: TStream; ABinding: TIdSocketHandle);
var
  s: string;
  len, i: integer;

  // 得到玩家新位置用
  X, Y, num: ShortInt;

  // 把字串分割用
  temp: TStringList;
  s_p: PChar;
begin
  // > 下載資料 <
  len := AData.Size;
  setlength(s, len);
  Adata.Read(s[1], len);
  memo1.Lines.add('UDPS> ' + s); // DEBUG

  // > 解析資料 <
  // 1) Client & Server: 接收地圖更新 L[玩家編號]X[座標]Y[座標]
  if copy(s, 1, 1) = 'L' then
  begin
    // (得到玩家編號、新的X和Y)
    temp := TStringList.Create;
    s_p := PChar(s);
    ExtractStrings(['L', 'X', 'Y'], [], s_p, temp);
    num := strtoint(temp[0]); //送出移動訊號的玩家編號
    X := strtoint(temp[1]);   //新的X值
    Y := strtoint(temp[2]);   //新的Y值
    temp.free;

    // (更新自己的con_loc[][])
    if (length(con_loc) < (num+1)*2) then
      setlength(con_loc, (num+1)*2);
    con_loc[num*2] := X;
    con_loc[num*2 + 1] := Y;

    //更新畫面
    updateFrame();
    
    // 如果是伺服器，要協助轉發訊息
    if con_mode = 2 then
    begin
      i := 1;
      while i <= (Length(con_IP)-1) do
      begin
        if i = num then
        begin
          i := i+1;
          continue;
        end
        else begin
          UDPC.Host := con_IP[i];
          UDPC.Port := 8787; 
          UDPC.Send(s);
          i := i+1;
        end;
      end; 
    end;
  end
  
  // 2) Client & Server: 接收 出牌結果
  else if copy(s, 1, 1) = 'P' then
  begin
    //
  end
  
  // 3) Client: 接收 對方給的序號 'N[序號]'
  else if copy(s, 1, 1) = 'N' then
  begin
    con_connected := true;
    con_num := strtoint(copy(s, 2, 10000));
    Form1.Caption := GAME_NAME + '：多人模式（Client｜已連線！ [' + inttostr(con_num) + ']）';
    Button5.Enabled := true;
  end

  // 4) Server: 接收 新連線 'C[IP]'
  else if copy(s, 1, 1) = 'C' then
  begin
    //(紀錄新玩家IP)
    setlength(con_IP, length(con_IP) + 1); // 重新設定con_IP陣列長度
    con_IP[length(con_IP)-1] := copy(s, 2, 10000);

    //(設定新玩家位置)
    setlength(con_loc, length(con_loc) + 2); // 重新設定con_loc陣列長度
    con_loc[length(con_loc)-1] := 1;
    con_loc[length(con_loc)-2] := 1;
    //TODO: 改成亂數

    //(送出玩家編號給Client)
    UDPC.Host := copy(s, 2, 10000);
    UDPC.Port := 8787;
    UDPC.send('N' + inttostr(length(con_IP)-1));

    //DEBUG
    memo1.Lines.add('C> IP ' + UDPC.Host);
    memo1.Lines.add('C> Port ' + inttostr(UDPC.Port));
    memo1.Lines.add('C> con_count ' + inttostr(length(con_IP)-1));
  end

  // 5) Server: 接收 玩家離開連線 'D[編號]'
  else if copy(s, 1, 1) = 'D' then
  begin
    // 把地圖擦掉
  end;
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

procedure TForm1.Button7Click(Sender: TObject);
begin
  Card1.ShowDeck:=false;
end;

procedure TForm1.Button6Click(Sender: TObject);
begin
  Card2.ShowDeck:=false;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  Card4.ShowDeck:=false;
end;

procedure TForm1.Button9Click(Sender: TObject);
begin
  Card3.ShowDeck:=false;
end;

end.
