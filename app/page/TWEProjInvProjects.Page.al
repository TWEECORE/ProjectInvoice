page 70704954 "TWE Proj. Inv. Projects"
{
    ApplicationArea = All;
    Caption = 'Proj. Inv. Projects';
    PageType = List;
    SourceTable = "TWE Project";
    UsageCategory = Lists;

    //TODO: Tooltips anpassen
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
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = All;
                }
                field("Related to Customer No."; Rec."Related to Customer No.")
                {
                    ToolTip = 'Specifies the value of the Related to Customer No. field';
                    ApplicationArea = All;
                }
                field("Related to Customer Name"; Rec."Related to Customer Name")
                {
                    ToolTip = 'Specifies the value of the Related to Customer Name field';
                    ApplicationArea = All;
                }
                field("Total Work Hours"; Rec."Total Work Hours")
                {
                    ToolTip = 'Specifies the value of the Total Work Hours field';
                    ApplicationArea = All;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the value of the Start Date field';
                    ApplicationArea = All;
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the value of the End Date field';
                    ApplicationArea = All;
                }
            }
        }
    }

}
