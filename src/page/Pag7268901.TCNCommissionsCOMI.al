page 7268901 "TCNCommissionsCOMI"
{
    Caption = 'Commissions';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = TCNCommissionsCOMI;
    InsertAllowed = false;
    ModifyAllowed = true;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Contenido)
            {
                field(FechaRegistro; Rec.FechaRegistro)
                {
                    ApplicationArea = All;
                }
                field(TipoDocumento; Rec.TipoDocumento)
                {
                    ApplicationArea = All;
                }
                field(NoDocumento; Rec.NoDocumento)
                {
                    ApplicationArea = All;
                }
                field(NoLinea; Rec.NoLinea)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(CodCliente; Rec.CodCliente)
                {
                    ApplicationArea = All;
                }

                field(Nombrecliente; Rec.Nombrecliente)
                {
                    ApplicationArea = All;
                }
                field("ItemNo."; Rec."ItemNo.")
                {
                    ApplicationArea = All;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(ItemDesc; Rec.ItemDesc)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field(Importe; Rec.Importe)
                {
                    ApplicationArea = All;
                }
                field("%Comision"; Rec."%Comision")
                {
                    ApplicationArea = All;
                }
                field(Importecomision; Rec.Importecomision)
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                }
                field(CodVendedor; Rec.CodVendedor)
                {
                    ApplicationArea = All;
                }
                field(NombreVendedor; Rec.NombreVendedor)
                {
                    ApplicationArea = All;
                }
                field(FechaLiquidacion; Rec."Application Date")
                {
                    ApplicationArea = All;
                }
                field(NoLiquidacion; Rec."Appl. Document No.")
                {
                    ApplicationArea = All;
                }
                field(CodVendedorCli; Rec.CodVendedorCli)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
            }
            group(Totals)
            {
                field(xTotalSales; xTotalSales)
                {
                    Caption = 'Total Sales';
                    Editable = false;
                    ApplicationArea = All;
                }
                field(xTotalCommission; xTotalCommission)
                {
                    Caption = 'Total Commission';
                    Editable = false;
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Reporting)
        {
            action(Print)
            {

                Caption = 'Print';
                Image = Print;
                //Promoted = true;
                //PromotedCategory = Report;
                ApplicationArea = All;

                trigger OnAction()
                var
                    rlCustLedgerEntry: Record "Cust. Ledger Entry";
                    rlSalesperson: Record "Salesperson/Purchaser";
                    rlComisiones: record TCNCommissionsCOMI;
                    repSalespersonCommission: report TCNSalespersonCommissionCOMI;
                    xCustomerNoFilter: Text;
                begin
                    CurrPage.SETSELECTIONFILTER(rlComisiones);
                    //repSalespersonCommission.SetFilter(rlComisiones);
                    rlCustLedgerEntry.Reset();
                    rlSalesperson.Reset();

                    rlCustLedgerEntry.SetFilter("Document Type", '%1|%2', rlCustLedgerEntry."Document Type"::Invoice, rlCustLedgerEntry."Document Type"::"Credit Memo");
                    if rlComisiones.FindSet() then
                        repeat
                            rlCustLedgerEntry.SetRange("Document No.", rlComisiones.NoDocumento);
                            if rlCustLedgerEntry.FindFirst() then begin
                                rlCustLedgerEntry.Mark(true);
                                if xCustomerNoFilter <> '' then
                                    xCustomerNoFilter := xCustomerNoFilter + '|' + Format(rlCustLedgerEntry."Entry No.")
                                else
                                    xCustomerNoFilter := Format(rlCustLedgerEntry."Entry No.")
                            end;
                        until rlComisiones.Next() = 0;
                    rlCustLedgerEntry.SetRange("Document No.");
                    rlCustLedgerEntry.MarkedOnly(true);
                    if xCustomerNoFilter <> '' then
                        rlCustLedgerEntry.SetFilter("Entry No.", xCustomerNoFilter);

                    if rlComisiones.GetFilter(CodVendedor) <> '' then
                        rlComisiones.CopyFilter(CodVendedor, rlSalesperson.Code);
                    if rlComisiones.GetFilter(FechaRegistro) <> '' then
                        rlComisiones.CopyFilter(FechaRegistro, rlSalesperson."Date Filter");

                    repSalespersonCommission.SetTableView(rlSalesperson);
                    repSalespersonCommission.SetTableView(rlCustLedgerEntry);
                    repSalespersonCommission.Run();
                end;
            }
        }
        area(Processing)
        {
            action(ModifyMultiple)
            {

                Caption = 'Modify Multiple';
                Image = ChangeBatch;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    rlComisiones: record TCNCommissionsCOMI;
                    plEntradadedatos: page TCN_EntradaDeDatos;
                    xPct: Decimal;
                begin
                    CurrPage.SETSELECTIONFILTER(rlComisiones);

                    plEntradadedatos.SETTITTLE('Indicar el nuevo %');
                    xPct := Rec."%Comision";
                    plEntradadedatos.ADDDECIMAL('% comision', xPct);
                    if plEntradadedatos.RUNMODAL() = Action::Yes then
                        xPct := plEntradadedatos.GETDECIMAL()
                    else
                        ERROR('Proceso cancelado por el usuario');

                    if rlComisiones.FindSet() then
                        repeat
                            rlComisiones.Validate("%Comision", xPct);
                            rlComisiones.Modify(true);
                        until rlComisiones.Next() = 0;
                end;
            }

            action(Apply)
            {

                Caption = 'Apply';
                Image = Apply;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    rlComisiones: record TCNCommissionsCOMI;
                    culTCNFuncionesCommissionsCOMI: Codeunit TCNFuncionesCommissionsCOMI;
                    clMessage: Label 'Se liquidan %1 registros con un total de %2';
                begin
                    CurrPage.SetSelectionFilter(rlComisiones);

                    rlComisiones.CalcSums(Importecomision);

                    if GuiAllowed then
                        Message(StrSubstNo(clMessage, rlComisiones.COUNT(), rlComisiones.Importecomision));

                    if rlComisiones.FindSet(true, false) then
                        repeat

                            culTCNFuncionesCommissionsCOMI.ApplyComissions(rlComisiones);
                            rlComisiones.Modify(TRUE);

                        until rlComisiones.Next() = 0;
                end;
            }
            action(UnApply)
            {

                Caption = 'UnApply';
                Image = UnApply;
                ApplicationArea = All;

                trigger OnAction()
                var
                    rlComisiones: record TCNCommissionsCOMI;
                    rlComisiones2: record TCNCommissionsCOMI;
                    culTCNFuncionesCommissionsCOMI: Codeunit TCNFuncionesCommissionsCOMI;
                    clMessage: Label 'Se desliquidan %1 registros con un total de %2';
                begin
                    CurrPage.SetSelectionFilter(rlComisiones);

                    rlComisiones.CalcSums(Importecomision);

                    if GuiAllowed then
                        Message(StrSubstNo(clMessage, rlComisiones.COUNT(), rlComisiones.Importecomision));

                    if rlComisiones.FindSet(true, false) then
                        repeat

                            rlComisiones2 := rlComisiones;
                            culTCNFuncionesCommissionsCOMI.UnApplyComissions(rlComisiones2);
                            rlComisiones := rlComisiones2;
                            rlComisiones.Modify(true);

                        until rlComisiones.NEXT() = 0;
                end;
            }

            action(Naviate)
            {

                Caption = 'Naviate';
                Image = Navigate;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = All;
                ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.'; // Buscar todos los movimientos y los documentos que existen para el número de documento y la fecha de registro que constan en el movimiento o documento seleccionados.

                trigger OnAction()
                begin
                    Rec.Navigate(false);
                end;
            }

            action(NaviateAppl)
            {

                Caption = 'Naviate Application';
                Image = Navigate;
                ApplicationArea = All;
                ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.'; // Buscar todos los movimientos y los documentos que existen para el número de documento y la fecha de registro que constan en el movimiento o documento seleccionados.

                trigger OnAction()
                begin
                    Rec.Navigate(true);
                end;
            }
        }
    }

    var
        xTotalCommission: Decimal;
        xTotalSales: Decimal;

    trigger OnAfterGetCurrRecord()
    var
        rlTCNCommissionsCOMI: Record TCNCommissionsCOMI;
    begin
        rlTCNCommissionsCOMI.CopyFilters(Rec);

        rlTCNCommissionsCOMI.CalcSums(Importe, Importecomision);
        xTotalSales := rlTCNCommissionsCOMI.Importe;
        xTotalCommission := rlTCNCommissionsCOMI.Importecomision;
    end;

}