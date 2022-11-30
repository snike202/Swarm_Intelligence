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
    Top: Integer;                                                               // координаты букашки
    Direct: UInt16;                                                             // направление движения
    Speed: Byte;                                                                // скорость
    Width: Integer;                                                             // ширина (и высота) объекта
    NotifyRadius: Byte;                                                         // радиус Вещания
    DistanceKing,                                                               // Примерные счетчики до каждого пунтка назначения
    DistanceRes: UInt16;                                                        //
    Target: TType;                                                              // Цель
    Life: Int32;                                                                // Количество жизней (может убегать в минус)
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

function TBot.CheckDied: Boolean;                                               // проверяем жив ли бот
begin
  Result := Life <= 0;
end;

function TBot.SetTarget(Res: TRes): Boolean;                                    // выставляем новую цель боту
begin
  Result := False;
  if Target = Res.ResType then                                                  // если пункт назначения найден
  begin
    if Res.ResType = tdKing then
    begin
      Inc(Res.ResCount);
      DistanceKing := 0;
      Target := tdRes;                                                          // меняем цель поиска
      //Res.Direct := Round((Res.Direct + (Вirect + 180)) shr 1); // shr 1 это быстрое деление на 2
                                                                                // мы знаем куда направлена букашка (в нашу сторону)
      Res.Direct := Direct + 180;                                               // поэтому разворачиваем королеву в сторону букашки используя ее направлкние
    end
    else
    if Res.ResType = tdRes then
    begin
      if Res.ResCount > 0 then
      begin
        Dec(Res.ResCount);
        DistanceRes := 0;
        Target := tdKing;                                                       // меняем цель поиска
      end;
    end;
    Speed := Random(8)+3;                                                       // задаем скорость от 3 до 11
  end
  else
  begin
    if Res.ResType = tdKing then
      DistanceKing := 0
    else
    if Res.ResType = tdRes then
      DistanceRes := 0;
  end;
  Direct := Direct + 180;                                                       // меняем направление бота на 180 градусов
  Life := DefaultLife;                                                          // Обнуляем жизнь
end;

constructor TBot.Create(Box: TPaintBox; ALife: Integer);
begin
  inherited Create;
  Left := Random(Box.ClientWidth);
  Top := Random(Box.ClientHeight);
  Width := 3;                                                                   // стандартная ширина бота 3 пикселя, выглядит как крестик
  Speed := Random(8)+3;
  Direct := Random(360);                                                        // направление любое
  DefaultLife := ALife;
  Life := ALife;
  Target := tdRes;                                                              // цель - ресурс (еда)
end;

destructor TBot.Destroy;
begin
  IncGlobalResource(20);                                                        // каждый бот стоит 20 едениц, вернем эту энергию
  inherited Destroy;
end;

function TBot.GetRect: TRect;                                                   // показываем размеры тела
begin
  Result.Left := Left;
  Result.Top := Top;
  Result.Right := Left + Width;
  Result.Bottom := Top + Width;
end;

procedure TBot.Move(Box: TPaintBox);                                            // шаг
begin
  if (Target = tdRes) or (Target = tdNone) then
    Dec(Life);                                                                  // если бот ищет ресурс, он стареет, с ресурсом он вечный

  if Life <= 0 then                                                             // если жизнь на нуле или ниже, двигаться не можем
  begin
    Target := tdNone;                                                           // цели больше нет, мы мертвы
    Exit;
  end;

  if Life <= (DefaultLife shr 1) then                                           // когда жизни осталось меньше половины
    Speed := 15;                                                                // быстрее двигаемся в поисках цели

  Left := Left - Round(Speed * Cos(DegToRad(Direct + 90)));                     // пересчитываем новые координаты бота
  Top := Top + Round(Speed * Sin(DegToRad(Direct - 90)));                       //

  Inc(DistanceKing, 1);                                                         // увеличиваем счётчики до всех пунктов назначения
  Inc(DistanceRes, 1);                                                          //

  Direct := Direct - (Random(11)-5);                                            // немного меняем направление (эффект шатающегося бота)

  if (Left <= 0)                                                                // проверяем столкновение с границами холста
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
    Direct := Direct + Random(180);                                             // разворачиваемся на какой-нибудь угол
  end;
end;

procedure TBot.Notify(BotList: TList<TBot>; Index: Integer);                    // оповестим всех кто входит в границы видимости
var
  i: Integer;
begin
  i := Index;
  while i < BotList.Count do
  begin
    Notify(BotList[i]);                                                         // проверим не соприкоснулся ли наш ресурс с другими себе подобными?
    Inc(i);
  end;
end;

procedure TBot.Notify(BotNotify: TBot);
begin

  if BotNotify.Died or Died then
    Exit;                                                                       // если слушатель или оратор мертвы, выходим

  if (Left - NotifyRadius < BotNotify.Left)                                     // если бот в диапазоне слышимости
    and (Left + Width + NotifyRadius > BotNotify.Left)                          // очень плохой механизм проверки, очень медленный
    and (Top - NotifyRadius < BotNotify.Top)                                    // нужно попробовать как-то ускорить, но похоже условному переходу
    and (Top + Width + NotifyRadius > BotNotify.Top) then                       // не нравится когда используются операторы > < >= <=
  begin

    if BotNotify.DistanceKing > DistanceKing + NotifyRadius then                // если у кричащего дистанция к цели меньше
    begin
      BotNotify.DistanceKing := DistanceKing + NotifyRadius;
      if BotNotify.Target = tdKing then
        BotNotify.Direct := Round(RadToDeg(ArcTan2(Top-BotNotify.Top, Left-BotNotify.Left)) +90); // (то повернем в его сторону)
    end
    else
    if BotNotify.DistanceKing + BotNotify.NotifyRadius < DistanceKing then      // если же наоборот услышавший отвечает новыми координатами
    begin
      DistanceKing := BotNotify.DistanceKing + BotNotify.NotifyRadius;
      if Target = tdKing then
        Direct := Round(RadToDeg(ArcTan2(BotNotify.Top-Top, BotNotify.Left-Left)) +90);
    end;

    if BotNotify.DistanceRes > DistanceRes + NotifyRadius then                  // если у кричащего дистанция к цели меньше
    begin
      BotNotify.DistanceRes := DistanceRes + NotifyRadius;
      if BotNotify.Target = tdRes then
        BotNotify.Direct := Round(RadToDeg(ArcTan2(Top-BotNotify.Top, Left-BotNotify.Left)) +90);
    end
    else
    if BotNotify.DistanceRes + BotNotify.NotifyRadius < DistanceRes then        // если же наоборот услышавший отвечает новыми координатами
    begin
      DistanceRes := BotNotify.DistanceRes + BotNotify.NotifyRadius;
      if Target = tdRes then
        Direct := Round(RadToDeg(ArcTan2(BotNotify.Top-Top, BotNotify.Left-Left)) +90);
    end;
  end;
end;

procedure TBot.Paint(Canvas: TCanvas);                                          // нарисуем бота
const
  Color: array[TType] of TColor = (clGreen, clRed, clSilver);                   // от королевы бежит серый, от мишени зеленый
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
