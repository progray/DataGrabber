inherited frmcxGrid: TfrmcxGrid
  ClientHeight = 319
  ClientWidth = 695
  Font.Name = 'Se'
  ExplicitWidth = 695
  ExplicitHeight = 319
  PixelsPerInch = 96
  TextHeight = 14
  object grdMain: TcxGrid [0]
    Left = 0
    Top = 0
    Width = 695
    Height = 319
    Align = alClient
    BevelInner = bvNone
    BevelOuter = bvNone
    BorderStyle = cxcbsNone
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Calibri'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    LevelTabs.Slants.Positions = []
    LevelTabs.Style = 6
    LookAndFeel.Kind = lfStandard
    LookAndFeel.NativeStyle = True
    LookAndFeel.ScrollbarMode = sbmDefault
    object tvwMain: TcxGridDBTableView
      Navigator.Buttons.ConfirmDelete = True
      Navigator.Buttons.CustomButtons = <>
      Navigator.Buttons.Append.Visible = True
      Navigator.InfoPanel.Visible = True
      Navigator.Visible = True
      FilterBox.MRUItemsListDropDownCount = 10
      FindPanel.ApplyInputDelay = 500
      FindPanel.DisplayMode = fpdmAlways
      FindPanel.MRUItemsListCount = 100
      FindPanel.MRUItemsListDropDownCount = 20
      FindPanel.UseExtendedSyntax = True
      FindPanel.Location = fplGroupByBox
      ScrollbarAnnotations.Active = True
      ScrollbarAnnotations.CustomAnnotations = <>
      OnCustomDrawCell = tvwMainCustomDrawCell
      DataController.DataSource = dscMain
      DataController.MultiThreadedOptions.Filtering = bTrue
      DataController.MultiThreadedOptions.Sorting = bTrue
      DataController.Options = [dcoAssignGroupingValues, dcoAssignMasterDetailKeys, dcoSaveExpanding, dcoSortByDisplayText, dcoFocusTopRowAfterSorting, dcoImmediatePost, dcoInsertOnNewItemRowFocusing]
      DataController.Summary.DefaultGroupSummaryItems = <
        item
          Format = '0'
          Kind = skCount
          VisibleForCustomization = False
        end>
      DataController.Summary.FooterSummaryItems = <>
      DataController.Summary.SummaryGroups = <>
      DataController.Summary.Options = [soMultipleSelectedRecords]
      DateTimeHandling.Filters = [dtfRelativeDays, dtfRelativeDayPeriods, dtfRelativeWeeks, dtfRelativeMonths, dtfRelativeYears, dtfPastFuture, dtfMonths, dtfYears]
      EditForm.DefaultColumnCount = 6
      EditForm.DefaultStretch = fsHorizontal
      EditForm.ItemHotTrack = True
      Filtering.ColumnFilteredItemsList = True
      Filtering.ColumnMRUItemsListCount = 10
      Filtering.ColumnPopup.MaxDropDownItemCount = 30
      FilterRow.ApplyInputDelay = 500
      FixedDataRows.PinClickAction = rpcaNone
      FixedDataRows.PinVisibility = rpvHotTrack
      OptionsBehavior.CellHints = True
      OptionsBehavior.FocusCellOnTab = True
      OptionsBehavior.FocusFirstCellOnNewRecord = True
      OptionsBehavior.GoToNextCellOnEnter = True
      OptionsBehavior.IncSearch = True
      OptionsBehavior.NavigatorHints = True
      OptionsBehavior.BestFitMaxRecordCount = 100
      OptionsBehavior.ColumnMergedGrouping = True
      OptionsBehavior.FixedGroups = True
      OptionsBehavior.ImmediateEditor = False
      OptionsBehavior.ShowLockedStateImageOptions.BestFit = lsimImmediate
      OptionsBehavior.PullFocusing = True
      OptionsCustomize.ColumnExpressionEditing = True
      OptionsCustomize.ColumnHiding = True
      OptionsCustomize.ColumnsQuickCustomization = True
      OptionsCustomize.ColumnsQuickCustomizationSorted = True
      OptionsCustomize.DataRowSizing = True
      OptionsCustomize.GroupBySorting = True
      OptionsCustomize.GroupRowSizing = True
      OptionsData.Appending = True
      OptionsSelection.MultiSelect = True
      OptionsSelection.CellMultiSelect = True
      OptionsSelection.InvertSelect = False
      OptionsView.CellEndEllipsis = True
      OptionsView.FocusRect = False
      OptionsView.ExpandButtonsForEmptyDetails = False
      OptionsView.GridLineColor = clSilver
      OptionsView.HeaderAutoHeight = True
      OptionsView.HeaderEndEllipsis = True
      OptionsView.Indicator = True
      OptionsView.ShowColumnFilterButtons = sfbWhenSelected
      RowLayout.SmartCellNavigation = True
      OnCustomDrawColumnHeader = tvwMainCustomDrawColumnHeader
      OnCustomDrawGroupSummaryCell = tvwMainCustomDrawGroupSummaryCell
    end
    object grlMain: TcxGridLevel
      GridView = tvwMain
      Options.TabsForEmptyDetails = False
    end
  end
  object ppmMain: TcxGridPopupMenu
    Grid = grdMain
    PopupMenus = <>
    AlwaysFireOnPopup = True
    Left = 464
    Top = 248
  end
end
