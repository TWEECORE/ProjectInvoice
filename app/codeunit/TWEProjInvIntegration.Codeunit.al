/// <summary>
/// Codeunit TWE Proj Inv. Integration (ID 50002).
/// </summary>
codeunit 50002 "TWE Proj Inv. Integration"
{
    var
        SetupWizardTxt: Label 'Set up your Project Invoice Application';
        PISetupTitleLbl: Label 'Project Invoice Setup';
        PISetupShortTitleLbl: Label 'Project Invoice Setup';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Guided Experience", 'OnRegisterAssistedSetup', '', false, false)]
    local procedure Initialize()
    var
        GuidedExperience: Codeunit "Guided Experience";
        Language: Codeunit Language;
        CurrentGlobalLanguage: Integer;
    begin
        if not GuidedExperience.Exists("Guided Experience Type"::"Assisted Setup", ObjectType::Page, Page::"TWE Proj Inv. Wizard") then begin
            CurrentGlobalLanguage := GlobalLanguage;
            GuidedExperience.InsertAssistedSetup(
                PISetupTitleLbl, PISetupShortTitleLbl,
                SetupWizardTxt, 5,
                ObjectType::Page, Page::"TWE Proj Inv. Wizard",
                "Assisted Setup Group"::Extensions, '', "Video Category"::Uncategorized, '');

            GlobalLanguage(Language.GetDefaultApplicationLanguageId());

            GuidedExperience.AddTranslationForSetupObjectTitle(
                "Guided Experience Type"::"Assisted Setup", ObjectType::Page,
                Page::"TWE Proj Inv. Wizard", Language.GetDefaultApplicationLanguageId(),
                SetupWizardTxt);
            GlobalLanguage(CurrentGlobalLanguage);
        end;
    end;
}
