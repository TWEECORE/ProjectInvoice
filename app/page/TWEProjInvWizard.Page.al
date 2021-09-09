/// <summary>
/// Page TWE Proj Inv. Wizard (ID 70704951).
/// </summary>
page 70704951 "TWE Proj Inv. Wizard"
{
    PageType = NavigatePage;
    SourceTable = "TWE Proj. Inv. Setup";
    SourceTableTemporary = true;
    Caption = 'Project Invoice Setup';

    //TODO: Application OAuth Einrichtung
    layout
    {
        area(Content)
        {
            group(BannerStandard)
            {
                Editable = false;
                Visible = TopBannerVisible and (CurrentStep < 4);
                field(MediaResourcesStandard; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }
            group(BannerDone)
            {
                Editable = false;
                Visible = TopBannerVisible and (CurrentStep = 4);
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }

            group(Step1)
            {
                Visible = (CurrentStep = 0);
                Caption = 'Welcome to your Project Invoice Setup.';
                InstructionalText = 'You have successfully installed the Project Invoice extension. Please follow the instruction on the next pages ....';
            }

            group(Step2)
            {
                Visible = (CurrentStep = 1);
                group(General)
                {
                    InstructionalText = 'Please fill the information below.';
                    field("Invoice Type"; rec."Invoice Type")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Invoice Type that should be used to invoice project hours';
                    }
                    field("No."; rec."No.")
                    {
                        ApplicationArea = All;
                        ToolTip = 'No. of object to be invoiced';
                    }
                    field(NoSeries; Rec."No. Series for Proj. Invoices")
                    {
                        ApplicationArea = All;
                        ToolTip = 'No. Series for Imported project data';
                    }

                    field("Summarize Times for Invoice"; rec."Summarize Times for Invoice")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Defines whether all invoiced project times should be summarized';
                    }
                    field("Summarized Description"; rec."Summarized Description")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Defines summarized description';
                    }
                }
            }
            group(Step3)
            {
                Visible = (CurrentStep = 2);
                group("Project Management System")
                {
                    InstructionalText = 'Please fill the information below.';
                    field("Proj. Mgt. System Code"; oAuthApp.Code)
                    {
                        ApplicationArea = All;
                        ToolTip = 'API Application Name';
                    }
                    field("Proj. Mgt. System"; oAuthApp."TWE Project Mgt. System")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Project Management System Name';
                    }
                }
            }

            group(Step4)
            {
                Visible = (CurrentStep = 3);
                group(FinishPage)
                {
                    Caption = 'All done';
                    InstructionalText = 'Click on Finish to exit the setup and save the data.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = ActionBackAllowed;
                Image = PreviousRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    TakeStep(-1);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = ActionNextAllowed;
                Image = NextRecord;
                InFooterBar = true;

                trigger OnAction()
                begin
                    TakeStep(1);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = ActionFinishAllowed;
                Image = Approve;
                InFooterBar = true;

                trigger OnAction()
                begin
                    Finish();
                end;
            }
        }
    }

    var
        MediaRepositoryStandard: Record "Media Repository";
        MediaRepositoryDone: Record "Media Repository";
        MediaResourcesStandard: Record "Media Resources";
        MediaResourcesDone: Record "Media Resources";
        oAuthApp: Record "TWE OAuth 2.0 Application";
        CurrentStep: Integer;
        ActionBackAllowed: Boolean;
        ActionNextAllowed: Boolean;
        ActionFinishAllowed: Boolean;
        TopBannerVisible: Boolean;

    trigger OnInit()
    begin
        LoadTopBanners();
    end;

    trigger OnOpenPage()
    begin
        CurrentStep := 1;
        SetControls();
        Rec."Summarize Times for Invoice" := true;
    end;

    local procedure SetControls()
    begin
        ActionBackAllowed := CurrentStep > 1;
        ActionNextAllowed := (CurrentStep < 3);
        ActionFinishAllowed := (CurrentStep = 3);
    end;

    local procedure TakeStep(Step: Integer)
    begin
        CurrentStep += Step;
        SetControls();
    end;

    local procedure Finish()
    begin
        StoreRecordVar();
        CurrPage.Close();
    end;

    local procedure StoreRecordVar();
    var
        RecordVar: Record "TWE Proj. Inv. Setup";
    begin
        if not RecordVar.Get() then begin
            RecordVar.Init();
            RecordVar.Insert();
        end;

        RecordVar.TransferFields(Rec, false);
        RecordVar.Modify(true);
    end;

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png', Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png', Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;
}