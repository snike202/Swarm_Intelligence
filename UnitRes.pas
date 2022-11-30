unit UnitRes;

interface

uses
  System.Types, Vcl.Graphics, Vcl.ExtCtrls, System.Math, System.Classes,
  System.Threading, System.SyncObjs, Generics.Collections, Generics.Defaults;

type
  TType = (tdKing, tdRes, tdNone);
  TRes = class
    constructor Create(Box: TPaintBox);
    destructor Destroy; override;
  private
    function GetRect: TRect;
  public
    ResType: TType;                                                             // ��� ������� (�������� ��� ������)
    ResCount: UInt32;                                                           // ���������� ��������
    Left, Top: Integer;                                                         // ����������
    Direct: UInt16;                                                             // ����������� (0-360 ��������)
    BodyWidth: UInt16;                                                          // ���������� ������ �������
    PenWidth: UInt16;                                                           // ������ �� ������
    LifeCount: UInt32;                                                          // ������� �����
    procedure Move(Box: TPaintBox);
    procedure Paint(Canvas: TCanvas);
    procedure Touch(ResTouch: TRes); overload;
    procedure Touch(ResList: TList<TRes>; Index: Integer); overload;
    property Rect: TRect read GetRect;
  end;

  function GetCountResource(Res: UInt32): UInt32;
  procedure IncGlobalResource(Cnt: UInt32 = 1);

const
  CGlobalResource = 75000;

var
  GlobalResource: UInt32;                                                       // ���������� ������� ��������
  CS: TCriticalSection;                                                         // ��� ����������� ��������

implementation

function GetCountResource(Res: UInt32): UInt32;                                 // �������� ���������� ��������, ���� ��� ��������
begin
  CS.Enter;                                                                     // �� ����� ���� ���� ����� �������� �����
  try                                                                           // ����� ��������� ���-�� ������
    if Res <= GlobalResource then
    begin
      Dec(GlobalResource, Res);
      Result := Res;
    end
    else
    begin
      Result := GlobalResource;
      GlobalResource := 0;
    end;
  finally
    CS.Leave;
  end;
end;

procedure IncGlobalResource(Cnt: UInt32 = 1);                                   // ���������� ������� � ���������� ����������
begin
  CS.Enter;
  try
    Inc(GlobalResource, Cnt);
  finally
    CS.Leave;
  end;
end;

{ TRes }

constructor TRes.Create(Box: TPaintBox);                                        // ������ ������ �� ����� ������
begin                                                                           // �� ���������� ��� ����� ���� �������� ��� ���
  inherited Create;
  Left := Random(Box.ClientWidth);                                              // � ����� �����
  Top := Random(Box.ClientHeight);                                              //
  BodyWidth := Random(30) +5;                                                   // ������� ������ �������, ����� ����� ���������������� �� ����������
  LifeCount := 0;                                                               // ������� ���� ����������������� �������
  Direct := Random(360);
end;

destructor TRes.Destroy;
begin
  IncGlobalResource(ResCount);                                                  // ������ ���������� ������� ����
  inherited Destroy;
end;

function TRes.GetRect: TRect;                                                   // �������� ������� ���� �������
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Right := Left + BodyWidth;
  Result.Bottom := Top + BodyWidth;
end;

procedure TRes.Move(Box: TPaintBox);                                            // ���
begin
  if ResType = tdKing then
  begin
    Dec(ResCount);                                                              // ���� ��������, � ����� ��������� �� �����
    IncGlobalResource;
  end
  else
  begin
    if ResCount < 15000 then                                                    // ���� ������ �������� ��� �� 15000, �� ������������� ����������
    begin
      if GetCountResource(1) > 0 then
        Inc(ResCount);
    end;
  end;

  Inc(LifeCount);                                                               // ����������� ������� �����
  Left := Left - Round(Cos(DegToRad(Direct +90)));                              // ������������� ����� ���������� ������� (��������)
  Top := Top + Round(Sin(DegToRad(Direct -90)));                                // ����� ������� ����, �� ���������� �����

  Direct := Direct - (Random(21) -10);                                          // ������� ������ ����������� ��������

  if (Left <= 0) or (Top <= 0)                                                  // ��������� ������������ � ��������� ������
      or (Left + BodyWidth >= Box.ClientWidth)
      or (Top + BodyWidth >= Box.ClientHeight) then
  begin
    if Left <= 0 then
      Left := 0;
    if Top <= 0 then
      Top := 0;
    if Left + BodyWidth >= Box.ClientWidth then
      Left := Box.ClientWidth - BodyWidth;
    if Top + BodyWidth >= Box.ClientHeight then
      Top := Box.ClientHeight - BodyWidth;
    Direct := Direct +Random(180);                                              // ��������������� �� �����-������ ����
  end;
