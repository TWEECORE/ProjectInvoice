page 70704953 "TWE Proj. Inv. Import Lines"
{
    ApplicationArea = All;
    Caption = 'Proj. Inv. Import Lines';
    PageType = List;
    SourceTable = "TWE Proj. Inv. Import Line";
    UsageCategory = Lists;

    //TODO: Tooltips anpassen + Action Button Daten übernehmen

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(ID; Rec.ID)
                {
                    ToolTip = 'Specifies the value of the ID field';
                    ApplicationArea = All;
                }
                field("Import Header ID"; Rec."Import Header ID")
                {
                    ToolTip = 'Specifies the value of the Import Header ID field';
                    ApplicationArea = All;
                }
                field("Project ID"; Rec."Project ID")
                {
                    ToolTip = 'Specifies the value of the Project ID field';
                    ApplicationArea = All;
                }
                field("Project Name"; Rec."Project Name")
                {
                    ToolTip = 'Specifies the value of the Project Name field';
                    ApplicationArea = All;
                }
                field("Project Description"; Rec."Project Description")
                {
                    ToolTip = 'Specifies the value of the Project Description field';
                    ApplicationArea = All;
                }
                field("Ticket No."; Rec."Ticket No.")
                {
                    ToolTip = 'Specifies the value of the Ticket No. field';
                    ApplicationArea = All;
                }
                field("Ticket Name"; Rec."Ticket Name")
                {
                    ToolTip = 'Specifies the value of the Ticket Name field';
                    ApplicationArea = All;
                }
                field("Ticket Status"; Rec."Ticket Status")
                {
                    ToolTip = 'Specifies the value of the Ticket Status field';
                    ApplicationArea = All;
                }
                field(Hours; Rec.Hours)
                {
                    ToolTip = 'Specifies the value of the Hours field';
                    ApplicationArea = All;
                }
                field(Imported; Rec.Imported)
                {
                    ToolTip = 'Specifies the value of the Imported field';
                    ApplicationArea = All;
                }
            }
        }
    }

}
