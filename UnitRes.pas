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
    ResType: TType;                                                             // Тип ресурса (Королева или Мишень)
    ResCount: UInt32;                                                           // Количество ресурсов
    Left, Top: Integer;                                                         // Координаты
    Direct: UInt16;                                                             // Направление (0-360 градусов)
    BodyWidth: UInt16;                                                          // Визуальная ширина объекта
    PenWidth: UInt16;                                                           // Тощина ее стенки
    LifeCount: UInt32;                                                          // Счетчик жизни
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
  GlobalResource: UInt32;                                                       // Глобальный счётчик ресурсов
  CS: TCriticalSection;                                                         // для глобального счётчика

implementation

function GetCountResource(Res: UInt32): UInt32;                                 // Получаем количество ресурсов, если оно доступно
begin
  CS.Enter;                                                                     // На самом деле этот метод работает плохо
  try                                                                           // нужно придумать что-то другое
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

procedure IncGlobalResource(Cnt: UInt32 = 1);                                   // возвращаем ресурсы в глобальную переменную
begin
  CS.Enter;
  try
    Inc(GlobalResource, Cnt);
  finally
    CS.Leave;
  end;
end;

{ TRes }

constructor TRes.Create(Box: TPaintBox);                                        // Создаём ресурс на нашем холсте
begin                                                                           // по содержанию это может быть королева или еда
  inherited Create;
  Left := Random(Box.ClientWidth);                                              // в любом месте
  Top := Random(Box.ClientHeight);                                              //
  BodyWidth := Random(30) +5;                                                   // сначала такого размера, потом будут перерисовываться по содержанию
  LifeCount := 0;                                                               // счётчик всей жизнедеятельности ресурса
  Direct := Random(360);
end;

destructor TRes.Destroy;
begin
  IncGlobalResource(ResCount);                                                  // вернем остаточную энергию миру
  inherited Destroy;
end;

function TRes.GetRect: TRect;                                                   // получаем размеры тела ресурса
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Right := Left + BodyWidth;
  Result.Bottom := Top + BodyWidth;
end;

procedure TRes.Move(Box: TPaintBox);                                            // шаг
begin
  if ResType = tdKing then
  begin
    Dec(ResCount);                                                              // если королева, с шагом уменьшаем ее жизнь
    IncGlobalResource;
  end
  else
  begin
    if ResCount < 15000 then                                                    // если ресурс набрался сил до 15000, то останавливаем накопление
    begin
      if GetCountResource(1) > 0 then
        Inc(ResCount);
    end;
  end;

  Inc(LifeCount);                                                               // увеличиваем счётчик жизни
  Left := Left - Round(Cos(DegToRad(Direct +90)));                              // пересчитываем новые координаты ресурса (королевы)
  Top := Top + Round(Sin(DegToRad(Direct -90)));                                // самое сложное было, не перепутать знаки

  Direct := Direct - (Random(21) -10);                                          // немного меняем направление движения

  if (Left <= 0) or (Top <= 0)                                                  // проверяем столкновение с границами холста
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
    Direct := Direct +Random(180);                                              // разворачиваемся на какой-нибудь угол
  end;
end;

procedure TRes.Paint(Canvas: TCanvas);                                          // рисуем объеект
const
  Color: array[TType] of TColor = (clRed, clGreen, clSilver);                   // королева красная, мишень зеленая, остальное неважно
begin
  with Canvas do
  begin
    Brush.Color := Color[ResType];
    Pen.Color := Color[ResType];
    Pen.Width := PenWidth;
    BodyWidth := ResCount div 100;                                              // размер тела зависит от внутренних ресурсов
    if BodyWidth > 30 then                                                      // если тело занимает больше 30 пикселей
    begin                                                                       // остаемся в этих же пределах, но рисуем линию
      Pen.Width := BodyWidth div 30;                                            // толщина полоски уже равна +30 пикс тела
      BodyWidth := 30;                                                          // чем больше будет ресурсов, тем толще будет полоска (кратная 30)
      Pen.Color := clBlack;
    end;
    Ellipse(Rect);
  end;
end;

procedure TRes.Touch(ResTouch: TRes);                                           // проверка на столкновение
begin
  //(Sqrt(Sqr(Rect.Left-ResTouch.Rect.Left)+                                    // соприкосновение с границами круга
  //                         Sqr(Rect.Top-ResTouch.Rect.Top))<=20);             //
  //PtInCircle()
  //if IntersectRect(Rect, ResTouch.Rect) then
  if (Left+BodyWidth > ResTouch.Left)
    and (Left < ResTouch.Left+ResTouch.BodyWidth)
    and (Top+BodyWidth > ResTouch.Top)
    and (Top < ResTouch.Top+ResTouch.BodyWidth) then
  begin
    Direct := Direct + 180;                                                     // при соприкосновении разворачиваемся на 180
    Left := Left - Round(4*Cos(DegToRad(Direct + 90)));                         // и делаем шаг в противоположную сторону
    Top := Top + Round(4*Sin(DegToRad(Direct - 90)));                           // чтоб случайно объекты не залипли друг в друге
    ResTouch.Direct := ResTouch.Direct + 180;                                   // встречный ресурс тоже разворачиваем
  end;
end;

procedure TRes.Touch(ResList: TList<TRes>; Index: Integer);                     // проверка на столкновение
var
  i: Integer;
begin
  i := Index;

  {TParallel.For(Index, Pred(ResList.Count),                                    // параллельное вычисление хромает, не используем его
    procedure(i: integer; loopState: TParallel.TLoopState)
    begin
      //Touch(ResList[i]);                                                        // проверим не соприкоснулся ли наш ресурс с другими себе подобными?
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
    Touch(ResList[i]);                                                          // проверим не соприкоснулся ли наш ресурс с другими себе подобными?
    Inc(i);
  end;
end;

end.
