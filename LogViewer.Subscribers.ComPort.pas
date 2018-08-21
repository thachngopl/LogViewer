{
  Copyright (C) 2013-2018 Tim Sinaeve tim.sinaeve@gmail.com

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
}

unit LogViewer.Subscribers.ComPort;

{ ComPort subscriber data. }

interface

uses
  System.Classes,

  synaser,

  LogViewer.Interfaces, LogViewer.ComPort.Settings, LogViewer.Subscribers.Base;

type
  TComPortSubscriber = class(TSubscriber)
  private
    FSettings   : TComPortSettings;
    FSerialPort : TBlockSerial;
    FBuffer     : TMemoryStream;

    procedure FSerialPortStatus(
      Sender      : TObject;
      Reason      : THookSerialReason;
      const Value : string
    );
    procedure SettingsChanged(Sender: TObject);

  protected
    {$REGION 'property access methods'}
    procedure SetEnabled(const Value: Boolean); override;
    {$ENDREGION}

    procedure Poll; override;

    procedure DoStringReceived(const AString: AnsiString);

  public
    constructor Create(
      AReceiver : IChannelReceiver;
      ASettings : TComPortSettings
    ); reintroduce;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

  end;

implementation

uses
  System.SysUtils, System.AnsiStrings,

  DDuce.Logger.Interfaces;

{$REGION 'construction and destruction'}
constructor TComPortSubscriber.Create(AReceiver: IChannelReceiver;
  ASettings: TComPortSettings);
begin
  inherited Create(AReceiver, 0, '', '', True);
  FSettings := TComPortSettings.Create;
  FSettings.Assign(ASettings);
  FSettings.OnChanged.Add(SettingsChanged);
end;

procedure TComPortSubscriber.AfterConstruction;
begin
  inherited AfterConstruction;
  FBuffer              := TMemoryStream.Create;
  FSerialPort          := TBlockSerial.Create;
  FSerialPort.OnStatus := FSerialPortStatus;
end;

procedure TComPortSubscriber.BeforeDestruction;
begin
  FSettings.OnChanged.Remove(SettingsChanged);
  FSettings.Free;
  FSerialPort.Free;
  FBuffer.Free;
  inherited BeforeDestruction;
end;
{$ENDREGION}

{$REGION 'property access methods'}
procedure TComPortSubscriber.SetEnabled(const Value: Boolean);
begin
  inherited SetEnabled(Value);
  if Value then
  begin
    FSerialPort.Connect(FSettings.Port);
    FSerialPort.Config(
      FSettings.BaudRate,
      FSettings.DataBits,
      FSettings.Parity,
      FSettings.StopBits,
      False,
      True
    );
  end
  else
  begin
    if FSerialPort.InstanceActive then
      FSerialPort.CloseSocket;
  end;
end;
{$ENDREGION}

{$REGION 'event handlers'}
procedure TComPortSubscriber.FSerialPortStatus(Sender: TObject;
  Reason: THookSerialReason; const Value: string);
var
  S: string;
begin
  case Reason of
    HR_SerialClose: S := 'Serial Close';
    HR_Connect:     S := 'Connect';
    HR_CanRead:     S := 'CanRead';
    HR_CanWrite:    S := 'CanWrite';
    HR_ReadCount:   S := 'ReadCount';
    HR_WriteCount:  S := 'WriteCount';
    HR_Wait:        S := 'Wait';
  end;
  if S <> '' then
  begin
//    sbrMain.SimpleText := Format('%s %s', [S, Value]);
//    FLogIn.LogFmt(
//      '%s %s',
//      [S, Value]
//    );
  end;
end;

procedure TComPortSubscriber.SettingsChanged(Sender: TObject);
begin
  if FSerialPort.Device <> FSettings.Port then
  begin
    if FSerialPort.InstanceActive then
    begin
      FSerialPort.CloseSocket;
      FSerialPort.Connect(FSettings.Port);
    end;
  end;
  FSerialPort.Config(
    FSettings.BaudRate,
    FSettings.DataBits,
    FSettings.Parity,
    FSettings.StopBits,
    False,
    True
  );
end;
{$ENDREGION}

{$REGION 'protected methods'}
procedure TComPortSubscriber.DoStringReceived(const AString: AnsiString);
const
  LZero : Integer = 0;
var
  LMsgType   : Integer;
  LTimeStamp : TDateTime;
  LTextSize  : Integer;
  LString    : UTF8String;
begin
  FBuffer.Clear;
  if ContainsStr(AString, '=') then
  begin
    LMsgType := Integer(lmtWatch);
  end
  else
    LMsgType := Integer(lmtText);
  LString    := UTF8String(AString);
  LTextSize  := Length(LString);
  LTimeStamp := Now;
  FBuffer.Seek(0, soFromBeginning);
  FBuffer.WriteBuffer(LMsgType, SizeOf(Integer));
  FBuffer.WriteBuffer(LTimeStamp, SizeOf(TDateTime));
  FBuffer.WriteBuffer(LTextSize, SizeOf(Integer));
  FBuffer.WriteBuffer(LString[1], LTextSize);
  FBuffer.WriteBuffer(LZero, SizeOf(Integer));
  Receiver.DoReceiveMessage(FBuffer);
end;

procedure TComPortSubscriber.Poll;
var
  S : AnsiString;
begin
  inherited Poll;
  while FSerialPort.WaitingDataEx <> 0 do
  begin
    S := Trim(FSerialPort.RecvTerminated(10, #10));
    DoStringReceived(S);
  end;
end;
{$ENDREGION}

end.
