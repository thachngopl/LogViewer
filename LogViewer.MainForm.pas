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

unit LogViewer.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,

  ChromeTabs, ChromeTabsClasses, ChromeTabsTypes,

  LogViewer.Interfaces,
  LogViewer.Factories, LogViewer.Manager, LogViewer.Settings,
  LogViewer.ComPort.Settings,

  LogViewer.Dashboard.View;

type
  TfrmMain = class(TForm)
    sbrMain       : TStatusBar;
    ctMain        : TChromeTabs;
    pnlMainClient : TPanel;

    procedure ctMainButtonAddClick(
      Sender      : TObject;
      var Handled : Boolean
    );
    procedure ctMainButtonCloseTabClick(
      Sender    : TObject;
      ATab      : TChromeTab;
      var Close : Boolean
    );
    procedure ctMainNeedDragImageControl(
      Sender          : TObject;
      ATab            : TChromeTab;
      var DragControl : TWinControl
    );
    procedure ctMainActiveTabChanged(
      Sender : TObject;
      ATab   : TChromeTab
    );
    procedure ctMainTabDragDrop(
      Sender             : TObject;
      X, Y               : Integer;
      DragTabObject      : IDragTabObject;
      Cancelled          : Boolean;
      var TabDropOptions : TTabDropOptions
    );
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);

  private
    FMessageViewer   : ILogViewer;
    FManager         : TdmManager;
    FSettings        : TLogViewerSettings;
    FMainToolbar     : TToolBar;
    FComPortSettings : TComPortSettings;
    FDashboard       : TfrmDashboard;

    procedure SettingsChanged(Sender: TObject);

    procedure ProcessDroppedTab(
      Sender             : TObject;
      X, Y               : Integer;
      DragTabObject      : IDragTabObject;
      Cancelled          : Boolean;
      var TabDropOptions : TTabDropOptions
    );

  protected
    {$REGION 'property access methods'}
    function GetEvents: ILogViewerEvents;
    function GetActions: ILogViewerActions;
    function GetMenus: ILogViewerMenus;
    function GetManager: ILogViewerManager;
    {$ENDREGION}

    procedure EventsAddLogViewer(
      Sender     : TObject;
      ALogViewer : ILogViewer
    );

    procedure CreateDashboardView;

    procedure UpdateTabs;
    procedure UpdateStatusBar;

  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;

    property Manager: ILogViewerManager
      read GetManager;

    property Actions: ILogViewerActions
      read GetActions;

    { Menu components to use in the user interface. }
    property Menus: ILogViewerMenus
      read GetMenus;

    { Set of events where the user interface can respond to. }
    property Events: ILogViewerEvents
      read GetEvents;

    end;

var
  frmMain: TfrmMain;

implementation

uses
  Spring;

{$R *.dfm}

{$REGION 'construction and destruction'}
procedure TfrmMain.AfterConstruction;
begin
  inherited AfterConstruction;
  FSettings := TLogViewerFactories.CreateSettings;
  FSettings.Load;
  FManager := TLogViewerFactories.CreateManager(Self, FSettings);
  Events.OnAddLogViewer.Add(EventsAddLogViewer);
  FSettings.FormSettings.AssignTo(Self);
  FSettings.OnChanged.Add(SettingsChanged);
  FMainToolbar := TLogViewerFactories.CreateMainToolbar(
    FManager,
    Self,
    Actions,
    Menus
  );
  CreateDashboardView;
end;

procedure TfrmMain.BeforeDestruction;
begin
  FSettings.FormSettings.Assign(Self);
  FSettings.Save;
  FSettings.Free;
  FComPortSettings.Free;
  inherited BeforeDestruction;
end;
{$ENDREGION}

{$REGION 'event handlers'}
procedure TfrmMain.ctMainActiveTabChanged(Sender: TObject; ATab: TChromeTab);
var
  MV : ILogViewer;
begin
  if ATab.DisplayName = 'Dashboard' then
  begin
    FDashboard.Show;
    FDashboard.SetFocus;
  end
  else if Assigned(ATab.Data) then
  begin
    MV := ILogViewer(ATab.Data);
    MV.Form.Show;
    MV.Form.SetFocus;
    Manager.ActiveView := MV;
  end;
end;

procedure TfrmMain.ctMainButtonAddClick(Sender: TObject; var Handled: Boolean);
//var
//  LMessageViewer : ILogViewer;
//  LTab           : TChromeTab;
begin
//  LMessageViewer := TLogViewerFactories.CreateMessagesView(
//    FManager,
//    pnlMainClient,
//    FMessageViewer.Receiver
//  );
//  Manager.AddView(LMessageViewer);
//  LTab := ctMain.Tabs.Add;
//  LTab.Data := Pointer(LMessageViewer);
//  LTab.Caption := Format('%s-%s', [
//    LMessageViewer.Form.Caption,
//    LMessageViewer.Receiver.Name
//  ]);
//  Handled := True;
end;

