/// <summary>
/// Table TWE Project (ID 70704954).
/// </summary>
table 70704954 "TWE Proj. Inv. Project"
{
    DataClassification = CustomerContent;
    Caption = 'Project Invoice Project';

    fields
    {
        field(1; ID; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'ID';
            Editable = false;
        }
        field(2; Name; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Name';
            Editable = false;
        }
        field(5; "Related to Customer No."; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Related to Customer No.';
            TableRelation = Customer where("No." = field("Related to Customer No."));

            trigger OnValidate()
            var
                customer: Record Customer;
            begin
                if customer.Get(rec."Related to Customer No.") then
                    Rec."Related to Customer Name" := customer.Name;
            end;
        }
        field(6; "Related to Customer Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Related to Customer Name';
        }
        field(10; "Total Work Hours"; Decimal)
        {
            Caption = 'Total Work Hours';
            DecimalPlaces = 2;
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(15; "Invoice Type"; Enum "TWE Proj. Inv. Invoice Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Invoice Type';
        }
        field(20; "No."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            TableRelation = IF ("Invoice Type" = CONST("G/L Account")) "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                                                               "Account Type" = CONST(Posting),
                                                                                               Blocked = CONST(false))
            ELSE
            IF ("Invoice Type" = CONST(Resource)) Resource
            ELSE
            IF ("Invoice Type" = CONST(Item)) Item WHERE(Blocked = CONST(false), "Sales Blocked" = CONST(false));
        }
        field(25; "Project Mgt System"; Enum "TWE Project Mgt. System")
        {
            DataClassification = CustomerContent;
            Caption = 'Project Mgt System';
            Editable = false;
        }
        field(30; "Use Standard Hourly Rate"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Use Standard Hourly Rate';
        }
        field(35; "Standard Hourly Rate"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Standard Hourly Rate';
        }
        field(40; "Summarize Times for Invoice"; Boolean)
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
        }
        field(50; "Summarized Description"; Text[100])
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
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
        projectTicket: Record "TWE Proj. Inv. Ticket";
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

    /// <summary>
    /// GetLastID.
    /// </summary>
    /// <returns>Return value of type Integer.</returns>
    procedure GetLastID(): Integer;
    var
        FindRecordManagement: Codeunit "Find Record Management";
    begin
        exit(FindRecordManagement.GetLastEntryIntFieldValue(Rec, FieldNo(ID)));
    end;
}