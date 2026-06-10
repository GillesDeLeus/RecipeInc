import SwiftUI

struct PrivacyPolicyView: View {

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                // Header
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "Privacy Policy"))
                        .font(.largeTitle).fontWeight(.bold)
                    Text(String(localized: "Effective date: June 2026"))
                        .font(.subheadline).foregroundStyle(.secondary)
                }

                ForEach(sections, id: \.title) { section in
                    PolicySectionView(title: section.title, content: section.content)
                }
            }
            .padding(24)
        }
        .navigationTitle(String(localized: "Privacy Policy"))
        .navigationTitleDisplayMode(.inline)
    }

    // MARK: - Policy content

    private struct PolicySection {
        let title: String
        let content: String
    }

    // Prose documents aren't catalog material — pick the section set by locale.
    private var sections: [PolicySection] {
        Locale.current.language.languageCode?.identifier == "nl" ? dutchSections : englishSections
    }

    // MARK: English

    private let englishSections: [PolicySection] = [
        .init(
            title: "1. Introduction",
            content: """
            Koen's Kitchen ("the App") is a personal recipe manager developed as an individual project. This Privacy Policy explains how your data is collected, stored, and protected when you use the App.

            By using Koen's Kitchen, you agree to the practices described in this document. If you do not agree, please discontinue use of the App.
            """
        ),
        .init(
            title: "2. Data We Collect",
            content: """
            Koen's Kitchen stores only data that you explicitly enter:

            • Recipes – name, preparation time, instructions, photos, categories, and tags.
            • Ingredients – name, unit of measurement, and shopping category.
            • Storage inventory – ingredients you own, quantities, storage location, and optional expiry dates.
            • Meal plans – dates, meal types, portions, and notes.
            • Shopping list – items you add manually or generate from a meal plan, including name, amount, unit, category, and checked status.

            The App does not collect any data automatically. No usage analytics, crash reports, advertising identifiers, or device telemetry are gathered.
            """
        ),
        .init(
            title: "3. How Your Data Is Stored",
            content: """
            All data is stored locally on your device using Apple's SwiftData framework (backed by SQLite). Recipe photos are stored in the App's sandboxed container and never leave your device unless you use the Export or iCloud features described below.

            No data is transmitted to external servers operated by the developer.
            """
        ),
        .init(
            title: "4. iCloud & CloudKit Sync (Upcoming)",
            content: """
            A future version of Koen's Kitchen will offer optional iCloud synchronisation using Apple's CloudKit framework. When enabled:

            • Your data will be stored in your personal iCloud account and synced across your devices.
            • The data remains under your full control and is subject to Apple's iCloud Terms of Service and Apple's Privacy Policy (https://www.apple.com/legal/privacy/).
            • The developer has no access to your iCloud data at any time.
            • You can disable iCloud sync at any time in Settings → [Your Name] → iCloud on your device. Disabling sync does not delete local data.
            • Data in iCloud is encrypted in transit and at rest by Apple.

            CloudKit sync will be strictly opt-in. The App will continue to work fully without an iCloud account.
            """
        ),
        .init(
            title: "5. Local Notifications",
            content: """
            Koen's Kitchen may request permission to send local notifications to alert you when a storage item is approaching its expiry date (1 or 2 days before). These notifications:

            • Are generated entirely on your device.
            • Do not involve any network communication.
            • Can be disabled at any time in your device's notification settings or by removing the expiry date from the relevant item.
            """
        ),
        .init(
            title: "6. Data Export & Import",
            content: """
            The App provides an Export function that lets you save all your data as a JSON file to any location you choose (local storage, external drive, cloud service). You are solely responsible for the security of exported files.

            The Import function reads a previously exported JSON file and merges its contents into the App. No data is sent to the developer during import or export.
            """
        ),
        .init(
            title: "7. Network Features",
            content: """
            Some optional features connect to the internet, always at your explicit request:

            • Recipe import from a URL – the App fetches the web page you provide (or share) directly from your device, including public caption data for TikTok and YouTube links. Your request goes straight to the website in question; the developer operates no intermediary server.
            • Barcode lookup – when you scan a product barcode, the barcode number is sent to Open Food Facts (https://openfoodfacts.org) to retrieve product information. No personal data accompanies this request.
            • AI recipe analysis – all AI processing (text extraction and recipe parsing) happens on your device using Apple Intelligence. Recipe content is never sent to external AI services.

            These requests are subject to the privacy policies of the websites contacted. The App sends no identifiers, accounts, or personal data with any request.
            """
        ),
        .init(
            title: "8. Data Sharing",
            content: """
            Koen's Kitchen does not share, sell, rent, or disclose your personal data to any third party. The App contains no third-party SDKs, advertising frameworks, or analytics libraries.

            The only circumstances under which data may leave your device are:
            • You explicitly export data using the built-in export feature.
            • You enable iCloud sync (governed by Apple's privacy policy).
            """
        ),
        .init(
            title: "9. Your Rights (GDPR)",
            content: """
            If you are located in the European Economic Area (EEA), you have the following rights under the General Data Protection Regulation (GDPR):

            • Right of access – You can view all your data directly within the App at any time.
            • Right to rectification – You can edit any data in the App at any time.
            • Right to erasure – You can delete individual items or all data by deleting the App from your device. For iCloud data, you can also delete it via iCloud.com or your device's iCloud settings.
            • Right to data portability – Use the Export feature to obtain a machine-readable (JSON) copy of all your data.
            • Right to restriction & objection – Because the App processes no data beyond what you enter yourself for your own personal use, processing is based on your consent and your legitimate interest. You may withdraw consent at any time by deleting the App.

            Since all data is stored locally or in your personal iCloud account, the developer acts as a data processor only for the purpose of providing the App's functionality.
            """
        ),
        .init(
            title: "10. Data Retention",
            content: """
            Your data is retained for as long as you keep the App installed. Uninstalling the App removes all local data from your device. iCloud data persists until you delete it via iCloud settings or iCloud.com.
            """
        ),
        .init(
            title: "11. Children's Privacy",
            content: """
            Koen's Kitchen does not knowingly collect any information from children under the age of 13. The App does not contain any features designed to collect personal data from children.
            """
        ),
        .init(
            title: "12. Changes to This Policy",
            content: """
            This Privacy Policy may be updated to reflect changes in the App's functionality (such as the addition of iCloud sync) or applicable law. Material changes will be communicated through an App Store update notice. The "Effective Date" at the top of this page will always reflect the date of the most recent revision.

            Continued use of the App after a policy update constitutes acceptance of the revised policy.
            """
        ),
        .init(
            title: "13. Contact",
            content: """
            If you have questions or concerns about this Privacy Policy or the handling of your data, please contact the developer:

            Email: gilles.de.leus@devoteam.com

            We aim to respond to all inquiries within 30 days.
            """
        ),
    ]

    // MARK: Dutch

    private let dutchSections: [PolicySection] = [
        .init(
            title: "1. Inleiding",
            content: """
            Koen's Kitchen ("de App") is een persoonlijke receptenmanager ontwikkeld als individueel project. Dit Privacybeleid legt uit hoe uw gegevens worden verzameld, opgeslagen en beschermd bij het gebruik van de App.

            Door Koen's Kitchen te gebruiken, gaat u akkoord met de praktijken beschreven in dit document. Indien u niet akkoord gaat, verzoeken wij u de App niet langer te gebruiken.
            """
        ),
        .init(
            title: "2. Welke gegevens we verzamelen",
            content: """
            Koen's Kitchen slaat uitsluitend gegevens op die u expliciet invoert:

            • Recepten – naam, bereidingstijd, instructies, foto's, categorieën en labels.
            • Ingrediënten – naam, meeteenheid en winkelcategorie.
            • Voorraad – ingrediënten die u bezit, hoeveelheden, opslaglocatie en optionele vervaldatums.
            • Maaltijdplanning – datums, maaltijdtypes, porties en notities.
            • Boodschappenlijst – items die u handmatig toevoegt of genereert vanuit een maaltijdplan, inclusief naam, hoeveelheid, eenheid, categorie en afvinkstatus.

            De App verzamelt geen gegevens automatisch. Er worden geen gebruiksanalyses, crashrapporten, advertentie-identifiers of apparaattelemetrie verzameld.
            """
        ),
        .init(
            title: "3. Hoe uw gegevens worden opgeslagen",
            content: """
            Alle gegevens worden lokaal op uw apparaat opgeslagen via het SwiftData-framework van Apple (op basis van SQLite). Receptfoto's worden opgeslagen in de beveiligde container van de App en verlaten uw apparaat nooit, tenzij u de Export- of iCloud-functies gebruikt zoals hieronder beschreven.

            Er worden geen gegevens verzonden naar externe servers van de ontwikkelaar.
            """
        ),
        .init(
            title: "4. iCloud & CloudKit-synchronisatie (binnenkort beschikbaar)",
            content: """
            Een toekomstige versie van Koen's Kitchen zal optionele iCloud-synchronisatie aanbieden via het CloudKit-framework van Apple. Wanneer ingeschakeld:

            • Worden uw gegevens opgeslagen in uw persoonlijke iCloud-account en gesynchroniseerd tussen uw apparaten.
            • Blijven de gegevens volledig onder uw beheer en zijn ze onderworpen aan de iCloud-gebruiksvoorwaarden en het Privacybeleid van Apple (https://www.apple.com/nl/legal/privacy/).
            • Heeft de ontwikkelaar op geen enkel moment toegang tot uw iCloud-gegevens.
            • Kunt u iCloud-synchronisatie op elk moment uitschakelen via Instellingen → [Uw naam] → iCloud op uw apparaat. Het uitschakelen van synchronisatie verwijdert geen lokale gegevens.
            • Worden gegevens in iCloud door Apple versleuteld tijdens overdracht en opslag.

            CloudKit-synchronisatie zal strikt opt-in zijn. De App blijft volledig functioneel zonder iCloud-account.
            """
        ),
        .init(
            title: "5. Lokale meldingen",
            content: """
            Koen's Kitchen kan toestemming vragen om lokale meldingen te sturen wanneer een voorraaditem de vervaldatum nadert (1 of 2 dagen ervoor). Deze meldingen:

            • Worden volledig op uw apparaat gegenereerd.
            • Vereisen geen netwerkcommunicatie.
            • Kunnen op elk moment worden uitgeschakeld in de meldingsinstellingen van uw apparaat of door de vervaldatum van het betreffende item te verwijderen.
            """
        ),
        .init(
            title: "6. Exporteren & importeren van gegevens",
            content: """
            De App biedt een exportfunctie waarmee u al uw gegevens kunt opslaan als een JSON-bestand op een locatie naar keuze (lokale opslag, externe schijf, cloudservice). U bent zelf verantwoordelijk voor de beveiliging van geëxporteerde bestanden.

            De importfunctie leest een eerder geëxporteerd JSON-bestand en voegt de inhoud samen met de App. Er worden geen gegevens naar de ontwikkelaar verzonden tijdens importeren of exporteren.
            """
        ),
        .init(
            title: "7. Netwerkfuncties",
            content: """
            Sommige optionele functies maken verbinding met het internet, altijd op uw uitdrukkelijk verzoek:

            • Recepten importeren via URL – de App haalt de door u opgegeven (of gedeelde) webpagina rechtstreeks vanaf uw apparaat op, inclusief publieke bijschriften voor TikTok- en YouTube-links. Uw verzoek gaat rechtstreeks naar de betreffende website; de ontwikkelaar beheert geen tussenliggende server.
            • Barcode opzoeken – wanneer u een barcode scant, wordt het barcodenummer naar Open Food Facts (https://openfoodfacts.org) gestuurd om productinformatie op te halen. Er worden geen persoonsgegevens meegestuurd.
            • AI-receptanalyse – alle AI-verwerking (tekstherkenning en receptanalyse) gebeurt op uw apparaat via Apple Intelligence. Receptinhoud wordt nooit naar externe AI-diensten gestuurd.

            Deze verzoeken vallen onder het privacybeleid van de gecontacteerde websites. De App stuurt geen identifiers, accounts of persoonsgegevens mee met enig verzoek.
            """
        ),
        .init(
            title: "8. Delen van gegevens",
            content: """
            Koen's Kitchen deelt, verkoopt, verhuurt of openbaart uw persoonsgegevens niet aan derden. De App bevat geen SDK's van derden, advertentieraamwerken of analysetools.

            De enige omstandigheden waaronder gegevens uw apparaat kunnen verlaten zijn:
            • U exporteert gegevens expliciet via de ingebouwde exportfunctie.
            • U schakelt iCloud-synchronisatie in (geregeld door het privacybeleid van Apple).
            """
        ),
        .init(
            title: "8. Uw rechten (AVG/GDPR)",
            content: """
            Als u zich in de Europese Economische Ruimte (EER) bevindt, heeft u de volgende rechten op grond van de Algemene Verordening Gegevensbescherming (AVG/GDPR):

            • Recht op inzage – U kunt op elk moment alle gegevens in de App bekijken.
            • Recht op rectificatie – U kunt alle gegevens in de App op elk moment bewerken.
            • Recht op verwijdering – U kunt afzonderlijke items verwijderen of alle gegevens wissen door de App van uw apparaat te verwijderen. Voor iCloud-gegevens kunt u dit ook doen via iCloud.com of de iCloud-instellingen van uw apparaat.
            • Recht op gegevensoverdraagbaarheid – Gebruik de exportfunctie om een machineleesbare (JSON) kopie van al uw gegevens te verkrijgen.
            • Recht op beperking en bezwaar – Omdat de App uitsluitend gegevens verwerkt die u zelf hebt ingevoerd voor persoonlijk gebruik, is de verwerking gebaseerd op uw toestemming en uw gerechtvaardigd belang. U kunt uw toestemming op elk moment intrekken door de App te verwijderen.

            Omdat alle gegevens lokaal of in uw persoonlijke iCloud-account worden opgeslagen, treedt de ontwikkelaar uitsluitend op als gegevensverwerker ten behoeve van de functionaliteit van de App.
            """
        ),
        .init(
            title: "10. Bewaartermijn",
            content: """
            Uw gegevens worden bewaard zolang de App op uw apparaat is geïnstalleerd. Het verwijderen van de App wist alle lokale gegevens van uw apparaat. iCloud-gegevens blijven bewaard totdat u ze verwijdert via de iCloud-instellingen of iCloud.com.
            """
        ),
        .init(
            title: "11. Privacy van kinderen",
            content: """
            Koen's Kitchen verzamelt niet bewust gegevens van kinderen jonger dan 13 jaar. De App bevat geen functies die zijn ontworpen om persoonsgegevens van kinderen te verzamelen.
            """
        ),
        .init(
            title: "12. Wijzigingen in dit beleid",
            content: """
            Dit Privacybeleid kan worden bijgewerkt om wijzigingen in de functionaliteit van de App (zoals de toevoeging van iCloud-synchronisatie) of de toepasselijke wetgeving te weerspiegelen. Materiële wijzigingen worden gecommuniceerd via een App Store-updatemelding. De "Ingangsdatum" bovenaan deze pagina geeft altijd de datum van de meest recente herziening aan.

            Voortgezet gebruik van de App na een beleidsupdate houdt in dat u het herziene beleid aanvaardt.
            """
        ),
        .init(
            title: "13. Contact",
            content: """
            Voor vragen of opmerkingen over dit Privacybeleid of de verwerking van uw gegevens kunt u contact opnemen met de ontwikkelaar:

            E-mail: gilles.de.leus@devoteam.com

            We streven ernaar alle verzoeken binnen 30 dagen te beantwoorden.
            """
        ),
    ]
}

// MARK: - Section view

private struct PolicySectionView: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)
            Text(content)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
            .environment(AppSettings())
    }
}
