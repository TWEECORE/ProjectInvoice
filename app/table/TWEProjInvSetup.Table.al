/// <summary>
/// Table TWE Proj. Inv. Setup (ID 70704950).
/// </summary>
table 70704950 "TWE Proj. Inv. Setup"
{
    Caption = 'Project Invoice Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; ID; Integer)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Invoice Type"; Enum "TWE Proj. Inv. Invoice Type")
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
        }
        field(10; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("Invoice Type" = CONST("G/L Account")) "G/L Account" WHERE("Direct Posting" = CONST(true),
                                                                                               "Account Type" = CONST(Posting),
                                                                                               Blocked = CONST(false))
            ELSE
            IF ("Invoice Type" = CONST(Resource)) Resource
            ELSE
            IF ("Invoice Type" = CONST(Item)) Item WHERE(Blocked = CONST(false), "Sales Blocked" = CONST(false));
        }
        field(100; "No. Series for Proj. Invoices"; Code[20])
        {
            Caption = 'No. Series for Project Invoices';
            DataClassification = CustomerContent;
            TableRelation = "No. Series".Code;
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
    begin

    end;

    trigger OnRename()
    begin

    end;

    /// <summary>
    /// GetSetup.
    /// </summary>
    procedure GetSetup()
    begin
        if not FindFirst() then begin
            Init();
            Insert();
        end;
    end;

}
