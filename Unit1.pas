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
    
    //�ۭq�禡
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

    // ���^�ǭȪ��ۭq�禡
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
  horizontal_block = 37; //��ܪ���V�Ϯ׼�
  vertical_block = 27; //��ܪ��a�V�Ϯ׼�
  LW = 12;   //�C��������򥻪���
  MMW = 10; // �p�a�Ϥ��C��������򥻪��� miniMap_Width
  Hmax = 14; //��V�Ϲ���-1
  Vmax = 14; //�a�V�Ϲ���-1
  GAME_NAME = 'D&D v0.1';

var
  Form1: TForm1;
  
  //3D�������ݭn�B�z�쪺����a��
  Dmap: array[0..4, 0..4] of Byte; 

  // ����a��
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
  Back_Bmap: TBitmap; //�u��3D�ƭn�Ψ쪺�I�}��
  twoD_Bmap: TBitmap; //2D�a�ϥΨ쪺�I�}��

  // �@���ܼ�
  LX, LY, Dir: ShortInt;      // �ڪ���m
  Rect_B, Rect_M: TRect;

  // �s�u�Ϊ��ܼ�
  con_mode: Byte;             // �s���Ҧ�
  con_connected: boolean;     // �ˬd�O�_�w�s��
  con_loc: array of ShortInt; // �Ҧ����a����m
  con_IP: array of string;    // (Server�~��) �Ҧ����a��IP
  con_battling: array of ShortInt;// �Ҧ����a�O�_���b�԰�
  con_num: ShortInt;          // �ڪ��s�� (Server = 0)
  opp_num: ShortInt;          // ��誺�s�u�s��
  opp_card_string: string;    // ���X���d�]�r��^

  // �԰��Ϊ��ܼ�
  HP: ShortInt;               // ��q
  my_value: ShortInt;         // �ڥX���d��
  my_suit_num: ShortInt;      // �ڥX���d���s��
  opp_value: ShortInt;        // ���X���d��
  opp_suit_num: ShortInt;     // ���X���d���s��

  // �쥻��IP�Ϊ��ܼ�
  Host, IP, Err: string;

  // ���J�P�Ϊ��ܼ�
  CD: array[0..3] of TCard;

  // DEBUG �}��
  DEBUG: boolean;
implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  DEBUG := false;
  Form1.caption := GAME_NAME;

  //��l���x�s�u��3D�Ϊ��I�}��
  Back_Bmap := TBitmap.Create;
  Back_Bmap.Width := 30 * LW;
  Back_Bmap.Height := 30 * LW;

  //��l���x�s2D�a�Ϫ��I�}��
  twoD_Bmap := Tbitmap.Create;
  twoD_Bmap.width := Hmax * MMW + 10;
  twoD_Bmap.Height := Vmax * MMW + 10;

  //�ܼƪ�l��
  LX := 1; // ���ax��m
  LY := 1; // ���ay��m
  Dir := 1; // ���a���諸��V

  //�԰��ƭȪ�l��
  HP := 100;
  Gauge1.Progress := HP;
  opp_card_string := '';
  opp_num := -1;

  //��l��UDP����
  UDPC.Active := false;
  UDPS.Active := false;
  
  //��l�Ƴs�u�ܼ�
  con_mode := 0; //0:��H�B1:Client�B2:Server
  setlength(con_loc, 2);
  con_loc[0] := 1;
  con_loc[1] := 1;
  setlength(con_IP, 1);
  con_num := 0;
  setlength(con_battling, 0);
  con_connected := false;
  
  //��|�i�P�\�_��
  Card1.Showdeck := true;
  Card2.Showdeck := true;
  Card3.Showdeck := true;
  Card4.Showdeck := true;

  CD[0]:=Card1;
  CD[1]:=Card2;
  CD[2]:=Card3;
  CD[3]:=Card4;

  // �N�P�\�~�P
  shuffleCards();
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //����3D�B2D�Ϊ��I�}��
  Back_Bmap.free;
  twoD_Bmap.free;
end;

// DEBUG �}��
procedure TForm1.DEBUG_btnClick(Sender: TObject);
begin
  DEBUG := not DEBUG;
  if (DEBUG) then
    memo1.Lines.add('/ DEBUG mode: �ҥ� /')
  else
    memo1.Lines.add('/ DEBUG mode: ���� /');
end;



// ----------------------------------------------------------------
// �e���p��
// ----------------------------------------------------------------

// ���������ͫ�A�i�H���W�e�Ĥ@���a��
procedure TForm1.Timer1Timer(Sender: TObject);
begin
  updateFrame();
  Timer1.Enabled := false;
end;

