/// <summary>
/// Page TWE Proj Inv. Wizard (ID 70704951).
/// </summary>
page 70704951 "TWE Proj Inv. Wizard"
{
    PageType = NavigatePage;
    SourceTable = "TWE Proj. Inv. Setup";
    Caption = 'Project Invoice Setup';

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

            group(Step0)
            {
                Visible = (CurrentStep = 0);
                Caption = 'Welcome to your Project Invoice Setup.';
                InstructionalText = 'You have successfully installed the Project Invoice extension. Please follow the instruction on the next pages ....';
            }

            group(Step1)
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
            group(Step2)
            {
                Visible = (CurrentStep = 2);
                group("API Data")
                {
                    InstructionalText = 'Please fill your companies Project Mgt. System information.';
                    group("Project Management System")
                    {
                        group(ProjMgtPart)
                        {
                            ShowCaption = false;
                            part(ProjMgtSystems; "TWE Proj. Mgt. System SubPart")
                            {
                                ApplicationArea = All;
                            }
                        }
                    }
                }
            }

            group(Step3)
            {
                Visible = (CurrentStep = 3);
                group("Finish Setup")
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
        ProjInvSetup: Record "TWE Proj. Inv. Setup";
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
        ProjInvSetup.GetSetup();

        CurrentStep := 1;
        SetControls();
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