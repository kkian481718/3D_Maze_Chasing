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
    Button6: TButton;
    Button7: TButton;
    Memo1: TMemo;
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
    procedure conUISetVisible(bool: Boolean);
    procedure Button4Click(Sender: TObject);
    procedure UDPSUDPRead(Sender: TObject; AData: TStream; ABinding: TIdSocketHandle);
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
  GAME_NAME = 'D&D';

var
  Form1: TForm1;
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

  Dmap: array[0..4, 0..4] of Byte; //3D�������ݭn�B�z�쪺����a��
  Back_Bmap: TBitmap; //�u��3D�ƭn�Ψ쪺�I�}��
  twoD_Bmap: TBitmap; //2D�a�ϥΨ쪺�I�}��

  // �@���ܼ�
  LX, LY, Dir: Byte;      // �ڪ���m
  Rect_B, Rect_M: TRect;

  // �s�u�Ϊ��ܼ�
  con_mode: Byte;             // �s���Ҧ�
  con_loc: array of ShortInt; // �Ҧ����a����m
  con_IP: array of string;    // �Ҧ����a��IP
  con_num: ShortInt;          // �ڪ��s�� (Server = 0)

  // �쥻��IP�Ϊ��ܼ�
  Host, IP, Err: string;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
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

  //��l��UDP����
  UDPC.Active := false;
  UDPS.Active := false;
  
  //��l�Ƴs�u�ܼ�
  con_mode := 0; //0:��H�B1:Client�B2:Server
  setlength(con_loc, 2);
  con_loc[0] := 1;
  con_loc[1] := 1;
  con_num := 0;

  //��|�i�P�\�_��
  Card1.Showdeck := true;
  Card2.Showdeck := true;
  Card3.Showdeck := true;
  Card4.Showdeck := true;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  // > �p�G�i�H���ʡA�N���ܮy�� <
  if Dir > 15 then
  begin
    // �T�{ 1.���a�b�g�c�d�� 2.�S���I�����
    Dir := Dir and 15; // ???
    case Dir of
      0: if (LX + 1 <= Hmax) and (Lmap[LX+1, LY] and 1 = 0) then
        LX := LX + 1; // �F

      1: if (LY - 1 >= 0   ) and (Lmap[LX, LY-1] and 1 = 0) then
        LY := LY - 1; // �n

      2: if (LX - 1 >= 0   ) and (Lmap[LX-1, LY] and 1 = 0) then
        LX := LX - 1; // ��

      3: if (LY + 1 <= Vmax) and (Lmap[LX, LY+1] and 1 = 0) then
        LY := LY + 1; // �_
    end;
  end;

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
  Bmap.Canvas.Brush.Color := $2a2a2a;
  Bmap.Canvas.Rectangle(0, 0, Bmap.Width, Bmap.Height);

  // 1) 4�滷�B���������?? (��ΡB�@5��)
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
  Bmap.Canvas.Brush.Color := $262626;
  if (Dmap[1, 2] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(7*LW, 7*LW), Point(7*LW, 23*LW), Point(10*LW, 20*LW), Point(10*LW, 10*LW)]);
  if (Dmap[3, 2] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(23*LW, 7*LW), Point(23*LW, 23*LW), Point(20*LW, 20*LW), Point(20*LW, 10*LW)]);

  // 5) ����
  for X := 1 to 3 do
    if (Dmap[X, 2] and 1) = 1 then
      Bmap.Canvas.Rectangle(((X-1)*16 - 9)*LW, 7*LW, ((X-1)*16 + 7)*LW, 23*LW);

  // 6)
  Bmap.Canvas.Brush.Color := $242424;
  if (Dmap[1, 3] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(3*LW, 3*LW), Point(3*LW, 27*LW), Point(7*LW, 23*LW), Point(7*LW, 7*LW)]);
  if (Dmap[3, 3] and 1) = 1 then
    Bmap.Canvas.Polygon([Point(27*LW, 3*LW), Point(27*LW, 27*LW), Point(23*LW, 23*LW), Point(23*LW, 7*LW)]);

  // 7) ����
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
  while i <= Length(con_loc) do
  begin
    if i = con_num then
    begin
      // ���εe�ۤv����m
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

// �e�i
procedure TForm1.Button1Click(Sender: TObject);
begin
  Dir := Dir or 16;

  con_loc[con_num*2] := LX;
  con_loc[con_num*2 + 1] := LY;

  UDPC.send('L' + inttostr(con_num) + 'X' + inttostr(LX) + 'Y' + inttostr(LY));
end;

// ����
procedure TForm1.Button2Click(Sender: TObject);
begin
  Dir := (Dir + 1) and 3;
end;

// �k��
procedure TForm1.Button3Click(Sender: TObject);
begin
  Dir := (Dir + 3) and 3;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //����3D�B2D�Ϊ��I�}��
  Back_Bmap.free;
  twoD_Bmap.free;