// �I�sMake3D�B2D��s�e��
procedure TForm1.updateFrame();
begin
  // > ��ܮy�Ф�r <
  L_LX.caption := 'X: ' + inttostr(LX);
  L_LY.caption := 'Y: ' + inttostr(LY);
  L_Dir.caption := '��V: ' + inttostr(Dir);

  // > ����� <
  Make3D(LX, LY, Dir, Back_Bmap);
  Back_Bmap.Canvas.CopyMode := cmSrcCopy;
  Form1.Canvas.Draw(16, 16, Back_Bmap);

  // > �e2D�a�� <
  Make2D(LX, LY, Dir, twoD_Bmap);
  Form1.Canvas.Draw(Back_Bmap.Width+30, 16, twoD_Bmap);
end;

procedure TForm1.Make3D(Mx, My, Md: Byte; Bmap: TBitmap);
var
  X, Y: ShortInt;
begin
  // > 3D�������ݭn�B�z�쪺����a��Dmap <
  for X := 0 to 4 do
    for Y := 0 to 4 do
      Dmap[X, Y] := 1;

  case Md of
    0: begin // �p�G�¦V�F��
      for X := 4 downto 0 do
        for Y := -2 to 2 do
          if (Mx+X <= Hmax) and (My+Y >= 0) and (My+Y <= Vmax) then Dmap[Y+2, 4-X] := Lmap[Mx+X, My+Y];
    end;

    1: begin // �p�G�¦V�n��
      for Y := -4 to 0 do
        for X := -2 to 2 do
          if (My+Y >= 0) and (Mx+X >= 0) and (Mx+X <= Hmax) then Dmap[X+2, Y+4] := Lmap[Mx+X, My+Y];
    end;

    2: begin // �p�G�¦V����
      for X := -4 to 0 do
        for Y := 2 downto -2 do
          if (Mx+X >= 0) and (My+Y >= 0) and (My+Y <= Vmax) then Dmap[2-Y, 4+X] := Lmap[Mx+X, My+Y];
    end;

    3: begin // �p�G�¦V�_��
      for Y := 4 downto 0 do
        for X := 2 downto -2 do
          if (My+Y <= Hmax) and (Mx+X >= 0) and (Mx+X <= Hmax) then Dmap[2-X, 4-Y] := Lmap[Mx+X, My+Y];
    end;
  end;

  // > �N�u��3Dø�s�b�I�}�ϤW <
  Bmap.Canvas.Pen.Width := 2;
  Bmap.Canvas.Pen.Color := $ffffff;

  // 0) �e����
  Bmap.Canvas.Brush.Color := $2f2f2f;
  Bmap.Canvas.Rectangle(0, 0, Bmap.Width, Bmap.Height);

  // 1) 4�滷�B���������?? (��ΡB�@5��)
  Bmap.Canvas.Brush.Color := $222222;
  for X := 0 to 4 do
    if (Dmap[X, 0] and 1) = 1 then
      Bmap.Canvas.Rectangle(X*6*LW, 12*LW, (X*6 + 6)*LW, 18*LW);
  
  // 2) 3�滷�B���������? (��ΡB�@4��)
  Bmap.Canvas.Brush.Color := $282828;
  if (Dmap[0, 1] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(0, 10*LW), Point(0, 20*LW), Point(6*LW, 18*LW), Point(6*LW, 12*LW)]);
  if (Dmap[1, 1] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(10*LW, 10*LW), Point(10*LW, 20*LW), Point(12*LW, 18*LW), Point(12*LW, 12*LW)]);
  if (Dmap[3, 1] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(20*LW, 10*LW), Point(20*LW, 20*LW), Point(18*LW, 18*LW), Point(18*LW, 12*LW)]);
  if (Dmap[4, 1] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(30*LW, 10*LW), Point(30*LW, 20*LW), Point(24*LW, 18*LW), Point(24*LW, 12*LW)]);
  
  // 3) 3�滷�B��������� (��ΡB�@3��)
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

  // 4) 2�滷�B��������� (��ΡB�@2��)
  Bmap.Canvas.Brush.Color := $303030;
  if (Dmap[1, 2] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(7*LW, 7*LW), Point(7*LW, 23*LW), Point(10*LW, 20*LW), Point(10*LW, 10*LW)]);
  if (Dmap[3, 2] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(23*LW, 7*LW), Point(23*LW, 23*LW), Point(20*LW, 20*LW), Point(20*LW, 10*LW)]);

  // 5) ����
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

  // 7) ���e�����
  Bmap.Canvas.Brush.Color := $505050;
  for X := 1 to 3 do
    if (Dmap[X, 3] and 1) = 1 then
      Bmap.Canvas.Rectangle(((X-1)*24 -21)*LW, 3*LW, ((X-1)*24 + 3)*LW, 27*LW);

  // 8) ���k�����
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
  
  // �e�a�ϭI��
  Bmap.Canvas.Brush.Color := $222222;
  Bmap.Canvas.Rectangle(0, 0, Bmap.Width, Bmap.Height);

  // �e���
  Bmap.Canvas.Brush.Color := $ffff00;
  for X := 0 to Hmax do
    for Y := 0 to Vmax do
    begin
      if Lmap[X, Y] = 1 then Bmap.Canvas.Rectangle(X*MMW, Y*MMW, (X+1)*MMW, (Y+1)*MMW);
    end;

  // �e���a��m
  Bmap.Canvas.Pen.Color := $ff00ff;
  Bmap.Canvas.Brush.Color := $ff00ff;
  Bmap.Canvas.Rectangle(Mx*MMW, My*MMW, (Mx+1)*MMW, (My+1)*MMW);

  // �e���a�¦V
  case Md of
    // �F
    0: Bmap.Canvas.Rectangle((Mx+1)*MMW +2, My*MMW +2, (Mx+1)*MMW +4, (My+1)*MMW -2); 
    
    // �_
    1: Bmap.Canvas.Rectangle(Mx*MMW +2, My*MMW -2, (Mx+1)*MMW -2, My*MMW -4);
    
    // ��
    2: Bmap.Canvas.Rectangle(Mx*MMW -2, My*MMW +2, Mx*MMW -4, (My+1)*MMW -2);

    // �n
    3: Bmap.Canvas.Rectangle(Mx*MMW +2, (My+1)*MMW +2, (Mx+1)*MMW -2, (My+1)*MMW +4);
  end; 

  // �e��L���a��m
  Bmap.Canvas.Pen.Color := $00ffff;
  Bmap.Canvas.Brush.Color := $00ffff;
  i := 0;
  while i < Length(con_loc) do
  begin
    if (i = con_num) or (con_loc[i] = -1) then
    begin
      // ���εe�ۤv����m�B���εe�_�u���a����m
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
// ���ʡB���
// ----------------------------------------------------------------

