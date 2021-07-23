table 70704952 "TWE Proj. Inv. Import Header"
{
    Caption = 'Import Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }

        field(5; "No. of Entries"; Integer)
        {
            Caption = 'No. of Entries';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("TWE Proj. Inv. Import Line" where("Import Header ID" = Field("Entry No.")));
        }
        field(6; "No of imported Entries"; Integer)
        {
            Caption = 'No. of imported Entries';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = count("TWE Proj. Inv. Import Line" where("Import Header ID" = field("Entry No."), Imported = const(true)));
        }
        field(7; "Total Hours"; Decimal)
        {
            Caption = 'Total Hourse';
            FieldClass = FlowField;

            CalcFormula = sum("TWE Proj. Inv. Import Line".Hours where("Import Header ID" = field("Entry No.")));
        }
        field(10; "Import Date"; Date)
        {
            Caption = 'Import Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Import Time"; Time)
        {
            Caption = 'Import Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(15; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "User ID"; Text[100])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
            TableRelation = User;
        }
    }
    keys
    {
        key(PK; "Entry No.")
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
        importLine: Record "TWE Proj. Inv. Import Line";
        ValidateDeleteLbl: Label 'Do you want to delete import %1 and associated import lines?', Comment = '%1=ImportHeaderEntryNo';
    begin
        if Confirm(StrSubstNo(ValidateDeleteLbl, Rec."Entry No.")) then begin
            importLine.SetRange("Import Header ID", "Entry No.");
            if importLine.FindSet() then
                DeleteAll(true);
        end;
    end;

    trigger OnRename()
    begin

    end;

}
