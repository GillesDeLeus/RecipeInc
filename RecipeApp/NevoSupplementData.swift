import Foundation

// Extended nutritional values not present in NevoEntry.
// Per 100 g: satFat (g), sugars (g), sodium (mg), potassium (mg),
//            calcium (mg), iron (mg), vitC (mg), vitD (µg).
// Keys match NutritionService.normalize(NevoEntry.name).
struct NutritionSupplement {
    let satFat: Double
    let sugars: Double
    let sodium: Double
    let potassium: Double
    let calcium: Double
    let iron: Double
    let vitC: Double
    let vitD: Double
}

let nevoSupplementData: [String: NutritionSupplement] = [

    // ── Vegetables ──────────────────────────────────────────────────────────
    "aardappelen rauw":         .init(satFat:0.0,  sugars:0.8,  sodium:7,   potassium:407, calcium:9,   iron:0.7, vitC:14,  vitD:0),
    "aardappelen nieuwe rauw":  .init(satFat:0.0,  sugars:0.8,  sodium:7,   potassium:407, calcium:9,   iron:0.7, vitC:14,  vitD:0),
    "andijvie rauw":            .init(satFat:0.0,  sugars:0.5,  sodium:22,  potassium:314, calcium:52,  iron:0.8, vitC:7,   vitD:0),
    "asperge witte rauw":       .init(satFat:0.0,  sugars:2.0,  sodium:2,   potassium:202, calcium:24,  iron:0.6, vitC:9,   vitD:0),
    "aubergine rauw":           .init(satFat:0.0,  sugars:2.4,  sodium:2,   potassium:229, calcium:9,   iron:0.2, vitC:2.2, vitD:0),
    "biet rode rauw":           .init(satFat:0.0,  sugars:5.5,  sodium:78,  potassium:305, calcium:16,  iron:0.8, vitC:4.9, vitD:0),
    "kool bloem rauw":          .init(satFat:0.0,  sugars:2.0,  sodium:30,  potassium:300, calcium:22,  iron:0.4, vitC:46,  vitD:0),
    "kool bloem gekookt":       .init(satFat:0.0,  sugars:1.8,  sodium:15,  potassium:142, calcium:16,  iron:0.4, vitC:21,  vitD:0),
    "kool boeren gekookt":      .init(satFat:0.1,  sugars:0.5,  sodium:43,  potassium:228, calcium:150, iron:1.0, vitC:41,  vitD:0),
    "cantharel rauw":           .init(satFat:0.0,  sugars:0.5,  sodium:3,   potassium:506, calcium:15,  iron:3.5, vitC:0,   vitD:1.1),
    "champignon rauw":          .init(satFat:0.0,  sugars:1.7,  sodium:5,   potassium:318, calcium:3,   iron:0.5, vitC:2.1, vitD:1.9),
    "champignon gekookt":       .init(satFat:0.0,  sugars:0.4,  sodium:9,   potassium:356, calcium:6,   iron:0.6, vitC:0,   vitD:1.0),
    "kool chinese rauw":        .init(satFat:0.0,  sugars:1.4,  sodium:65,  potassium:252, calcium:105, iron:0.3, vitC:45,  vitD:0),
    "doperwten rauw":           .init(satFat:0.1,  sugars:5.7,  sodium:5,   potassium:244, calcium:25,  iron:1.5, vitC:40,  vitD:0),
    "kool groene rauw":         .init(satFat:0.0,  sugars:3.8,  sodium:18,  potassium:200, calcium:35,  iron:0.4, vitC:36,  vitD:0),
    "komkommer z schil rauw":   .init(satFat:0.0,  sugars:1.7,  sodium:2,   potassium:147, calcium:16,  iron:0.3, vitC:2.8, vitD:0),
    "paprika groene rauw":      .init(satFat:0.0,  sugars:2.6,  sodium:3,   potassium:175, calcium:10,  iron:0.4, vitC:80,  vitD:0),
    "paprika groene gekookt":   .init(satFat:0.0,  sugars:2.0,  sodium:3,   potassium:166, calcium:8,   iron:0.4, vitC:51,  vitD:0),
    "peultjes rauw":            .init(satFat:0.0,  sugars:3.0,  sodium:4,   potassium:200, calcium:43,  iron:2.1, vitC:60,  vitD:0),
    "prei gekookt":             .init(satFat:0.0,  sugars:1.5,  sodium:5,   potassium:180, calcium:35,  iron:1.0, vitC:8,   vitD:0),
    "kool rode rauw":           .init(satFat:0.0,  sugars:4.0,  sodium:27,  potassium:243, calcium:57,  iron:0.5, vitC:57,  vitD:0),
    "kool rode gekookt":        .init(satFat:0.0,  sugars:3.2,  sodium:10,  potassium:170, calcium:45,  iron:0.4, vitC:25,  vitD:0),
    "sla krop rauw":            .init(satFat:0.0,  sugars:0.8,  sodium:7,   potassium:238, calcium:36,  iron:1.0, vitC:4,   vitD:0),
    "bonen sperzie rauw":       .init(satFat:0.0,  sugars:2.0,  sodium:6,   potassium:209, calcium:37,  iron:1.0, vitC:12,  vitD:0),
    "spinazie rauw":            .init(satFat:0.1,  sugars:0.4,  sodium:79,  potassium:558, calcium:99,  iron:2.7, vitC:28,  vitD:0),
    "spinazie gekookt":         .init(satFat:0.1,  sugars:0.3,  sodium:70,  potassium:466, calcium:136, iron:3.6, vitC:9,   vitD:0),
    "spruitjes gekookt":        .init(satFat:0.1,  sugars:2.5,  sodium:15,  potassium:388, calcium:42,  iron:1.4, vitC:62,  vitD:0),
    "mais suiker gekookt":      .init(satFat:0.2,  sugars:3.2,  sodium:15,  potassium:270, calcium:3,   iron:0.5, vitC:6,   vitD:0),
    "tomaat gewoon rauw":       .init(satFat:0.0,  sugars:2.9,  sodium:5,   potassium:237, calcium:10,  iron:0.3, vitC:15,  vitD:0),
    "tomaat gewoon gekookt":    .init(satFat:0.0,  sugars:2.9,  sodium:5,   potassium:218, calcium:10,  iron:0.4, vitC:10,  vitD:0),
    "bonen tuin rauw":          .init(satFat:0.0,  sugars:1.0,  sodium:25,  potassium:332, calcium:45,  iron:1.9, vitC:33,  vitD:0),
    "ui rauw":                  .init(satFat:0.0,  sugars:4.2,  sodium:4,   potassium:157, calcium:23,  iron:0.2, vitC:6.4, vitD:0),
    "ui gekookt":               .init(satFat:0.0,  sugars:4.0,  sodium:4,   potassium:125, calcium:18,  iron:0.2, vitC:3,   vitD:0),
    "sla veld rauw":            .init(satFat:0.0,  sugars:0.7,  sodium:4,   potassium:459, calcium:38,  iron:2.2, vitC:38,  vitD:0),
    "witlof rauw":              .init(satFat:0.0,  sugars:1.5,  sodium:2,   potassium:211, calcium:19,  iron:0.4, vitC:2.8, vitD:0),
    "kool witte rauw":          .init(satFat:0.0,  sugars:3.4,  sodium:18,  potassium:246, calcium:47,  iron:0.5, vitC:36,  vitD:0),
    "wortel rauw gem":          .init(satFat:0.0,  sugars:4.7,  sodium:69,  potassium:320, calcium:33,  iron:0.3, vitC:5.9, vitD:0),
    "wortel gekookt gem":       .init(satFat:0.0,  sugars:4.5,  sodium:58,  potassium:235, calcium:30,  iron:0.3, vitC:2.4, vitD:0),
    "kool zuur rauw":           .init(satFat:0.0,  sugars:0.6,  sodium:661, potassium:170, calcium:30,  iron:1.5, vitC:15,  vitD:0),
    "courgette rauw":           .init(satFat:0.0,  sugars:1.7,  sodium:8,   potassium:261, calcium:16,  iron:0.4, vitC:17,  vitD:0),
    "peterselie vers":          .init(satFat:0.1,  sugars:0.9,  sodium:56,  potassium:554, calcium:138, iron:6.2, vitC:133, vitD:0),
    "radijs rauw":              .init(satFat:0.0,  sugars:1.9,  sodium:39,  potassium:233, calcium:25,  iron:0.3, vitC:14.8,vitD:0),
    "tauge rauw":               .init(satFat:0.0,  sugars:1.6,  sodium:6,   potassium:149, calcium:13,  iron:0.5, vitC:8,   vitD:0),
    "koolraap gekookt":         .init(satFat:0.0,  sugars:3.5,  sodium:20,  potassium:230, calcium:46,  iron:0.4, vitC:22,  vitD:0),
    "bonen snij rauw":          .init(satFat:0.0,  sugars:2.0,  sodium:6,   potassium:209, calcium:37,  iron:1.0, vitC:12,  vitD:0),
    "selderij bleek gekookt":   .init(satFat:0.0,  sugars:1.4,  sodium:100, potassium:263, calcium:40,  iron:0.2, vitC:3,   vitD:0),
    "selderij knol gekookt":    .init(satFat:0.0,  sugars:2.0,  sodium:40,  potassium:248, calcium:43,  iron:0.3, vitC:4,   vitD:0),
    "puree tomaten geconcentreerd blik": .init(satFat:0.0, sugars:7.5, sodium:59, potassium:439, calcium:36, iron:2.4, vitC:21, vitD:0),

    // ── Fruits ──────────────────────────────────────────────────────────────
    "appel z schil gem":        .init(satFat:0.0,  sugars:10.1, sodium:1,   potassium:107, calcium:6,   iron:0.1, vitC:6,   vitD:0),
    "aardbeien":                .init(satFat:0.0,  sugars:5.4,  sodium:1,   potassium:153, calcium:16,  iron:0.4, vitC:60,  vitD:0),
    "abrikozen m schil":        .init(satFat:0.0,  sugars:8.0,  sodium:1,   potassium:259, calcium:13,  iron:0.4, vitC:10,  vitD:0),
    "ananas":                   .init(satFat:0.0,  sugars:11.0, sodium:1,   potassium:109, calcium:13,  iron:0.3, vitC:47,  vitD:0),
    "banaan":                   .init(satFat:0.1,  sugars:12.2, sodium:1,   potassium:358, calcium:5,   iron:0.3, vitC:8.7, vitD:0),
    "bessen blauwe":            .init(satFat:0.0,  sugars:9.7,  sodium:1,   potassium:77,  calcium:6,   iron:0.3, vitC:10,  vitD:0),
    "bessen rode":              .init(satFat:0.0,  sugars:4.4,  sodium:1,   potassium:275, calcium:33,  iron:1.0, vitC:41,  vitD:0),
    "bessen zwarte":            .init(satFat:0.0,  sugars:8.1,  sodium:2,   potassium:322, calcium:55,  iron:1.5, vitC:181, vitD:0),
    "bramen":                   .init(satFat:0.0,  sugars:5.1,  sodium:1,   potassium:162, calcium:29,  iron:0.6, vitC:15,  vitD:0),
    "citroen":                  .init(satFat:0.0,  sugars:2.5,  sodium:3,   potassium:138, calcium:26,  iron:0.6, vitC:53,  vitD:0),
    "druiven m schil gem":      .init(satFat:0.0,  sugars:15.5, sodium:2,   potassium:191, calcium:10,  iron:0.4, vitC:10,  vitD:0),
    "frambozen":                .init(satFat:0.0,  sugars:4.4,  sodium:1,   potassium:151, calcium:25,  iron:0.7, vitC:26,  vitD:0),
    "grapefruit":               .init(satFat:0.0,  sugars:6.6,  sodium:0,   potassium:135, calcium:22,  iron:0.1, vitC:38,  vitD:0),
    "kersen zoete":             .init(satFat:0.1,  sugars:11.5, sodium:3,   potassium:222, calcium:13,  iron:0.4, vitC:7,   vitD:0),
    "mandarijn":                .init(satFat:0.0,  sugars:9.5,  sodium:2,   potassium:166, calcium:30,  iron:0.3, vitC:30,  vitD:0),
    "peer z schil":             .init(satFat:0.0,  sugars:10.0, sodium:1,   potassium:116, calcium:9,   iron:0.2, vitC:4,   vitD:0),
    "pruimen m schil":          .init(satFat:0.0,  sugars:9.9,  sodium:1,   potassium:157, calcium:6,   iron:0.2, vitC:9.5, vitD:0),
    "rozijnen gedroogd":        .init(satFat:0.0,  sugars:65.0, sodium:11,  potassium:744, calcium:50,  iron:1.9, vitC:2.3, vitD:0),
    "sinaasappel":              .init(satFat:0.0,  sugars:9.1,  sodium:0,   potassium:181, calcium:40,  iron:0.1, vitC:53,  vitD:0),
    "pruimen gedroogd":         .init(satFat:0.0,  sugars:47.9, sodium:1,   potassium:745, calcium:51,  iron:0.9, vitC:0.6, vitD:0),
    "dadels gedroogd":          .init(satFat:0.0,  sugars:70.5, sodium:1,   potassium:696, calcium:64,  iron:0.9, vitC:0,   vitD:0),
    "abrikozen gedroogd":       .init(satFat:0.0,  sugars:59.0, sodium:10,  potassium:1160,calcium:55,  iron:2.7, vitC:1,   vitD:0),
    "vijgen gedroogd":          .init(satFat:0.1,  sugars:54.1, sodium:10,  potassium:680, calcium:162, iron:2.0, vitC:0,   vitD:0),
    "krenten gedroogd":         .init(satFat:0.0,  sugars:75.0, sodium:6,   potassium:892, calcium:93,  iron:2.3, vitC:0,   vitD:0),

    // ── Proteins ─────────────────────────────────────────────────────────────
    "ei kippen rauw gem":       .init(satFat:3.2,  sugars:0.4,  sodium:142, potassium:147, calcium:56,  iron:1.8, vitC:0,   vitD:1.9),
    "ei kippen gekookt gem":    .init(satFat:3.0,  sugars:0.4,  sodium:124, potassium:126, calcium:50,  iron:1.9, vitC:0,   vitD:1.9),
    "mosselen gekookt":         .init(satFat:0.5,  sugars:0.0,  sodium:300, potassium:268, calcium:68,  iron:4.5, vitC:8,   vitD:4.0),
    "haring pan rauw":          .init(satFat:3.5,  sugars:0.0,  sodium:77,  potassium:360, calcium:55,  iron:1.0, vitC:0,   vitD:4.0),
    "konijn tam rauw":          .init(satFat:1.6,  sugars:0.0,  sodium:47,  potassium:330, calcium:22,  iron:2.0, vitC:0,   vitD:0.2),
    "kip m vel rauw":           .init(satFat:4.5,  sugars:0.0,  sodium:72,  potassium:200, calcium:11,  iron:0.9, vitC:0,   vitD:0.1),
    "schapenvlees  g vet rauw gem": .init(satFat:12.0, sugars:0.0, sodium:72, potassium:290, calcium:14, iron:1.9, vitC:0,  vitD:0.2),
    "haas rauw":                .init(satFat:0.5,  sugars:0.0,  sodium:39,  potassium:337, calcium:20,  iron:3.2, vitC:0,   vitD:0.2),

    // ── Legumes ─────────────────────────────────────────────────────────────
    "bonen witte bruine gedroogd": .init(satFat:0.1, sugars:1.5, sodium:16, potassium:561, calcium:86, iron:4.0, vitC:0,    vitD:0),
    "erwten groene gedroogd":   .init(satFat:0.1,  sugars:2.0,  sodium:8,   potassium:900, calcium:74,  iron:5.0, vitC:1,   vitD:0),
    "linzen groene en bruine gedroogd": .init(satFat:0.2, sugars:2.0, sodium:6, potassium:677, calcium:56, iron:7.5, vitC:4.0, vitD:0),
    "kapucijners gedroogd":     .init(satFat:0.1,  sugars:1.5,  sodium:10,  potassium:870, calcium:72,  iron:5.3, vitC:0,   vitD:0),
    "kapucijners blik glas":    .init(satFat:0.1,  sugars:1.0,  sodium:240, potassium:291, calcium:49,  iron:2.4, vitC:0,   vitD:0),
    "olijven groen in water blik glas": .init(satFat:1.5, sugars:0.0, sodium:1556, potassium:42, calcium:52, iron:0.5, vitC:0, vitD:0),

    // ── Grains & Starch ──────────────────────────────────────────────────────
    "pasta witte rauw":         .init(satFat:0.3,  sugars:1.4,  sodium:6,   potassium:220, calcium:21,  iron:1.2, vitC:0,   vitD:0),
    "rijst witte rauw":         .init(satFat:0.2,  sugars:0.1,  sodium:1,   potassium:76,  calcium:28,  iron:0.8, vitC:0,   vitD:0),
    "bloem tarwe":              .init(satFat:0.2,  sugars:1.5,  sodium:2,   potassium:107, calcium:17,  iron:1.2, vitC:0,   vitD:0),
    "meel tarwe volkoren":      .init(satFat:0.3,  sugars:1.5,  sodium:2,   potassium:340, calcium:34,  iron:3.7, vitC:0,   vitD:0),
    "vlokken haver":            .init(satFat:1.1,  sugars:1.0,  sodium:2,   potassium:362, calcium:54,  iron:4.7, vitC:0,   vitD:0),
    "gort parel rauw":          .init(satFat:0.4,  sugars:0.8,  sodium:3,   potassium:280, calcium:33,  iron:2.5, vitC:0,   vitD:0),
    "chips gem":                .init(satFat:3.1,  sugars:0.5,  sodium:530, potassium:1200,calcium:26,  iron:1.9, vitC:22,  vitD:0),
    "beschuit naturel":         .init(satFat:0.7,  sugars:4.0,  sodium:490, potassium:200, calcium:80,  iron:2.5, vitC:0,   vitD:0),
    "tarwebrood bruin":         .init(satFat:0.3,  sugars:2.0,  sodium:450, potassium:198, calcium:60,  iron:2.5, vitC:0,   vitD:0),
    "tarwebrood wit water":     .init(satFat:0.3,  sugars:2.2,  sodium:480, potassium:110, calcium:140, iron:1.5, vitC:0,   vitD:0),
    "tarwebrood volkoren gem v fijn en grof": .init(satFat:0.4, sugars:2.0, sodium:420, potassium:230, calcium:40, iron:2.5, vitC:0, vitD:0),
    "roggebrood volkoren":      .init(satFat:0.2,  sugars:2.5,  sodium:410, potassium:230, calcium:37,  iron:2.0, vitC:0,   vitD:0),
    "bloem rijste":             .init(satFat:0.1,  sugars:0.1,  sodium:1,   potassium:76,  calcium:10,  iron:0.4, vitC:0,   vitD:0),
    "maizena":                  .init(satFat:0.1,  sugars:0.2,  sodium:5,   potassium:3,   calcium:2,   iron:0.3, vitC:0,   vitD:0),

    // ── Nuts & Seeds ─────────────────────────────────────────────────────────
    "noten amandelen z vliesje ongezouten": .init(satFat:4.3, sugars:4.5, sodium:1, potassium:705, calcium:264, iron:3.7, vitC:0, vitD:0),
    "noten cashew ongezouten":  .init(satFat:9.2,  sugars:5.4,  sodium:12,  potassium:660, calcium:37,  iron:6.7, vitC:0,   vitD:0),
    "noten hazel ongezouten":   .init(satFat:4.6,  sugars:4.3,  sodium:0,   potassium:680, calcium:114, iron:4.7, vitC:6,   vitD:0),
    "noten para ongezouten":    .init(satFat:15.1, sugars:2.3,  sodium:3,   potassium:659, calcium:160, iron:2.4, vitC:0,   vitD:0),
    "pinda's ongezouten":       .init(satFat:7.0,  sugars:3.6,  sodium:18,  potassium:705, calcium:92,  iron:4.6, vitC:0,   vitD:0),
    "noten wal ongezouten":     .init(satFat:5.6,  sugars:2.6,  sodium:2,   potassium:441, calcium:98,  iron:2.9, vitC:1.3, vitD:0),
    "noten gemengd ongezouten": .init(satFat:7.0,  sugars:3.0,  sodium:10,  potassium:550, calcium:100, iron:3.5, vitC:1,   vitD:0),
    "kastanje rauw":            .init(satFat:0.5,  sugars:10.6, sodium:3,   potassium:518, calcium:29,  iron:1.0, vitC:40,  vitD:0),
    "kokosnootvlees":           .init(satFat:35.0, sugars:6.2,  sodium:20,  potassium:356, calcium:14,  iron:2.4, vitC:3.3, vitD:0),

    // ── Dairy (selected entries from NEVO) ───────────────────────────────────
    "melk rauwe":               .init(satFat:2.8,  sugars:4.4,  sodium:44,  potassium:152, calcium:119, iron:0.0, vitC:1.5, vitD:0.04),

    // ── Other ────────────────────────────────────────────────────────────────
    "augurk zuur":              .init(satFat:0.0,  sugars:0.9,  sodium:936, potassium:140, calcium:17,  iron:0.4, vitC:0,   vitD:0),
    "studentenhaver":           .init(satFat:3.5,  sugars:20.0, sodium:52,  potassium:430, calcium:55,  iron:2.5, vitC:1,   vitD:0),
]