// �e�i
procedure TForm1.Button1Click(Sender: TObject);
var
  i, pt_battling_list, battling_num, len_XY_list: ShortInt;
  battling_X_list, battling_Y_list: array of ShortInt;
  can_move: boolean;
begin
  setlength(battling_X_list, 0);
  setlength(battling_Y_list, 0);

  // �s�y�X���b��Ԫ���l�M��
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
  // > �p�G�i�H���ʡA�N���ܮy�� <
  if Dir > 15 then
  begin
    // �T�{ 1.���a�b�g�c�d�� 2.�S���I�����
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

        if (can_move = true) then LX := LX + 1; // �F 
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

        if (can_move = true) then LY := LY - 1; // �n
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

        if (can_move = true) then LX := LX - 1; // ��
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

        if (can_move = true) then LY := LY + 1; // �_
      end;
    end;
  end;

  // > ��s���a����m���Ҧ��H <
  con_loc[con_num*2] := LX;
  con_loc[con_num*2 + 1] := LY;

  case con_mode of
    1: // Client
    UDPC.send('L' + inttostr(con_num) + 'X' + inttostr(LX) + 'Y' + inttostr(LY));
    
    2: // Server
    begin
      // �ǰe���Ҧ��H
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

  updateFrame(); // ��s2D�B3D�a��
  collectionCheck(1); // �ˬd�O�_���J��H
end;

// ����
procedure TForm1.Button2Click(Sender: TObject);
begin
  Dir := (Dir + 1) and 3;
  updateFrame();
end;

// �k��
procedure TForm1.Button3Click(Sender: TObject);
begin
  Dir := (Dir + 3) and 3;
  updateFrame();
end;

// �X�P
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

// �~�P
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

// �ƨg�~�P�ʵe
procedure TForm1.Timer_shuffleTimer(Sender: TObject);
var
  times: ShortInt;
begin
  times := 0;
  while (times < 50) do // <--��o�̥i�H���~�P�ɶ�
  begin
    shuffleCards();
    times := times + 1;
  end;
  
  Timer_shuffle.Enabled := false;
  Button_showcard1.Visible := true;
  Button_showcard2.Visible := true;
  Button_showcard3.Visible := true;
  Button_showcard4.Visible := true;
  Button_showcard1.Caption := '�X�o�i';
  Button_showcard4.Caption := '�X�o�i';  
end;

// �ˬd�O�_���J��H
procedure TForm1.collectionCheck(mode: integer);
var
  i, k, player_count: integer;
