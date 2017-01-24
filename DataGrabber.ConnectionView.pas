{
  Copyright (C) 2013-2017 Tim Sinaeve tim.sinaeve@gmail.com

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

unit DataGrabber.ConnectionView;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.ActnList, Vcl.ExtCtrls,

  VirtualTrees,

  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxPCdxBarPopupMenu, cxPC, dxDockControl, dxDockPanel, dxBarBuiltInMenu,
  dxSkinsCore,

  ts.Interfaces,

  DataGrabber.Interfaces, DataGrabber.ConnectionProfiles;

{
   A IConnectionView instance consists of
     - one editorview
     - one or more dataviews corresponding to the user input in the editor as
       multiple datasets can be returned as a result of one statement.

     - a list of connectionprofiles

     - an active connection profile (of the available profiles in
        FSettings.ConnectionProfiles)

     - The owner of a ConnectionView is always a IConnectionViewManager instance
}

type
  TfrmConnectionView = class(TForm, IConnectionView)
    dsGrids       : TdxDockSite;
    dxdckst1      : TdxDockSite;
    ldsGrid       : TdxLayoutDockSite;
    pcGrid        : TcxPageControl;
    pnlBottom     : TPanel;
    pnlEditor     : TPanel;
    pnlGrid       : TPanel;
    pnlGrid1      : TdxDockPanel;
    pnlProfiles   : TPanel;
    pnlTop        : TPanel;
    splHorizontal : TSplitter;
    splVertical   : TSplitter;

    procedure vstProfilesBeforeCellPaint(
      Sender          : TBaseVirtualTree;
      TargetCanvas    : TCanvas;
      Node            : PVirtualNode;
      Column          : TColumnIndex;
      CellPaintMode   : TVTCellPaintMode;
      CellRect        : TRect;
      var ContentRect : TRect
    );
    procedure vstProfilesGetText(
      Sender       : TBaseVirtualTree;
      Node         : PVirtualNode;
      Column       : TColumnIndex;
      TextType     : TVSTTextType;
      var CellText : string
    );
    procedure vstProfilesFocusChanged(
      Sender : TBaseVirtualTree;
      Node   : PVirtualNode;
      Column : TColumnIndex
    );
    procedure vstProfilesPaintText(
      Sender             : TBaseVirtualTree;
      const TargetCanvas : TCanvas;
      Node               : PVirtualNode;
      Column             : TColumnIndex;
      TextType           : TVSTTextType
    );
    procedure tlbGridCustomDraw(
      Sender          : TToolBar;
      const ARect     : TRect;
      var DefaultDraw : Boolean
    );

    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure FormShow(Sender: TObject);

  private
    FEditorView     : IEditorView;
    FActiveDataView : IDGDataView;
    FActiveData     : IData;
    vstProfiles     : TVirtualStringTree;

    function GetManager: IConnectionViewManager;
    function GetForm: TForm;
    function GetActiveData: IData;
    function GetActiveDataView: IDGDataView;
    function GetEditorView: IEditorView;
    function GetActiveConnectionProfile: TConnectionProfile;

  protected
    procedure Copy;
    procedure InitializeEditorView;

    procedure UpdateActions; override;

    procedure ApplySettings;

    procedure InitializeControls;

  public
    procedure AfterConstruction; override;
    constructor Create(
      AOwner      : TComponent;
      AEditorView : IEditorView;
      ADataView   : IDGDataView;
      AData       : IData
    ); reintroduce; virtual;

    property Form: TForm
      read GetForm;

    property Manager: IConnectionViewManager
      read GetManager;

    property ActiveDataView: IDGDataView
      read GetActiveDataView;

    property ActiveData: IData
      read GetActiveData;

    property ActiveConnectionProfile: TConnectionProfile
      read GetActiveConnectionProfile;

    property EditorView: IEditorView
      read GetEditorView;
  end;

implementation

uses
  System.UITypes,

  Spring, Spring.Services,

  DDuce.Factories,

  DataGrabber.Utils, DataGrabber.Data;

{$R *.dfm}

{$REGION 'construction and destruction'}
constructor TfrmConnectionView.Create(AOwner: TComponent;
  AEditorView: IEditorView; ADataView: IDGDataView; AData: IData);
begin
  inherited Create(AOwner);
  Guard.CheckNotNull(AEditorView, 'AEditorView');
  Guard.CheckNotNull(ADataView, 'ADataView');
  Guard.CheckNotNull(AData, 'AData');
  FEditorView     := AEditorView;
  FActiveDataView := ADataView;
  FActiveData     := AData;
  ActiveDataView.AssignParent(pnlBottom);
end;

procedure TfrmConnectionView.AfterConstruction;
begin
  inherited AfterConstruction;
  InitializeEditorView;
  vstProfiles := TFactories.CreateVirtualStringTree(Self, pnlProfiles);
  vstProfiles.RootNodeCount     := Manager.Settings.ConnectionProfiles.Count;
  vstProfiles.OnBeforeCellPaint := vstProfilesBeforeCellPaint;
  vstProfiles.OnGetText         := vstProfilesGetText;
  vstProfiles.OnFocusChanged    := vstProfilesFocusChanged;
  vstProfiles.OnPaintText       := vstProfilesPaintText;
  // TODO: select default node
  vstProfiles.FocusedNode       := vstProfiles.GetFirstVisible;
  InitializeControls;
  ApplySettings;
end;

procedure TfrmConnectionView.InitializeEditorView;
var
  F: TForm;
begin
  //FEditorView.OnStatusChange := EditorViewStatusChange;
  F := FEditorView as TForm;
  F.PopupMenu      := Manager.ConnectionViewPopupMenu;
  F.BorderStyle    := bsNone;
  F.Parent         := pnlTop;
  F.Align          := alClient;
  F.Visible        := True;
end;
{$ENDREGION}

{$REGION 'event handlers'}
procedure TfrmConnectionView.vstProfilesBeforeCellPaint(
  Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; CellPaintMode: TVTCellPaintMode; CellRect: TRect;
  var ContentRect: TRect);
var
  VST : TVirtualStringTree absolute Sender;
begin
  TargetCanvas.Brush.Color :=
    Manager.Settings.ConnectionProfiles[Node.Index].ProfileColor;
  TargetCanvas.FillRect(CellRect);
  if Sender.FocusedNode = Node then
  begin
    TargetCanvas.DrawFocusRect(CellRect);
  end;
end;

{ Needed to allow the shortcuts of the manager's actions to be executed. }

procedure TfrmConnectionView.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  Handled := True;
end;

procedure TfrmConnectionView.FormShow(Sender: TObject);
begin
  EditorView.SetFocus;
end;

procedure TfrmConnectionView.vstProfilesFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  if ContainsFocus(Self) then
    ApplySettings;
end;

procedure TfrmConnectionView.vstProfilesGetText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; TextType: TVSTTextType;
  var CellText: string);
begin
  CellText := Manager.Settings.ConnectionProfiles[Node.Index].DisplayName;
end;

procedure TfrmConnectionView.vstProfilesPaintText(Sender: TBaseVirtualTree;
  const TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex;
  TextType: TVSTTextType);
begin
  if Sender.FocusedNode = Node then
  begin
    TargetCanvas.Font.Style := TargetCanvas.Font.Style + [fsBold];
  end;
end;

procedure TfrmConnectionView.tlbGridCustomDraw(Sender: TToolBar;
  const ARect: TRect; var DefaultDraw: Boolean);
begin
  Sender.Canvas.FillRect(ARect);
end;
{$ENDREGION}

{$REGION 'property access methods'}
function TfrmConnectionView.GetActiveConnectionProfile: TConnectionProfile;
begin
  if Assigned(vstProfiles.FocusedNode) then
    Exit(Manager.Settings.ConnectionProfiles.Items[vstProfiles.FocusedNode.Index])
  else
    Exit(nil);
end;

function TfrmConnectionView.GetActiveData: IData;
begin
  Result := FActiveData;
end;

function TfrmConnectionView.GetActiveDataView: IDGDataView;
begin
  Result := FActiveDataView;
end;

function TfrmConnectionView.GetManager: IConnectionViewManager;
begin
  Result := Owner as IConnectionViewManager;
end;

function TfrmConnectionView.GetEditorView: IEditorView;
begin
  Result := FEditorView;
end;

function TfrmConnectionView.GetForm: TForm;
begin
  Result := Self;
end;
{$ENDREGION}

{$REGION 'private methods'}
procedure TfrmConnectionView.InitializeControls;
begin
  //tlbGrid.DrawingStyle := TTBDrawingStyle.dsNormal;

//    actADO                        : TAction;
//    actAutoSizeCols               : TAction;
//    actCommitTransaction          : TAction;
//    actCopy                       : TAction;
//    actCreateModel                : TAction;
//    actcxGrid                     : TAction;
//    actDataInspector              : TAction;
//    actDBX                        : TAction;
//    actDebug                      : TAction;
//    actDesigner                   : TAction;
//    actExecute                    : TAction;
//    actExecuteLimited             : TAction;
//    actFavoriteFieldsOnly         : TAction;
//    actFormatSQL                  : TAction;
//    actGridMode                   : TAction;
//    actGridView                   : TAction;
//    actGroupBySelection           : TAction;
//    actHideConstantColumns        : TAction;
//    actHideEmptyColumns           : TAction;
//    actHideSelectedColumns        : TAction;
//    actInspect                    : TAction;
//    actInspectConnection          : TAction;
//    actInspectDataSet             : TAction;
//    actInspectFields              : TAction;
//    actInspectGrid                : TAction;
//    actKGrid                      : TAction;
//    actMergeAllColumnCells        : TAction;
//    actMergeCells                 : TAction;
//    actPreview                    : TAction;
//    actPrint                      : TAction;
//    actProviderMode               : TAction;
//    actRollbackTransaction        : TAction;
//    actRtti                       : TAction;
//    actSelectionAsCommaText       : TAction;
//    actSelectionAsFields          : TAction;
//    actSelectionAsQuotedCommaText : TAction;
//    actSelectionAsQuotedFields    : TAction;
//    actSelectionAsText            : TAction;
//    actSelectionAsTextTable       : TAction;
//    actSelectionAsWhereIn         : TAction;
//    actSelectionAsWiki            : TAction;
//    actSettings                   : TAction;
//    actShowAllColumns             : TAction;
//    actStartTransaction           : TAction;
//    actSyncEditorWithRepository   : TAction;
//    actToggleFullScreen           : TAction;
//    actToggleRepositoryTree       : TAction;
//    actToggleStayOnTop            : TAction;
//    actUNI                        : TAction;
//    actVirtualDBGrid              : TAction;
//    actZEOS                       : TAction;
end;
{$ENDREGION}

{$REGION 'protected methods'}
procedure TfrmConnectionView.ApplySettings;
var
  CP: TConnectionProfile;
begin
  if Assigned(vstProfiles.FocusedNode) then
  begin
    CP := Manager.Settings.ConnectionProfiles.Items[vstProfiles.FocusedNode.Index];
    EditorView.Color := CP.ProfileColor;
    Application.Title := CP.Name;
    Caption := CP.Name;
    if CP.ConnectionType <> '' then
    begin
      //CreateData(CP.ConnectionType);
      FActiveData.Connection.ConnectionSettings.Assign(CP.ConnectionSettings);
      FActiveData.PacketRecords := CP.PacketRecords;
      FActiveData.ProviderMode  := CP.ProviderMode;
      FActiveData.FetchOnDemand := CP.FetchOnDemand;
    end;
  end;
//  CreateView(Manager.Settings.GridType);

//  S := FSettings.ConnectionType;
//  if S = 'ADO' then
//    actADO.Checked := True
//  else if S = 'DBX' then
//    actDBX.Checked := True
//  else if S = 'ZEOS' then
//    actZEOS.Checked := True
//  else if S = 'UNI' then
//    actUNI.Checked := True;
//
//  S := FSettings.GridType;
//  if S = 'cxGrid' then
//    actcxGrid.Checked := True
//  else if S = 'GridView' then
//    actGridView.Checked := True
//  else if S = 'KGrid' then
//    actKGrid.Checked := True
//  else if S = 'VirtualDBGrid' then
//    actVirtualDBGrid.Checked := True;
//
//  if FSettings.RepositoryVisible then
//    ShowToolWindow(FTree);
//
//  if FSettings.DataInspectorVisible then
//    ShowToolWindow(FDataInspector);
end;

procedure TfrmConnectionView.Copy;
begin
  if EditorView.EditorFocused then
    EditorView.CopyToClipboard
  else
    ActiveDataView.Copy;
end;

procedure TfrmConnectionView.UpdateActions;
begin
  inherited;
  if ContainsFocus(Self) then
  begin
    if Manager.ActiveConnectionView <> (Self as IConnectionView) then
    begin
      Manager.ActiveConnectionView := Self;
      EditorView.SetFocus;
    end;
    Manager.UpdateActions;
  end;
end;
{$ENDREGION}

end.
