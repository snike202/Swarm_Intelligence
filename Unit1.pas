unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Samples.Spin, System.Types, System.Math, System.Threading, System.SyncObjs, System.Diagnostics,
  //
  Generics.Collections, Generics.Defaults,
  UnitBot, UnitRes;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    PaintBox1: TPaintBox;
    TimerMove: TTimer;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    se_radius: TSpinEdit;
    Label3: TLabel;
    se_life: TSpinEdit;
    GroupBox2: TGroupBox;
    Label4: TLabel;
    se_res_count: TSpinEdit;
    Label5: TLabel;
    Label6: TLabel;
    chb_paint: TCheckBox;
    Label7: TLabel;
    Label8: TLabel;
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure TimerMoveTimer(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure chb_paintClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure se_radiusChange(Sender: TObject);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure se_lifeChange(Sender: TObject);
  private
    procedure ResStep;
    procedure BotStep;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

  BotList: TList<TBot>;                                                         // Список Роя
  ResList: TList<TRes>;                                                         // Список всех ресурсов

  CountKing: UInt16;
  CountBot: UInt16;
  cnt_bot: UInt16;

  SW: TStopwatch;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
//var
  //R1, R2: TRect;
  //i: Integer;
  //p: Extended;
begin
  {R1.Left := Random(1024);
  R1.Top := Random(1024);
  R1.Width := 200;
  R1.Height := 200;

  R2.Left := Random(1024);
  R2.Top := Random(1024);
  R2.Width := 200;
  R2.Height := 200;

  SW:=TStopwatch.StartNew;
  SW.Start;

  for i := 0 to 99999999 do
    //if IntersectRect(R1, R2) then
    //if (R1.Left+200 > R2.Left) and (R1.Left < R2.Left + 200)
    //  and (R1.Top+200 > R2.Top) and (R1.Top < R2.Top+200) then
    if (R1.Left > R2.Left) and (R1.Left < R2.Left)
      and (R1.Top > R2.Top) and (R1.Top < R2.Top) then
    //if max(abs(R1.Left-R2.Left),abs(R1.Top-R2.Top))<200 then
    begin
      Inc(p);
    end;

  SW.Stop;
  ShowMessage(SW.Elapsed.TotalMilliseconds.ToString); }

  {SW:=TStopwatch.StartNew;
  SW.Start;

  TParallel.For(0, 999999999, procedure(i: integer)
    begin
       //System.TMonitor.Enter(self);
       try
         p := i /4;
       finally
         //System.TMonitor.Exit(self);
       end;
    end
   );

  SW.Stop;
  ShowMessage(SW.Elapsed.TotalMilliseconds.ToString);}

end;

procedure TForm1.Button2Click(Sender: TObject);
var
  i: Integer;
begin
  if BotList.Count > 0 then
  begin
    i := 0;
    while i < BotList.Count do
    begin
      //TBot(BotList[i]).Destroy;
      BotList[i].Destroy;
      Inc(i);
    end;
    BotList.Clear;
  end;

  if ResList.Count > 0 then
  begin
    i := 0;
    while i < ResList.Count do
    begin
      //TRes(ResList[i]).Destroy;
      ResList[i].Destroy;
      Inc(i);
    end;
    ResList.Clear;
  end;

  Label7.Tag := 0;
end;

procedure TForm1.chb_paintClick(Sender: TObject);
begin
  if chb_paint.Checked then
    TimerMove.Interval := 1
  else
    TimerMove.Interval := 16;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //DoubleBuffered := True;
  Randomize;

  PaintBox1.ControlStyle := PaintBox1.ControlStyle + [csOpaque];

  CS := TCriticalSection.Create;

  GlobalResource := CGlobalResource;

  BotList := TList<TBot>.Create;
  ResList := TList<TRes>.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var
  i: Integer;
begin
  i := 0;
  while i < BotList.Count do
  begin
    BotList[i].Destroy;
    Inc(i);
  end;

  i := 0;
  while i < ResList.Count do
  begin
    ResList[i].Destroy;
    Inc(i);
  end;

  BotList.Free;
  ResList.Free;

  CS.Free;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  //cnt_bot := PaintBox1.ClientWidth div se_radius.Value;                         // посчитаем сколько ботов хватит для этой карты
  //cnt_bot := cnt_bot * (PaintBox1.ClientHeight div se_radius.Value);
  //cnt_bot := cnt_bot * 20;
  cnt_bot := 3000;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  TimerMove.Enabled := True;
end;

procedure BotsPaint(bm: TBitMap);
begin
  {TParallel.For(0, Pred(BotList.Count),
    procedure (i: Integer; loopState: TParallel.TLoopState)
    begin
      if i > BotList.Count then
        loopState.Break;
      BotList[i].Paint(bm.Canvas);                                              // прорисуем бота на холсте
    end
  ); }
  var i := 0;
  while i < BotList.Count do
  begin
    BotList[i].Paint(bm.Canvas);                                                // прорисуем бота на холсте
    Inc(i);
  end;
end;

procedure ResPaint(bm: TBitMap);
begin
  var i := 0;
  while i < ResList.Count do
  begin
    with ResList[i] do
    begin
      Paint(bm.Canvas);                                                         // прорисуем бота на холсте
      if ResType = tdKing then                                                  // если это королева, то нарисуем направление движения
      begin
        bm.Canvas.Pen.Width := 1;
        bm.Canvas.Pen.Color := clGray;
        var x := Left + BodyWidth shr 1; // div 2                               // вычисляем середину королевы
        var y := Top + BodyWidth shr 1; // div 2
        bm.Canvas.MoveTo(x, y);
        x := x - Round((BodyWidth shr 1) * Cos(DegToRad(Direct + 90)));         // вычисляем направление движения
        y := y + Round((BodyWidth shr 1) * Sin(DegToRad(Direct - 90)));
        bm.Canvas.LineTo(x, y);
      end;
    end;
    Inc(i);
  end;
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
const
  RType: array[TType] of String = ('Королева', 'Ресурс', '');
begin
  var i := 0;
  while i < ResList.Count do
  begin
    with ResList[i] do
    begin
      if (Left < X) and (Left + BodyWidth > X)
          and (Top < Y) and (Top + BodyWidth > Y) then
      begin
        ShowMessage(
          RType[ResType] + #13
          + 'Количество ресурсов: ' + ResCount.ToString + #13
          + 'Длительность жизни: '+ LifeCount.ToString
          + '/' + Label7.Tag.ToString);
        Break;
      end;
    end;
    Inc(i);
  end;
end;

procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  var bm := TBitMap.Create;
  try
    bm.PixelFormat := pf8bit; //pf24bit;
    bm.Height := PaintBox1.Height;
    bm.Width  := PaintBox1.Width;

    bm.Canvas.Brush.Color := clBtnFace;
    bm.Canvas.Pen.Color := clBtnFace;
    bm.Canvas.Pen.Width := 1;
    bm.Canvas.FillRect(Rect(0, 0, bm.Width, bm.Height));

    BotsPaint(bm);
    ResPaint(bm);

    PaintBox1.Canvas.Draw(0, 0, bm);                                            // выводим холст на экран, поискать более быструю замену
  finally
    bm.Free;
  end;
end;

procedure TForm1.ResStep;
begin
  var i := 0;
  CountKing := 0;                                                               // будем считать королев, обнулимся
  //TParallel.For(0, Pred(ResList.Count),
  while i < ResList.Count do
  //procedure (i: Integer; loopState: TParallel.TLoopState)
  begin
    //if i > ResList.Count then
    //  loopState.Break;

    var Res := ResList[i];
    if Res.BodyWidth <= 3 then                                                  // если ресурс был съеден, уничтожаем его
    begin
      Res.Destroy;
      //TThread.Queue(TThread.CurrentThread, procedure
      //begin
      ResList.Delete(i);
      //end);
      Continue;
      //loopState.Break;
    end;
  //end);

  {TParallel.For(0, Pred(ResList.Count),
  procedure (i: Integer)
  begin }
    //var Res := ResList[i];
    //TThread.Queue(TThread.CurrentThread, procedure
    //begin
    Res.Move(PaintBox1);                                                        // делаем шаг ресурсом (и королевой)
    //end);

    if Res.ResType = tdKing then                                                // если это не ресурс, а королева
    begin
      Inc(CountKing);                                                           // сразу считаем сколько у нас королев
      //TInterlocked.Increment(CountKing);
      if Res.ResCount > 1500 then                                               // если ресурсов у королевы достаточно
        if cnt_bot > CountBot {BotList.Count} then                              // а ботов меньше чем желательно для этой карты
        begin
          var Bot := TBot.Create(PaintBox1, se_life.Value);                     // создаем нового бота
          Bot.NotifyRadius := se_radius.Value;
          Bot.Left := Res.Left + (Res.BodyWidth shr 1);                         // внутри нашей королевы
          Bot.Top := Res.Top + (Res.BodyWidth shr 1);
          Bot.Direct := Res.Direct;                                             // с направлением движения тоже как у королевы
          Bot.Target := tdRes;                                                  // сразу сообщаем боту, чтоб искал он Ресурс
          Bot.DistanceKing := 0;                                                // текущий шаг (координата) до королевы
          Bot.DistanceRes := 2048;                                              // дистанция до ресурса не известна, ставим специально завшенную
          Bot.Speed := 10;                                                      // и повышенную скорость движения
          // сразу вычисляем первый шаг бота, чтобы верно определить направление движения
          Bot.Left := Bot.Left - Round(Res.BodyWidth shr 1 * Cos(DegToRad(Bot.Direct +90)));
          Bot.Top := Bot.Top + Round(Res.BodyWidth shr 1 * Sin(DegToRad(Bot.Direct -90)));
          //TThread.Queue(TThread.CurrentThread, procedure
          //begin
          BotList.Add(Bot);                                                     // добавляем бота в коллекцию
          Dec(Res.ResCount, 20);                                                // отнимаем у королевы стоимость одного бота
          //end);
        end;
    end;
    //Res.Touch(ResList, Succ(i));
    //TThread.Queue(TThread.CurrentThread, procedure
    //begin
    Res.Touch(ResList, Succ(i));                                                // проверим на соприкосновение
    //end);
    Inc(i);
  end; // while i < ResList.Count
end;

procedure TForm1.se_lifeChange(Sender: TObject);
begin
  if se_life.Value > 0 then
  try
    var i := 0;
    while i < BotList.Count do
    begin
      if not BotList[i].Died then
        BotList[i].Life := se_life.Value;
      Inc(i);
    end;
  except
  end;
end;

procedure TForm1.se_radiusChange(Sender: TObject);
begin
  if se_radius.Value > 0 then
  try
    FormResize(Sender);
    var i := 0;
    while i < BotList.Count do
    begin
      if not BotList[i].Died then
        BotList[i].NotifyRadius := se_radius.Value;
      Inc(i);
    end;
  except
  end;
end;

procedure TForm1.BotStep;
begin
  var i := 0;
  CountBot := 0;
  while i < BotList.Count do
  //TParallel.For(0, Pred(BotList.Count),
  //procedure (i: Integer; loopState: TParallel.TLoopState)
  begin
    //if i > BotList.Count then
    //  loopState.Break;

    var Bot := BotList[i];

    //TThread.Queue(TThread.CurrentThread, procedure
    //begin
    Bot.Move(PaintBox1);                                                        // делаем шаг ботом (если жив)
    //end);

    if Bot.Died then                                                            // если бот умер, удаляем запись о нем
    begin
      if Bot.Life < -500 then
      begin
        if Random(5000) = 0 then                                                // при смерти бот может породить вместо себя королеву, шанс 1 к 5000
        begin
          var Res2 := TRes.Create(PaintBox1);
          Res2.Left := Bot.Left;
          Res2.Top := Bot.Top;
          Res2.Direct := Bot.Direct;
          Res2.ResType := tdKing;
          Res2.ResCount := GetCountResource(1500);                              // но это самая слабая королева, не умеет рожать
          //TThread.Queue(TThread.CurrentThread, procedure
          //begin
          ResList.Add(Res2);
          //end);
        end;
        Bot.Destroy;
        //BotList.Delete(i);
        //TThread.Queue(TThread.CurrentThread, procedure
        //begin
        BotList.Delete(i);
        //end);
      end
      else
        Inc(i);
      Continue;
    end
    else
      Inc(CountBot);

    var j := 0;
    while j < ResList.Count do
    begin
      var Res := ResList[j];
      //if IntersectRect(Bot.Rect, Res.Rect) then                               // проверяем не столкнулись ли мы с объектом
      if (Bot.Left+Bot.Width > Res.Left) and (Bot.Left < Res.Left+Res.BodyWidth)
          and (Bot.Top+Bot.Width > Res.Top) and (Bot.Top < Res.Top+Res.BodyWidth) then
        Bot.SetTarget(Res);
      Inc(j);
    end;
    //TThread.Queue(TThread.CurrentThread, procedure
    //begin
    Bot.Notify(BotList, Succ(i));                                               // кричим о состоянии своих счетчиков всем кто нас слышит
    //end);
    Inc(i);
  end;
end;

procedure TForm1.TimerMoveTimer(Sender: TObject);
begin
  TimerMove.Enabled := False;

  ResStep;
  BotStep;

  if CountKing <= 0  then
  begin                                                                         // если вдруг вообще все королевы вымерли, создаем новую
    var Res := TRes.Create(PaintBox1);
    Res.ResType := tdKing;
    Res.ResCount := GetCountResource(25000);                                    // первоначальная королева должна быть с 25000 ресурсами
    if Res.ResCount >= 1500 then
      ResList.Add(Res)
    else
      Res.Destroy;
  end;

  if (ResList.Count-CountKing) < se_res_count.Value then
  begin
    var Res := TRes.Create(PaintBox1);
    Res.ResType := tdRes;
    Res.ResCount := GetCountResource(Random(1500) + 1500);                      // возьмем оттуда до от 1500 до 3000
    if Res.ResCount >= 500 then
      ResList.Add(Res)
    else
      Res.Destroy;
  end;

  if not chb_paint.Checked then
  begin
    if TimerMove.Tag div 4 = 0 then                                             // рисуем кадр каждый 4 цикл
    begin
      PaintBox1.Invalidate;
      TimerMove.Tag := 0;
    end;
    TimerMove.Tag := TimerMove.Tag + 1;
  end;

  Label1.Caption := 'Общие ресурсы: ' + GlobalResource.ToString;
  Label5.Caption := 'Ботов: ' + CountBot.ToString
                  + '/' + cnt_bot.ToString;
  var d_bot := BotList.Count - CountBot;
  Label8.Caption := 'Мёртвых/ресурсов: ' + d_bot.ToString
                  + '/' + IntToStr(d_bot*20);
  Label6.Caption := 'Королев: ' + CountKing.ToString;
  Label7.Caption := 'Цикл: ' + Label7.Tag.ToString;
  Label7.Tag := Succ(Label7.Tag);

  TimerMove.Enabled := True;
end;

end.