begin
  player_count := (length(con_loc) div 2); // �ثe���A�����`�H��
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
      memo1.Lines.add('> �o�;԰��I <');
      memo1.Lines.add('');

      case mode of
        1: // �D�ʼ��H
        begin
          Button_showcard1.Enabled := true;
          Button_showcard2.Enabled := true;
          Button_showcard3.Enabled := true;
          Button_showcard4.Enabled := true;
          card1.ShowDeck := false;
          card2.ShowDeck := false;
          card3.ShowDeck := false;
          card4.ShowDeck := false;

          memo1.Lines.add('�A�e�� ' + inttostr(opp_num) + ' �����a�F�I');
          memo1.Lines.add('�A�㦳�u�աI');
          memo1.Lines.add('�ֿ�@�i�Ʀr�j���P�����I');
          memo1.Lines.add('');

          // �o�T�����D�԰����H�A���L�̧�s�ۤv�� con_battling
          // A[������]D[���u��]
          case con_mode of
          1: // Client
          UDPC.send('A' + inttostr(con_num) + 'D' + inttostr(opp_num));
          
          2: // Server
          begin
            // �ǰe���Ҧ��H
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

        2: // �Q��
        begin
          Button_showcard1.Enabled := true;
          Button_showcard2.Enabled := true;
          Button_showcard3.Enabled := false;
          Button_showcard4.Enabled := false;
          card1.ShowDeck := false;
          card2.ShowDeck := false;
          card3.ShowDeck := true;
          card4.ShowDeck := true;
          
          memo1.Lines.add('�A�Q ' + inttostr(opp_num) + ' �����a�����F�I');
          memo1.Lines.add('�A�B��H��...');
          memo1.Lines.add('�ֿ�@�i�Ʀr�j���P�Ϩ�I');
          memo1.Lines.add('');
        end;
      end;

      Timer_shuffle.Enabled := true;
      break;
    end;
  end;
end;

// �X�P��G1.��ۤv���P�x�s 2.�T�{���O�_�w�X�P
procedure TForm1.complete_card_selection(x: integer);
var
  i: integer;
  s: string;
begin
  // 1. �����X�P���s
  Button_showcard1.Enabled := false;
  Button_showcard2.Enabled := false;
  Button_showcard3.Enabled := false;
  Button_showcard4.Enabled := false;
  
  // ���@�B�|�ӫ��s��r�������X�P���p
  Button_showcard1.Visible := true;
  Button_showcard1.Caption := '�A���P'; 
  Button_showcard4.Visible := true;
  Button_showcard4.Caption := '��誺�P';
  Button_showcard2.Visible := false;
  Button_showcard3.Visible := false;

  // �\�P
  for i:=0 to 3 do
  begin
    CD[i].ShowDeck := true;
  end;
  
  {
    Tcardsuit(0) : �®�
    Tcardsuit(1) : ���
    Tcardsuit(2) : ����
    Tcardsuit(3) : ����
  }
  // 2. ��P�s�i my_value �M my_suit_num
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

  // 3. ��X�ۤv�X���P
  s := '> �A�X�F ';
  case my_suit_num of
    1: s := s + '[ ���� ' + inttostr(my_value) + ' ]';
    2: s := s + '[ ��� ' + inttostr(my_value) + ' ]';
    3: s := s + '[ ���� ' + inttostr(my_value) + ' ]';
    4: s := s + '[ �®� ' + inttostr(my_value) + ' ]';
  end;
  memo1.Lines.add(s);
  CD[0].value := my_value; // ���Ĥ@�i�P��ܦۤv����
  CD[0].ShowDeck := false;

  // 4. �T�{���O�_�w�X�P
  if opp_card_string = '' then
  // 4-1. ��襼�X�G�Ǧۤv���P�L�h
  begin
    memo1.Lines.add('> ���b���ݹ��X�P...');

    // �e�X P[�ۤv���Ǹ�]O[��誺�s��]S[�ۤv�����s��]V[�ۤv���P��]
    case con_mode of
      1: // Client
      begin
        UDPC.send('P' + inttostr(con_num) + 'O' + inttostr(opp_num) + 'S' + inttostr(my_suit_num) + 'V' + inttostr(my_value)); //�H��server��o
      end;

      2: // Server
      begin
        // �s����O[���s��]
        UDPC.Host := con_IP[opp_num];
        UDPC.Port := 8787; 
        UDPC.send('P' + inttostr(con_num) + 'O' + inttostr(opp_num) + 'S' + inttostr(my_suit_num) + 'V' + inttostr(my_value)); //�H��server��o
      end;
    end;
  end
  
  // 4-2. ���w�X�G������G�A�öǰe���G
  else begin 
    // �� R[Ĺ�a�s��]O[����H�s��]S[�ۤv�����s��]V[�ۤv���P��] �����
    // �s�� F[������]O[���u��] ��ܵ������
    case con_mode of
      1: // Client
      begin
        UDPC.send('R' + getWinner(opp_card_string) + 'O' + inttostr(opp_num) + 'S' + inttostr(my_suit_num) + 'V' + inttostr(my_value)); //�H��server��o
        UDPC.send('F' + inttostr(con_num) + 'O' + inttostr(opp_num));
      end;

      2: // Server
      begin
        UDPC.Host := con_IP[opp_num];
        UDPC.Port := 8787; 
        UDPC.send('R' + getWinner(opp_card_string) + 'O' + inttostr(opp_num) + 'S' + inttostr(my_suit_num) + 'V' + inttostr(my_value)); //�H��server��o
        
        // �s���ǰe������԰T��
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
  // �ѪR��ƥ�
  temp: TStringList;
  s_p: PChar;
