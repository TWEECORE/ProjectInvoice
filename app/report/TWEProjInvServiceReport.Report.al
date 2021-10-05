/// <summary>
/// Report TWE Project Invoice (ID 50002).
/// </summary>
report 50002 "TWE Proj. Inv. Service Report"
{
    DefaultLayout = RDLC;
    RDLCLayout = 'ProjectInvoiceServiceReport.rdlc';
    Caption = 'Project Invoice Service Report';

    dataset
    {
        dataitem(DataItemName; "TWE Proj. Inv. Project Hours")
        {
            column(TicketNo; "Ticket ID")
            {

            }
            column(TicketNoCaption; FieldCaption("Ticket ID"))
            {

            }
            column(TicketName; "Ticket Name")
            {

            }
            column(TicketNameCaption; FieldCaption("Ticket Name"))
            {

            }
            column(DateValue; "Working Date")
            {

            }
            column(DateCaption; DateCaptionLbl)
            {

            }
            column(WorkDescription; "Work Description")
            {

            }
            column(WorkDescriptionCaption; FieldCaption("Work Description"))
            {

            }
            column(Hours; Hours)
            {

            }
            column(HoursCaption; FieldCaption(Hours))
            {

            }
            column(HoursToInvoice; "Hours to Invoice")
            {

            }
            column(HoursToInvoiceCaption; FieldCaption("Hours to Invoice"))
            {

            }
            column(Agent; Agent)
            {

            }
            column(AgentCaption; FieldCaption(Agent))
            {

            }
            column(DocCaption; DocumentCaptionLbl)
            {

            }
            column(TotalCaption; TotalCaptionLbl)
            {

            }

            trigger OnAfterGetRecord()
            var
            begin

            end;
        }

    }

    /*requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(Name; SourceExpression)
                    {
                        ApplicationArea = All;

                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;
                }
            }
        }
    } */

    var
        DocumentCaptionLbl: Label 'Service Report ';
        DateCaptionLbl: label 'Date';
        TotalCaptionLbl: Label 'Total:';

    trigger OnInitReport()
    begin

    end;
}
