unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Menus, ExtCtrls, StdCtrls, Card, IdUDPServer, IdBaseComponent,
  IdComponent, IdUDPBase, IdUDPClient, winsock, IdSocketHandle;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Timer1: TTimer;
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
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Make3D(Mx, My, Md: Byte; Bmap: TBitmap);
    procedure Make2D(Mx, My, Md: Byte; Bmap: TBitmap);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure ComboBox1Select(Sender: TObject);
    function GetIPFromHost(var HostName, IPaddr, WSAErr: string): Boolean;
    procedure Button4Click(Sender: TObject);
    procedure UDPSUDPRead(Sender: TObject; AData: TStream;
      ABinding: TIdSocketHandle);
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

  Dmap: array[0..4, 0..4] of Byte; //3D視角中需要處理到的牆壁地圖
  Back_Bmap: TBitmap; //線條3D化要用到的點陣圖
  twoD_Bmap: TBitmap; //2D地圖用到的點陣圖

  // 一些變數
  LX, LY, Dir: Byte;
  Rect_B, Rect_M: TRect;
  con_mode: Byte;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
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
  con_mode := 0; //0:單人、1:Client、2:Server

  //把四張牌蓋起來
  Card1.Showdeck := true;
  Card2.Showdeck := true;
  Card3.Showdeck := true;
  Card4.Showdeck := true;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
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
  X, Y: ShortInt;
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

  Bmap.Canvas.Pen.Color := $ff00ff;
  Bmap.Canvas.Brush.Color := $ff00ff;
  // 畫玩家位置
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
end;

// 前進
procedure TForm1.Button1Click(Sender: TObject);
begin
  Dir := Dir or 16;
end;

// 左轉
procedure TForm1.Button2Click(Sender: TObject);
begin
  Dir := (Dir + 1) and 3;
end;

// 右轉
procedure TForm1.Button3Click(Sender: TObject);
begin
  Dir := (Dir + 3) and 3;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //釋放3D、2D用的點陣圖
  Back_Bmap.free;
  twoD_Bmap.free;
end;

procedure TForm1.ComboBox1Select(Sender: TObject);
var
    Host, IP, Err: string;
begin
  if ComboBox1.ItemIndex = 0 then
  begin
    Form1.Caption := GAME_NAME + '：單人模式';
    con_mode := 0;

    // 隱藏IP、PORT、連線按鈕組
    Label1.Visible := false;
    Label2.Visible := false;
    Edit1.Visible := false;
    Edit2.Visible := false;
    Button4.Visible := false;
    Button5.Visible := false;
  end else
  begin
    // 顯示IP、PORT、連線按鈕組
    Label1.Visible := true;
    Label2.Visible := true;
    Edit1.Visible := true;
    Edit2.Visible := true;
    Button4.Visible := true;
    Button5.Visible := true;

    if ComboBox1.ItemIndex = 1 then
    begin
      Form1.Caption := GAME_NAME + '：多人模式（Client｜未連線）';
      con_mode := 1;

      Edit1.Enabled := true;
      Edit2.Enabled := true;
      Button4.Enabled := true;
      Button5.Enabled := true;
      Button4.Caption := '連線！';
    end else
    if ComboBox1.ItemIndex = 2 then
    begin
      Form1.Caption := GAME_NAME + '：多人模式（Server｜未創建）';
      con_mode := 2;

      Edit1.Enabled := false;
      Edit2.Enabled := true;
      Button4.Enabled := true;
      Button5.Enabled := false;
      Button4.Caption := '建立伺服器！';
      
      // 嘗試得到自己的IP
      if GetIPFromHost(Host, IP, Err) then
      begin
        //Edit2.Text := Host;
        Edit1.Text := IP;
      end
      else
        MessageDlg(Err, mtError, [mbOk], 0);
      
      // 
    end;
  end;

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

procedure TForm1.Button4Click(Sender: TObject);
begin
  case con_mode of
  //Client嘗試連線
    1:
    begin
      Form1.Caption := GAME_NAME + '：多人模式（Client｜正在連線至主機...）';

      Edit1.Enabled := false;
      Edit2.Enabled := false;
      UDPC.Host := Edit1.Text;
      UDPC.Port := strtoint(Edit2.Text);
      UDPC.Send('C'); // 送出C嘗試連接，並得到一個序號
    end;

    //Server嘗試建立
    2:
    begin
      Form1.Caption := GAME_NAME + '：多人模式（Server｜正在嘗試建立新伺服器...）';
      Edit2.Enabled := false;
      UDPS.DefaultPort := strtoint(Edit2.Text);
      UDPS.Active := true;
      
      Form1.Caption := GAME_NAME + '：多人模式（Server｜就緒）';
    end;
  end;

end;

// 1.接收對方X、Y 2.接收對方出的牌'P
// C: 還要接收 對方給的序號 'N[序號]'
// S: 還要接收 新連線 'C[IP]'
procedure TForm1.UDPSUDPRead(Sender: TObject; AData: TStream; ABinding: TIdSocketHandle);
var
  s: string;
  len: integer;
begin
  len := AData.Size;
  setlength(s, len);
  Adata.Read(s[1], len);
  
  if copy(s, 0, 1) = 'C' then
  {
    UDPC.z}
end;

end.