begin
  // �ѪR���
  temp := TStringList.Create;
  s_p := PChar(opp_card_string);
  ExtractStrings(['P', 'O', 'S', 'V'], [], s_p, temp);
  opp_suit_num := strtoint(temp[2]);
  opp_value := strtoint(temp[3]);

  // �P�_Ĺ�a�G����P��
  winner_num := -1;
  if (my_value > opp_value) then
  begin
    winner_num := con_num;
    outputBattleResut(1); // Ĺ
  end
  else if (my_value < opp_value) then
  begin
    winner_num := opp_num;
    outputBattleResut(0); // ��
  end
  else if (my_value = opp_value) then
  begin
    // �P�ȬۦP�A�A����
    if (my_suit_num > opp_suit_num) then
    begin
      winner_num := con_num;
      outputBattleResut(1); // Ĺ
    end
    else if (my_suit_num < opp_suit_num) then
    begin
      winner_num := opp_num;
      outputBattleResut(0); // ��
    end
    else
    begin
      winner_num := -1;
      outputBattleResut(-1); // ����
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
  s := '> ���X�F ';
  case opp_suit_num of
    1: begin
      s := s + '[ ���� ' + inttostr(opp_value) + ' ]';
      CD[3].Suit := Tcardsuit(2);
    end;

    2: begin
      s := s + '[ ��� ' + inttostr(opp_value) + ' ]';
      CD[3].Suit := Tcardsuit(1);
    end;

    3: begin
      s := s + '[ ���� ' + inttostr(opp_value) + ' ]';
      CD[3].Suit := Tcardsuit(3);
    end;

    4: begin
      s := s + '[ �®� ' + inttostr(opp_value) + ' ]';
      CD[3].Suit := Tcardsuit(0);
    end;
  end;
  memo1.Lines.add(s);
  CD[3].value := opp_value;
  CD[3].ShowDeck := false;

  // ��XĹ�a
  memo1.Lines.add('�ССССССССССС�');
  s := '> ��Ե��G�G';
  if (battle_result = 0) then
  begin
    s := s + ' �A��F...';
    memo1.Lines.add(s);
    damage();
  end else
  if (battle_result = 1) then
  begin
    s := s + ' �AĹ�F�I';
    memo1.Lines.add(s);
    memo1.Lines.add('');
    memo1.Lines.add('�]�A�����F�԰��I�^');
    memo1.Lines.add('');

    setlength(new_loc, 2);
    new_loc := getAvailableLocation();
    teleport(new_loc[0], new_loc[1]);
  end else
  if (battle_result = -1) then
  begin
    s := s + ' ����';
    memo1.Lines.add(s);
    damage();
  end;

  opp_card_string := '';
  Button1.Enabled := true;
  Button2.Enabled := true;
  Button3.Enabled := true;
end;

// ����
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
  memo1.Lines.add('�]���� ' + inttostr(HPdamage) + ' �I�ˮ`�^');

  if (HP = 0) then
  begin
    gameOver();
  end
  else begin
    memo1.Lines.add('�]�A�T�V�a�����F�԰�...�^');
    memo1.Lines.add('');
    setlength(new_loc, 2);
    new_loc := getAvailableLocation();
    teleport(new_loc[0], new_loc[1]);
  end;
end;

// �ǰe����w����m
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

  memo1.Lines.add('�A�w�g�ǰe�� (' + inttostr(x) + ', ' + inttostr(y) + ')�C');
  updateFrame();
end;

// �M��ťժ���m
function TForm1.getAvailableLocation(): TSIArray;
var
  validate_loc: boolean;
  i: ShortInt;
  new_XY: TSIArray;

begin
  randomize; // �H���ƶüƺؤl
  setlength(new_XY, 2); // �]�w�^��array����

  repeat
    validate_loc := true;
    new_XY[0] := random(Hmax + 1); // 0 ~ Hmax
    new_XY[1] := random(Vmax + 1); // 0 ~ Vmax
    
    // �ˬd��l�O�_�����
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
  // ��L�{���n��b�o��
  memo1.Lines.add('�]�A�w���h������q�^');
  memo1.Lines.add('�]�w�P���A���_�}�s�u�^');
  disconnect();
end;
// ----------------------------------------------------------------
// �s�u�]�w
// ----------------------------------------------------------------

// ��ܺ����Ҧ�
procedure TForm1.ComboBox1Select(Sender: TObject);
begin
  if ComboBox1.ItemIndex = 0 then
  begin
    Form1.Caption := GAME_NAME + '�G��H�Ҧ�';
    con_mode := 0;
    // ����IP�BPORT�B�s�u���s��
    conUISetVisible(false); 
  end
  else begin
    // ���IP�BPORT�B�s�u���s��
    conUISetVisible(true); 

    // ���ձo��ۤv��IP
    IP := '';
    if GetIPFromHost(Host, IP, Err) then
    begin
      Edit1.Text := IP;
    end else
      MessageDlg(Err, mtError, [mbOk], 0);

    // �]�w�s�u���s��r
    if ComboBox1.ItemIndex = 1 then // Client
    begin 
      Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Client�U���s�u�^';
      con_mode := 1;

      Edit1.Enabled := true;
      Edit2.Enabled := true;
      Button4.Enabled := true;
      Button5.Enabled := false;
      Button4.Caption := '�s�u�I';
    end else
    if ComboBox1.ItemIndex = 2 then // Server
    begin
      Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Server�U���Ыء^';
      con_mode := 2;

      Edit1.Enabled := false;
      Edit2.Enabled := true;
      Button4.Enabled := true;
      Button5.Enabled := false;
      Button4.Caption := '�إߦ��A���I';
    end;
  end;