end;

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

    if ComboBox1.ItemIndex = 1 then
    begin 
      Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Client�U���s�u�^';
      con_mode := 1;

      Edit1.Enabled := true;
      Edit2.Enabled := true;
      Button4.Enabled := true;
      Button5.Enabled := false;
      Button4.Caption := '�s�u�I';
    end else
    if ComboBox1.ItemIndex = 2 then
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

  case con_mode of
    1: //1. Client ���ճs�u
    begin
      Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Client�U���b�s�u�ܥD��...�^';

      UDPC.Host := Edit1.Text;
      UDPC.Port := strtoint(Edit2.Text);

      UDPS.DefaultPort := 8787;
      UDPS.Active := true;

      Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Client�U���b�ǰe�A��IP�G' + IP + '...�^';
      UDPC.Send('C' + IP); // �e�XC[IP]���ճs���A�ño��@�ӧǸ�
    end;

    2: //1. ���իإ� Server
    begin
      Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Server�U���b���իإ߷s���A��...�^';

      UDPS.DefaultPort := strtoint(Edit2.Text);
      UDPS.Active := true;
      
      Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Server�U�N���^';
      Button5.Enabled := true;
      
      // ���ձo��ۤv��IP
      if GetIPFromHost(Host, IP, Err) then
      begin
        Edit1.Text := IP;
      end
      else
        MessageDlg(Err, mtError, [mbOk], 0);
      
      // 
    end;
  end;

end;

// UDPS������T
procedure TForm1.UDPSUDPRead(Sender: TObject; AData: TStream; ABinding: TIdSocketHandle);
var
  s: string;
  len, i, con_count: integer;

  // �o�쪱�a�s��m��
  X, Y, num: ShortInt;

  // ��r����Υ�
  temp: TStringList;
  s_p: PChar;
begin
  // > �U����� <
  len := AData.Size;
  setlength(s, len);
  Adata.Read(s[1], len);
  memo1.Lines.add(s); // DEBUG

  // > �ѪR��� <
  // 1) Client & Server: �����a�ϧ�s L[���a�s��]X[�y��]Y[�y��]
  if copy(s, 1, 1) = 'L' then
  begin
    // (�o�쪱�a�s���B�s��X�MY)
    temp := TStringList.Create;
    s_p := PChar(s);
    ExtractStrings(['L', 'X', 'Y'], [], s_p, temp);
    num := strtoint(temp[0]); //�e�X���ʰT�������a�s��
    X := strtoint(temp[1]);   //�s��X��
    Y := strtoint(temp[2]);   //�s��Y��
    temp.free;

    // DEBUG
    memo1.Lines.add('L> num' + inttostr(num));
    memo1.Lines.add('L> X' + inttostr(X)); 
    memo1.Lines.add('L> Y' + inttostr(Y));  

    // (��s�ۤv��con_loc[][])
    con_loc[num*2] := X;
    con_loc[num*2 + 1] := Y;
    
    // �p�G�O���A���A�n��U��o�T��
    if con_mode = 2 then
    begin
      for i:=1 to Length(con_IP) do
      begin
        if i = num then continue;
        
        UDPC.Host := con_IP[i];
        UDPC.Port := 8787; 
        UDPC.Send(s);
      end; 
    end;
  end
  
  // 2) Client & Server: ���� �X�P���G
  else if copy(s, 1, 1) = 'P' then
  begin
    //
  end
  
  // 3) Client: ���� ��赹���Ǹ� 'N[�Ǹ�]'
  else if copy(s, 1, 1) = 'N' then
  begin
    con_num := strtoint(copy(s, 2, 10000));
    Form1.Caption := GAME_NAME + '�G�h�H�Ҧ��]Client�U�w�s�u�I [' + inttostr(con_num) + ']�^';
  end

  // 4) Server: ���� �s�s�u 'C[IP]'
  else if copy(s, 1, 1) = 'C' then
  begin
    //(�쥻���A������ i �H)
    con_count := Length(con_IP);
    con_count := con_count + 1;

    //(�����s���aIP)
    setlength(con_IP, con_count); // ���s�]�wcon_IP�}�C����
    con_IP[con_count-1] := copy(s, 2, 10000);

    //(�]�w�s���a��m)
    setlength(con_loc, con_count*2); // ���s�]�wcon_loc�}�C����
    con_loc[con_count-1] := 1;
    con_loc[con_count-2] := 1;
    
    //(�e�X���a�s����Client)
    UDPC.Host := copy(s, 2, 10000);
    UDPC.Port := 8787;
    UDPC.send('N' + inttostr(con_count));

    //DEBUG
    memo1.Lines.add('C> IP ' + UDPC.Host);
    memo1.Lines.add('C> Port ' + inttostr(UDPC.Port));
    memo1.Lines.add('C> con_count ' + inttostr(con_count));
  end;
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

end.