unit UnitBot;

interface

uses
  System.Types, Vcl.Graphics, Vcl.ExtCtrls, System.Math, System.Classes,
  UnitRes, Generics.Collections, Generics.Defaults;

type
  TBot = class
    constructor Create(Box: TPaintBox; ALife: Integer);
    destructor Destroy; override;
  private
    DefaultLife: Int32;
    function GetRect: TRect;
    function CheckDied: Boolean;
  public
    Left: Integer;
    Top: Integer;                                                               // ���������� �������
    Direct: UInt16;                                                             // ����������� ��������
    Speed: Byte;                                                                // ��������
    Width: Integer;                                                             // ������ (� ������) �������
    NotifyRadius: Byte;                                                         // ������ �������
    DistanceKing,                                                               // ��������� �������� �� ������� ������ ����������
    DistanceRes: UInt16;                                                        //
    Target: TType;                                                              // ����
    Life: Int32;                                                                // ���������� ������ (����� ������� � �����)
    procedure Move(Box: TPaintBox);
    procedure Paint(Canvas: TCanvas);
    function SetTarget(Res: TRes): Boolean;
    procedure Notify(BotNotify: TBot); overload;
    procedure Notify(BotList: TList<TBot>; Index: Integer); overload;
    property Rect: TRect read GetRect;
    property Died: Boolean read CheckDied;
  end;

implementation

{ TBot }

function TBot.CheckDied: Boolean;                                               // ��������� ��� �� ���
begin
  Result := Life <= 0;
end;

function TBot.SetTarget(Res: TRes): Boolean;                                    // ���������� ����� ���� ����
begin
  Result := False;
  if Target = Res.ResType then                                                  // ���� ����� ���������� ������
  begin
    if Res.ResType = tdKing then
    begin
      Inc(Res.ResCount);
      DistanceKing := 0;
      Target := tdRes;                                                          // ������ ���� ������
      //Res.Direct := Round((Res.Direct + (�irect + 180)) shr 1); // shr 1 ��� ������� ������� �� 2
                                                                                // �� ����� ���� ���������� ������� (� ���� �������)
      Res.Direct := Direct + 180;                                               // ������� ������������� �������� � ������� ������� ��������� �� �����������
    end
    else
    if Res.ResType = tdRes then
    begin
      if Res.ResCount > 0 then
      begin
        Dec(Res.ResCount);
        DistanceRes := 0;
        Target := tdKing;                                                       // ������ ���� ������
      end;
    end;
    Speed := Random(8)+3;                                                       // ������ �������� �� 3 �� 11
  end
  else
  begin
    if Res.ResType = tdKing then
      DistanceKing := 0
    else
    if Res.ResType = tdRes then
      DistanceRes := 0;
  end;
  Direct := Direct + 180;                                                       // ������ ����������� ���� �� 180 ��������
  Life := DefaultLife;                                                          // �������� �����
end;

constructor TBot.Create(Box: TPaintBox; ALife: Integer);
begin
  inherited Create;
  Left := Random(Box.ClientWidth);
  Top := Random(Box.ClientHeight);
  Width := 3;                                                                   // ����������� ������ ���� 3 �������, �������� ��� �������
  Speed := Random(8)+3;
  Direct := Random(360);                                                        // ����������� �����
  DefaultLife := ALife;
  Life := ALife;
  Target := tdRes;                                                              // ���� - ������ (���)
end;

destructor TBot.Destroy;
begin
  IncGlobalResource(20);                                                        // ������ ��� ����� 20 ������, ������ ��� �������
  inherited Destroy;
end;

function TBot.GetRect: TRect;                                                   // ���������� ������� ����
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Right := Left + Width;
  Result.Bottom := Top + Width;
end;