end;

// ���U�إ߳s�u
procedure TForm1.Button4Click(Sender: TObject);
begin

  Edit1.Enabled := false;
  Edit2.Enabled := false;
  Button4.Enabled := false;
  Button5.Enabled := false;
  ComboBox1.Enabled := false;
  opp_card_string := '';
  opp_num := -1;
  
  // �P�_�s�u�Ҧ�
  // �s�u�Ҧ����G
  case con_mode of
    1: //1. Client ���ճs�u
    begin
      Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Client�U���b�s�u�ܥD��...�^';

      UDPC.Host := Edit1.Text;
      UDPC.Port := strtoint(Edit2.Text);

      UDPS.DefaultPort := 8787;
      UDPS.Active := true;

      Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Client�U���b�ǰe�A��IP�G' + IP + '...�^';
      con_connected := false;
      UDPC.Send('C' + IP); // �e�XC[IP]���ճs���A�ño��@�ӧǸ�

      // ���ݽT�{�O�_������Ǹ�
      Timer_con.Interval := 3000; //3s
      Timer_con.Enabled := true;
      Timer_con.Tag := 1;
    end;

    2: //2. ���իإ� Server
    begin
      Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Server�U���b���իإ߷s���A��...�^';

      UDPS.DefaultPort := strtoint(Edit2.Text);
      UDPS.Active := true;

      con_IP[0] := Edit1.Text;
      
      Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Server�U�N���^';
      Button5.Enabled := true;
    end;
  end;

end;

// Client�s�u��A���ݽT�{�O�_������s�u���\���T��
procedure TForm1.Timer_conTimer(Sender: TObject);
begin
  if con_connected = false then
  begin
    //���\���a�������
    Button5.Enabled := true;

    Timer_con.Tag := Timer_con.Tag + 1;
    UDPC.Send('C' + IP); // �e�XC[IP]���ճs���A�ño��@�ӧǸ�
    Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Client�U�s�u���ѡA���b���ղ�' + inttostr(Timer_con.Tag) + '��...�^';
  end;
end;

// ���U�_�}�s��
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

  // ��X�P�\��T��
  CD[0].ShowDeck := true;
  CD[1].ShowDeck := true;
  CD[2].ShowDeck := true;
  CD[3].ShowDeck := true;
  Button_showcard1.Visible := false;
  Button_showcard2.Visible := false;
  Button_showcard3.Visible := false;
  Button_showcard4.Visible := false;
  
  // �}�Ҳ��ʥ\��
  Button1.Enabled := true;
  Button2.Enabled := true;
  Button3.Enabled := true;

  // ��l�Ƴs�u�ܼ�
  con_mode := 0; //0:��H�B1:Client�B2:Server
  setlength(con_IP, 1);
  con_num := 0;
  setlength(con_battling, 0);
  con_connected := false;

  // ���m���
  HP := 100;
  Gauge1.Progress := HP;

  // �~�դp�a��
  setlength(con_loc, 2);
  con_loc[0] := LX;
  con_loc[1] := LY;
  updateFrame();
  
  ComboBox1.Enabled := true;
  conUISetVisible(false);
  Form1.Caption := GAME_NAME + '�G��H�Ҧ�';
end;

// ���/���ós�u��
procedure TForm1.conUISetVisible(bool: Boolean);
begin
  Label1.Visible := bool;
  Label2.Visible := bool;
  Edit1.Visible := bool;
  Edit2.Visible := bool;
  Button4.Visible := bool;
  Button5.Visible := bool;
end;

// �o��ۤv�q����IP
function TForm1.GetIPFromHost (var HostName, IPaddr, WSAErr: string): Boolean;
type
    Name = array[0..100] of Char;     // Delphi 7(D7) ���g�k
    // Name = array[0..100] of AnsiChar;    // Delphi2009 �H�᪺�g�k
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

// UDPS������T
procedure TForm1.UDPSUDPRead(Sender: TObject; AData: TStream; ABinding: TIdSocketHandle);
var
  s: string;
  len, i: integer;

  // �o�쪱�a�s��m��
  X, Y, num, opp_num, move_num: ShortInt;
  newLoc: TSIArray;

  // ��r����Υ�
  temp: TStringList;
  s_p: PChar;