procedure TfrmMain.ctMainButtonCloseTabClick(Sender: TObject; ATab: TChromeTab;
  var Close: Boolean);
begin
  Close := False;
end;

procedure TfrmMain.ctMainNeedDragImageControl(Sender: TObject; ATab: TChromeTab;
  var DragControl: TWinControl);
begin
  DragControl := pnlMainClient;
end;

procedure TfrmMain.ctMainTabDragDrop(Sender: TObject; X, Y: Integer;
  DragTabObject: IDragTabObject; Cancelled: Boolean;
  var TabDropOptions: TTabDropOptions);
begin
  // TODO: not working yet
  //ProcessDroppedTab(Sender, X, Y, DragTabObject, Cancelled, TabDropOptions);
end;

procedure TfrmMain.EventsAddLogViewer(Sender: TObject;
  ALogViewer: ILogViewer);
begin
  ALogViewer.Receiver.Enabled := True;
  ALogViewer.Form.Parent := pnlMainClient;
  ctMain.Tabs.Add;
  ctMain.ActiveTab.Data := Pointer(ALogViewer);
  ctMain.ActiveTab.Caption := ALogViewer.Receiver.ToString;
  ALogViewer.Form.Show;
end;

procedure TfrmMain.SettingsChanged(Sender: TObject);
begin
  FormStyle   := FSettings.FormSettings.FormStyle;
  WindowState := FSettings.FormSettings.WindowState;
end;

procedure TfrmMain.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  Handled := Manager.Actions.ActionList.IsShortCut(Msg);
end;

{$ENDREGION}

{$REGION 'property access methods'}
function TfrmMain.GetActions: ILogViewerActions;
begin
  Result := Manager.Actions;
end;

function TfrmMain.GetEvents: ILogViewerEvents;
begin
  Result := FManager as ILogViewerEvents;
end;

function TfrmMain.GetManager: ILogViewerManager;
begin
  Result := FManager as ILogViewerManager;
end;

function TfrmMain.GetMenus: ILogViewerMenus;
begin
  Result := Manager.Menus;
end;
{$ENDREGION}

{$REGION 'protected methods'}
procedure TfrmMain.CreateDashboardView;
begin
  FDashboard := TfrmDashboard.Create(Self, Manager);
  FDashboard.Parent      := pnlMainClient;
  FDashboard.BorderStyle := bsNone;
  FDashboard.Align       := alClient;

  ctMain.Tabs.Add;
  ctMain.ActiveTab.Data        := Pointer(FDashboard);
  ctMain.ActiveTab.Caption     := 'Dashboard';
  ctMain.ActiveTab.DisplayName := 'Dashboard';
  ctMain.ActiveTab.Pinned      := True;
  FDashboard.Show;
end;

{ Handles the drop operation of a dragged tab. }

procedure TfrmMain.ProcessDroppedTab(Sender: TObject; X, Y: Integer;
  DragTabObject: IDragTabObject; Cancelled: Boolean;
  var TabDropOptions: TTabDropOptions);
var
  WinX, WinY: Integer;
  NewForm   : TForm;
begin
  // Make sure that the drag drop hasn't been cancelled and that
  // we are not dropping on a TChromeTab control
  if (not Cancelled) and
    (DragTabObject.SourceControl <> DragTabObject.DockControl) and
    (DragTabObject.DockControl = nil) then
  begin
    // Find the drop position
    WinX := Mouse.CursorPos.X - DragTabObject.DragCursorOffset.X -
      ((Width - ClientWidth) div 2);
    WinY := Mouse.CursorPos.Y - DragTabObject.DragCursorOffset.Y -
      (Height - ClientHeight) + ((Width - ClientWidth) div 2);

    // Create a new form
    NewForm := TForm.Create(Application);

    // Set the new form position
    NewForm.Position := poDesigned;
    NewForm.Left     := WinX;
    NewForm.Top      := WinY;

    // Show the form
    NewForm.Show;

    // Remove the original tab
    TabDropOptions := [tdDeleteDraggedTab];
  end;
end;

procedure TfrmMain.UpdateStatusBar;
begin
//
end;

procedure TfrmMain.UpdateTabs;
var
  MV : ILogViewer;
  CT : TChromeTab;
begin
  if Manager.Views.Count = 1 then
  begin
    ctMain.Visible := False;
//    if Assigned(Editor) then
//      Editor.Visible := True;
  end
  else
  begin
    ctMain.BeginUpdate;
    ctMain.Tabs.Clear;
    for MV in Manager.Views do
    begin
      CT := ctMain.Tabs.Add;
      CT.Data := Pointer(MV);
    end;
    ctMain.Visible := True;
    ctMain.EndUpdate;
  end;
end;
{$ENDREGION}

end.