procedure TBot.Move(Box: TPaintBox);                                            // ���
begin
  if (Target = tdRes) or (Target = tdNone) then
    Dec(Life);                                                                  // ���� ��� ���� ������, �� �������, � �������� �� ������

  if Life <= 0 then                                                             // ���� ����� �� ���� ��� ����, ��������� �� �����
  begin
    Target := tdNone;                                                           // ���� ������ ���, �� ������
    Exit;
  end;

  if Life <= (DefaultLife shr 1) then                                           // ����� ����� �������� ������ ��������
    Speed := 15;                                                                // ������� ��������� � ������� ����

  Left := Left - Round(Speed * Cos(DegToRad(Direct + 90)));                     // ������������� ����� ���������� ����
  Top := Top + Round(Speed * Sin(DegToRad(Direct - 90)));                       //

  Inc(DistanceKing, 1);                                                         // ����������� �������� �� ���� ������� ����������
  Inc(DistanceRes, 1);                                                          //

  Direct := Direct - (Random(11)-5);                                            // ������� ������ ����������� (������ ����������� ����)

  if (Left <= 0)                                                                // ��������� ������������ � ��������� ������
    or (Top <= 0)
    or (Left + Width >= Box.ClientWidth)
    or (Top + Width >= Box.ClientHeight) then
  begin
    if Left <= 0 then
      Left := 0;
    if Top <= 0 then
      Top := 0;
    if Left + Width >= Box.ClientWidth then
      Left := Box.ClientWidth - Width;
    if Top + Width >= Box.ClientHeight then
      Top := Box.ClientHeight - Width;
    Direct := Direct + Random(180);                                             // ��������������� �� �����-������ ����
  end;
end;

procedure TBot.Notify(BotList: TList<TBot>; Index: Integer);                    // ��������� ���� ��� ������ � ������� ���������
var
  i: Integer;
begin
  i := Index;
  while i < BotList.Count do
  begin
    Notify(BotList[i]);                                                         // �������� �� ������������� �� ��� ������ � ������� ���� ���������?
    Inc(i);
  end;
end;

procedure TBot.Notify(BotNotify: TBot);
begin

  if BotNotify.Died or Died then
    Exit;                                                                       // ���� ��������� ��� ������ ������, �������

  if (Left - NotifyRadius < BotNotify.Left)                                     // ���� ��� � ��������� ����������
    and (Left + Width + NotifyRadius > BotNotify.Left)                          // ����� ������ �������� ��������, ����� ���������
    and (Top - NotifyRadius < BotNotify.Top)                                    // ����� ����������� ���-�� ��������, �� ������ ��������� ��������
    and (Top + Width + NotifyRadius > BotNotify.Top) then                       // �� �������� ����� ������������ ��������� > < >= <=
  begin

    if BotNotify.DistanceKing > DistanceKing + NotifyRadius then                // ���� � ��������� ��������� � ���� ������
    begin
      BotNotify.DistanceKing := DistanceKing + NotifyRadius;
      if BotNotify.Target = tdKing then
        BotNotify.Direct := Round(RadToDeg(ArcTan2(Top-BotNotify.Top, Left-BotNotify.Left)) +90); // (�� �������� � ��� �������)
    end
    else
    if BotNotify.DistanceKing + BotNotify.NotifyRadius < DistanceKing then      // ���� �� �������� ���������� �������� ������ ������������
    begin
      DistanceKing := BotNotify.DistanceKing + BotNotify.NotifyRadius;
      if Target = tdKing then
        Direct := Round(RadToDeg(ArcTan2(BotNotify.Top-Top, BotNotify.Left-Left)) +90);
    end;

    if BotNotify.DistanceRes > DistanceRes + NotifyRadius then                  // ���� � ��������� ��������� � ���� ������
    begin
      BotNotify.DistanceRes := DistanceRes + NotifyRadius;
      if BotNotify.Target = tdRes then
        BotNotify.Direct := Round(RadToDeg(ArcTan2(Top-BotNotify.Top, Left-BotNotify.Left)) +90);
    end
    else
    if BotNotify.DistanceRes + BotNotify.NotifyRadius < DistanceRes then        // ���� �� �������� ���������� �������� ������ ������������
    begin
      DistanceRes := BotNotify.DistanceRes + BotNotify.NotifyRadius;
      if Target = tdRes then
        Direct := Round(RadToDeg(ArcTan2(BotNotify.Top-Top, BotNotify.Left-Left)) +90);
    end;
  end;
end;

procedure TBot.Paint(Canvas: TCanvas);                                          // �������� ����
const
  Color: array[TType] of TColor = (clGreen, clRed, clSilver);                   // �� �������� ����� �����, �� ������ �������
begin
  with Canvas do
  begin
    Brush.Color := Color[Target];
    Pen.Color := Color[Target]; //clGray;
    Pen.Width := 1;
    Ellipse(Rect);
  end;
end;

end.