begin
  // > �U����� <
  len := AData.Size;
  setlength(s, len);
  Adata.Read(s[1], len);
  if (DEBUG) then memo1.Lines.add('[UDPS] ' + s); // DEBUG

  // > �ѪR��� <
  // 1) Client & Server: �����a�ϧ�s L[���a�s��]X[�y��]Y[�y��]
  if copy(s, 1, 1) = 'L' then
  begin
    // (�o�쪱�a�s���B�s��X�MY)
    temp := TStringList.Create;
    s_p := PChar(s);
    ExtractStrings(['L', 'X', 'Y'], [], s_p, temp);
    move_num := strtoint(temp[0]); //�e�X���ʰT�������a�s��
    X := strtoint(temp[1]);   //�s��X��
    Y := strtoint(temp[2]);   //�s��Y��
    temp.free;

    // (��s�ۤv��con_loc[][])
    if length(con_loc) < ((move_num+1)*2) then
      setlength(con_loc, (move_num+1)*2);
    con_loc[move_num*2] := X;
    con_loc[move_num*2 + 1] := Y;

    //��s�e��
    updateFrame();

    //�T�{�I��
    collectionCheck(2);
    
    // �p�G�O���A���A�n��U��o�T��
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

  // 2) Client & Server: ���� ���a���}�s�u 'D[�s��]'
  else if copy(s, 1, 1) = 'D' then
  begin
    // ��a������
    num := strtoint(copy(s, 2, 10));
    con_loc[num*2] := -1;
    con_loc[num*2 + 1] := -1;

    updateFrame();

    // �p�G�O���A���A�n��U��o�T��
    if con_mode = 2 then
    begin
      con_IP[num] := '-1'; // �u��Server�|�s�j�a��IP

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
  
  // 3) Client & Server: �]�C�X���H�^���� �X�P���G 'P[�X�P�̽s��]O[����H�s��]S[���s��]V[�P��]'
  else if copy(s, 1, 1) = 'P' then
  begin
    // �p�G�OClient�G�s���G�iopp_card_string��
    if con_mode = 1 then
    begin
      opp_card_string := s;
      memo1.Lines.add('> ���w�X�P�I');
    end

    // �p�G�OServer�G�T�{����H�]�O�_�H���ۤv�^�B��H
    else if con_mode = 2 then
    begin
      // �ѪR���
      temp := TStringList.Create;
      s_p := PChar(s);
      ExtractStrings(['P', 'O', 'S', 'V'], [], s_p, temp);

      // �T�{�O�_�H���ۤv
      if (temp[1] = '0') then
      begin
        opp_card_string := s; //�H���ۤv
        memo1.Lines.add('> ���w�X�P�I');
      end
      else begin
        // ��e������H
        UDPC.Host := con_IP[strtoint(temp[1])];
        UDPC.Port := 8787;
        UDPC.send(s);
      end;

      temp.free;
    end;
  end

  // 4) Client & Server: (���X���H) ���� Ĺ�a 'R[Ĺ�a�s��]O[����H�s��]S[�ۤv�����s��]V[�ۤv���P��]'
  else if copy(s, 1, 1) = 'R' then
  begin
    // ��Ѹ��
    temp := TStringList.Create;
    s_p := PChar(s);
    ExtractStrings(['R', 'O', 'S', 'V'], [], s_p, temp);

    opp_suit_num := strtoint(temp[2]);
    opp_value := strtoint(temp[3]);

    // Client ������R��output���G
    if con_mode = 1 then
    begin
      if temp[0] = inttostr(con_num) then
        outputBattleResut(1)  // Ĺ
      else if temp[0] = '-1' then
        outputBattleResut(-1) // ����
      else
        outputBattleResut(0); // ��
    end

    // Server ���T�{����H�]�O�_�H���ۤv�^�B��H
    else if con_mode = 2 then
    begin
      // �H���ۤv
      if (temp[1] = '0') then
      begin
        if temp[0] = inttostr(con_num) then
          outputBattleResut(1)  // Ĺ
        else if temp[0] = '-1' then
          outputBattleResut(-1) // ����
        else
          outputBattleResut(0); // ��
      end

      // �n��e������H
      else begin
        UDPC.Host := con_IP[strtoint(temp[1])];
        UDPC.Port := 8787;
        UDPC.send(s);
      end;
    end;

    temp.free;
  end
  
  // 5) Client: ���� ���A�������Ǹ� 'N[�Ǹ�]X[�ǰe��m]Y[�ǰe��m]'
  else if copy(s, 1, 1) = 'N' then
  begin
    // (���p�ɾ�����A���A�ˬd�O�_���s�W)
    con_connected := true;

    // (�o��ۤv�����a�s���B�s��X�MY)
    temp := TStringList.Create;
    s_p := PChar(s);
    ExtractStrings(['N', 'X', 'Y'], [], s_p, temp);
    num := strtoint(temp[0]); //�e�X���ʰT�������a�s��
    X := strtoint(temp[1]);   //�s��X��
    Y := strtoint(temp[2]);   //�s��Y��
    temp.free;

    // ��ۤv�ǰe����w����m
    con_num := num;
    teleport(X, Y);
    
    Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Client�U�w�s�u�I [' + inttostr(con_num) + ']�^';
    Button5.Enabled := true;
  end

  // 6) Server: ���� �s�s�u 'C[IP]'
  else if copy(s, 1, 1) = 'C' then
  begin
    //(�����s�HIP)
    setlength(con_IP, length(con_IP)+1); // ���s�]�wcon_IP�}�C����
    num := length(con_IP)-1; // �s�H�s�� (=IP�M�����-1)
    con_IP[num] := copy(s, 2, 10000);

    //(�]�w�s�H��m)
    setlength(newLoc, 2);
    newLoc := getAvailableLocation();
    
    {
    //(�����s�H��m)
    setlength(con_loc, length(con_loc) + 2); // ���s�]�wcon_loc�}�C����
    con_loc[length(con_loc)-2] := newLoc[0]; // X
    con_loc[length(con_loc)-1] := newLoc[1]; // Y
    updateFrame();
    }

    //(��"���a�s���B��m"�ǵ��s�H)
    UDPC.Host := con_IP[num];
    UDPC.Port := 8787;
    UDPC.send('N' + inttostr(num) + 'X' + inttostr(newLoc[0]) + 'Y' + inttostr(newLoc[1]));
    
    //(��"�Ҧ��H����m"�ǵ��s�H)
    i := 0;
    while i < num do
    begin
      UDPC.Send('L' + inttostr(i) + 'X' + inttostr(con_loc[i*2]) + 'Y' + inttostr(con_loc[i*2 + 1]));
      i := i + 1;
    end;

    //(��"�s�H��m"�ǵ���L�H)
    // �g�b teleport() �̭��F�I

    //DEBUG
    if (DEBUG) then
    begin
      memo1.Lines.add('[_C] loc ' + inttostr(con_loc[length(con_loc)-1]) + inttostr(con_loc[length(con_loc)-2]));
      memo1.Lines.add('[_C] IP ' + UDPC.Host);
      memo1.Lines.add('[_C] Port ' + inttostr(UDPC.Port));
      memo1.Lines.add('[_C] client_num ' + inttostr(num));
    end;

    memo1.Lines.add('���a ' + inttostr(num) + ' �w�[�J�C');
  end

  // 7) Client & Server: ���� �԰��}�l 'A[������]D[���u��]'
  else if copy(s, 1, 1) = 'A' then
  begin
    // (�o��ۤv�����a�s���B�s��X�MY)
    temp := TStringList.Create;
    s_p := PChar(s);
    ExtractStrings(['A', 'D'], [], s_p, temp);
    num := strtoint(temp[0]);     // �����誺�s��
    opp_num := strtoint(temp[1]); // ���u�誺�s��
    temp.free;

    setlength(con_battling, length(con_battling) + 2);
    con_battling[length(con_battling)-2] := num;
    con_battling[length(con_battling)-1] := opp_num;

    if con_mode = 2 then // �p�G�OServer�A�n��԰���o�e���Ҧ��H
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
      memo1.Lines.add('�o�ͤF�԰��I');
      memo1.Lines.add('���b�԰������a�G');

      i := 0;
      while i < length(con_battling) do
      begin
        memo1.Lines.add(inttostr(con_battling[i]) + ' �M ' + inttostr(con_battling[i+1]));
        i := i + 2;
      end;
    end;
  end

  // 8) Client & Server: ���� �԰����� 'F[������]O[���u��]'
  else if copy(s, 1, 1) = 'F' then
  begin
    // (�o��ۤv�����a�s���B�s��X�MY)
    temp := TStringList.Create;
    s_p := PChar(s);
    ExtractStrings(['F', 'O'], [], s_p, temp);
    num := strtoint(temp[0]);     // �����誺�s��
    opp_num := strtoint(temp[1]); // ���u�誺�s��
    temp.free;

    // (�M�䵲���԰����H��m�b��)
    i := 0;
    while i < length(con_battling) do
    begin
      if con_battling[i] = num then
        break
      else
        i := i + 1;
    end;

    // ��Ӧ�m�R��(�@�����ⵧ���)
    if length(con_battling) > 2 then
    begin
      while i < length(con_battling)-2 do
      begin
        con_battling[i] := con_battling[i+2];
        con_battling[i+1] := con_battling[i+3];
        i := i + 2;
      end;
    end;

    // ���]�M�����
    setlength(con_battling, length(con_battling) - 2);
    
    // �p�G�OServer�A�n��԰�������T�o�e���Ҧ��H
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
      memo1.Lines.add('�Y�Ӿ԰������F�I');
      memo1.Lines.add('���b�԰������a�G');

      i := 0;
      while i < length(con_battling) do
      begin
        memo1.Lines.add(inttostr(con_battling[i]) + ' �M ' + inttostr(con_battling[i+1]));
        i := i + 2;
      end;
    end;
  end;
end;

end.