end;

procedure TRes.Paint(Canvas: TCanvas);                                          // ������ �������
const
  Color: array[TType] of TColor = (clRed, clGreen, clSilver);                   // �������� �������, ������ �������, ��������� �������
begin
  with Canvas do
  begin
    Brush.Color := Color[ResType];
    Pen.Color := Color[ResType];
    Pen.Width := PenWidth;
    BodyWidth := ResCount div 100;                                              // ������ ���� ������� �� ���������� ��������
    if BodyWidth > 30 then                                                      // ���� ���� �������� ������ 30 ��������
    begin                                                                       // �������� � ���� �� ��������, �� ������ �����
      Pen.Width := BodyWidth div 30;                                            // ������� ������� ��� ����� +30 ���� ����
      BodyWidth := 30;                                                          // ��� ������ ����� ��������, ��� ����� ����� ������� (������� 30)
      Pen.Color := clBlack;
    end;
    Ellipse(Rect);
  end;
end;

procedure TRes.Touch(ResTouch: TRes);                                           // �������� �� ������������
begin
  //(Sqrt(Sqr(Rect.Left-ResTouch.Rect.Left)+                                    // ��������������� � ��������� �����
  //                         Sqr(Rect.Top-ResTouch.Rect.Top))<=20);             //
  //PtInCircle()
  //if IntersectRect(Rect, ResTouch.Rect) then
  if (Left+BodyWidth > ResTouch.Left)
    and (Left < ResTouch.Left+ResTouch.BodyWidth)
    and (Top+BodyWidth > ResTouch.Top)
    and (Top < ResTouch.Top+ResTouch.BodyWidth) then
  begin
    Direct := Direct + 180;                                                     // ��� ��������������� ��������������� �� 180
    Left := Left - Round(4*Cos(DegToRad(Direct + 90)));                         // � ������ ��� � ��������������� �������
    Top := Top + Round(4*Sin(DegToRad(Direct - 90)));                           // ���� �������� ������� �� ������� ���� � �����
    ResTouch.Direct := ResTouch.Direct + 180;                                   // ��������� ������ ���� �������������
  end;
end;

procedure TRes.Touch(ResList: TList<TRes>; Index: Integer);                     // �������� �� ������������
var
  i: Integer;
begin
  i := Index;

  {TParallel.For(Index, Pred(ResList.Count),                                    // ������������ ���������� �������, �� ���������� ���
    procedure(i: integer; loopState: TParallel.TLoopState)
    begin
      //Touch(ResList[i]);                                                        // �������� �� ������������� �� ��� ������ � ������� ���� ���������?
      if (Left+BodyWidth > TRes(ResList[i]).Left) and (Left < TRes(ResList[i]).Left+TRes(ResList[i]).BodyWidth)
        and (Top+BodyWidth > TRes(ResList[i]).Top) and (Top < TRes(ResList[i]).Top+TRes(ResList[i]).BodyWidth) then
      begin
        System.TMonitor.Enter(self);
        try
          Direct := Direct + 180;
          Left := Left - Round(4*Cos(DegToRad(Direct + 90)));
          Top := Top + Round(4*Sin(DegToRad(Direct - 90)));
          TRes(ResList[i]).Direct := TRes(ResList[i]).Direct + 180;
        finally
          System.TMonitor.Exit(self);
        end;
      end;
    end
  );}

  while i < ResList.Count do
  begin
    Touch(ResList[i]);                                                          // �������� �� ������������� �� ��� ������ � ������� ���� ���������?
    Inc(i);
  end;
end;

end.
