/// <summary>
/// Table TWE Project (ID 70704954).
/// </summary>
table 70704954 "TWE Project"
{
    DataClassification = CustomerContent;
    Caption = 'Project';

    fields
    {
        field(1; ID; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'ID';
            Editable = false;
        }
        field(2; Name; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
        }
        field(5; "Related to Customer No."; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Related to Customer No.';
        }
        field(6; "Related to Customer Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Related to Customer Name';
        }
        field(10; "Total Work Hours"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Total Work Hours';
            Editable = false;
        }
        field(15; "Start Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Start Date';
        }
        field(16; "End Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'End Date';
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        projectTicket: Record "TWE Project Ticket";
        ValidateDeleteLbl: Label 'Do you want to delete the project %1 and associated tickets?', Comment = '%1=ProjectName';
    begin
        if Confirm(StrSubstNo(ValidateDeleteLbl, Name)) then begin
            projectTicket.SetRange("Project ID", ID);
            if projectTicket.FindSet() then
                projectTicket.DeleteAll(true);
        end;
    end;

    trigger OnRename()
    begin

    end;

}