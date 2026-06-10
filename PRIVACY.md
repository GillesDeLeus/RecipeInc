# recipeInc — Privacy Policy

**Effective date: June 2026**

*Een Nederlandse versie van dit beleid is beschikbaar in de app onder Instellingen → Privacybeleid.*

## 1. Introduction

recipeInc ("the App") is a personal recipe manager developed as an individual project. This Privacy Policy explains how your data is collected, stored, and protected when you use the App.

By using recipeInc, you agree to the practices described in this document. If you do not agree, please discontinue use of the App.

## 2. Data We Collect

recipeInc stores only data that you explicitly enter:

- **Recipes** – name, preparation time, instructions, photos, categories, and tags.
- **Ingredients** – name, unit of measurement, and shopping category.
- **Storage inventory** – ingredients you own, quantities, storage location, and optional expiry dates.
- **Meal plans** – dates, meal types, portions, and notes.
- **Shopping list** – items you add manually or generate from a meal plan, including name, amount, unit, category, and checked status.

The App does not collect any data automatically. No usage analytics, crash reports, advertising identifiers, or device telemetry are gathered.

## 3. How Your Data Is Stored

All data is stored locally on your device using Apple's SwiftData framework (backed by SQLite). Recipe photos are stored in the App's sandboxed container and never leave your device unless you use the Export or iCloud features described below.

No data is transmitted to external servers operated by the developer.

## 4. iCloud & CloudKit Sync (Upcoming)

A future version of recipeInc will offer optional iCloud synchronisation using Apple's CloudKit framework. When enabled:

- Your data will be stored in your personal iCloud account and synced across your devices.
- The data remains under your full control and is subject to Apple's iCloud Terms of Service and [Apple's Privacy Policy](https://www.apple.com/legal/privacy/).
- The developer has no access to your iCloud data at any time.
- You can disable iCloud sync at any time in Settings → [Your Name] → iCloud on your device. Disabling sync does not delete local data.
- Data in iCloud is encrypted in transit and at rest by Apple.

CloudKit sync will be strictly opt-in. The App will continue to work fully without an iCloud account.

## 5. Local Notifications

recipeInc may request permission to send local notifications to alert you when a storage item is approaching its expiry date (1 or 2 days before). These notifications:

- Are generated entirely on your device.
- Do not involve any network communication.
- Can be disabled at any time in your device's notification settings or by removing the expiry date from the relevant item.

## 6. Data Export & Import

The App provides an Export function that lets you save all your data as a JSON file to any location you choose (local storage, external drive, cloud service). You are solely responsible for the security of exported files.

The Import function reads a previously exported JSON file and merges its contents into the App. No data is sent to the developer during import or export.

## 7. Network Features

Some optional features connect to the internet, always at your explicit request:

- **Recipe import from a URL** – the App fetches the web page you provide (or share) directly from your device, including public caption data for TikTok and YouTube links. Your request goes straight to the website in question; the developer operates no intermediary server.
- **Barcode lookup** – when you scan a product barcode, the barcode number is sent to [Open Food Facts](https://openfoodfacts.org) to retrieve product information. No personal data accompanies this request.
- **AI recipe analysis** – all AI processing (text extraction and recipe parsing) happens on your device using Apple Intelligence. Recipe content is never sent to external AI services.

These requests are subject to the privacy policies of the websites contacted. The App sends no identifiers, accounts, or personal data with any request.

## 8. Data Sharing

recipeInc does not share, sell, rent, or disclose your personal data to any third party. The App contains no third-party SDKs, advertising frameworks, or analytics libraries.

The only circumstances under which data may leave your device are:

- You explicitly export data using the built-in export feature.
- You enable iCloud sync (governed by Apple's privacy policy).

## 9. Your Rights (GDPR)

If you are located in the European Economic Area (EEA), you have the following rights under the General Data Protection Regulation (GDPR):

- **Right of access** – You can view all your data directly within the App at any time.
- **Right to rectification** – You can edit any data in the App at any time.
- **Right to erasure** – You can delete individual items or all data by deleting the App from your device. For iCloud data, you can also delete it via iCloud.com or your device's iCloud settings.
- **Right to data portability** – Use the Export feature to obtain a machine-readable (JSON) copy of all your data.
- **Right to restriction & objection** – Because the App processes no data beyond what you enter yourself for your own personal use, processing is based on your consent and your legitimate interest. You may withdraw consent at any time by deleting the App.

Since all data is stored locally or in your personal iCloud account, the developer acts as a data processor only for the purpose of providing the App's functionality.

## 10. Data Retention

Your data is retained for as long as you keep the App installed. Uninstalling the App removes all local data from your device. iCloud data persists until you delete it via iCloud settings or iCloud.com.

## 11. Children's Privacy

recipeInc does not knowingly collect any information from children under the age of 13. The App does not contain any features designed to collect personal data from children.

## 12. Changes to This Policy

This Privacy Policy may be updated to reflect changes in the App's functionality (such as the addition of iCloud sync) or applicable law. Material changes will be communicated through an App Store update notice. The "Effective Date" at the top of this page will always reflect the date of the most recent revision.

Continued use of the App after a policy update constitutes acceptance of the revised policy.

## 13. Contact

If you have questions or concerns about this Privacy Policy or the handling of your data, please contact the developer:

**Email:** gilles.de.leus@devoteam.com

We aim to respond to all inquiries within 30 days.

---

*Data sources: nutritional values are based on NEVO (RIVM, the Netherlands). Barcode product data is provided by Open Food Facts under the Open Database License (ODbL).*
