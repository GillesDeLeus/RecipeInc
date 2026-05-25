import Foundation

struct NevoEntry {
    let name: String
    let aliases: [String]
    let kcal: Double
    let protein: Double
    let fat: Double
    let carbs: Double
    let fiber: Double
}

// NEVO 2025 v9.0 — Dutch national food composition database (RIVM)
// Values per 100 g. Parsed lazily from embedded compact data.
let nevoDatabase: [NevoEntry] = {
    let raw = """
    Aardappelen rauw|Potatoes raw||88|2|0|19|1.8
    Aardappelen nieuwe rauw|Potatoes new raw||88|2|0|19|1.8
    Aardappelen oude rauw|Potatoes old raw||88|2|0|19|1.8
    Pasta witte rauw|Pasta white raw|Macaroni/spaghetti/tagliatelle/noedels/mie/vermicelli witte onbereid|356|12.3|1.5|72|3
    Rijst witte rauw|Rice white raw|Witte rijst onbereid|352|7|1|78|1.3
    Andijvie rauw|Endive raw||16|1.5|0.3|1|1.7
    Andijvie gekookt|Endive boiled||22|1.4|0.5|2.3|1.7
    Asperge witte rauw|Asparagus white raw||22|1|0.3|3|1.7
    Aubergine rauw|Aubergine/eggplant raw||20|1|0|3|2
    Aubergine gekookt|Aubergine/eggplant boiled||21|1|0|3|2.5
    Biet rode rauw|Beetroot raw|Rode bieten rauw/Kroten rauw|38|1.7|0.1|6|2.9
    Selderij bleek- gekookt|Celery boiled|Bleekselderij gekookt|14|1|0|2|1.1
    Kool bloem- rauw|Cauliflower raw|Bloemkool rauw|25|1.9|0.2|3|2.2
    Kool bloem- gekookt|Cauliflower boiled|Bloemkool gekookt|22|1.8|0.4|1.8|2.3
    Kool boeren- gekookt|Kale curly boiled|Boerenkool gekookt|33|2.7|1.3|1|3.5
    Cantharel rauw|Mushrooms chanterelle raw||16|1.8|0|1|2.5
    Cantharel gekookt|Mushrooms chanterelle boiled||20|1.8|0|2|2.5
    Champignon rauw|Mushroom raw||18|2.3|0.5|0.4|1.5
    Champignon gekookt|Mushroom boiled||21|3.8|0.3|0.4|1.1
    Kool Chinese rauw|Cabbage Chinese raw||17|1|0|2|2.5
    Kool Chinese gekookt|Cabbage Chinese boiled||17|1|0|2|2.5
    Doperwten rauw|Peas raw||65|4|0|10|4.7
    Kool groene rauw|Cabbage green raw|Kool savooie rauw|36|2.4|0.2|4.1|4.1
    Kool groene gekookt|Cabbage green boiled|Kool savooie gekookt|21|1.5|0.2|2.3|2.2
    Selderij knol- gekookt|Celeriac boiled|Knolselderij gekookt|38|2|0|5|4.9
    Komkommer z schil rauw|Cucumber wo skin raw||15|0.6|0.2|2.5|0.3
    Komkommer gekookt|Cucumber boiled||17|1|0|3|0.3
    Koolraap gekookt|Swede boiled||33|0.7|0.1|5.8|3
    Koolrabi gekookt|Kohlrabi boiled||31|2|0.3|4|2
    Paprika groene rauw|Sweet pepper green raw|Paprika groen rauw|19|0.8|0.1|2.5|2.5
    Paprika groene gekookt|Sweet pepper green boiled|Paprika groen gekookt|17|0.6|0.2|2.3|2.2
    Rozijnen gedroogd|Raisins dried||325|3.1|0.5|71.7|3.7
    Peultjes rauw|Mange-tout raw||33|2|0|5|2.5
    Postelein gekookt|Purslane boiled||13|1|0|1|2.5
    Prei gekookt|Leek boiled||22|1.1|0.5|2.1|2.3
    Raapstelen rauw|Turnip tops raw||17|2|0|1|2.3
    Raapstelen gekookt|Turnip tops boiled||17|2|0|1|2.3
    Rabarber rauw|Rhubarb raw||23|1|0|2|1.8
    Kool rode rauw|Cabbage red raw||27|2|0|3|3.6
    Kool rode gekookt|Cabbage red boiled||23|1.3|0|3|2.9
    Schorseneren rauw|Salsify raw||76|1|1|15|1.7
    Sla krop- rauw|Lettuce butterhead raw|Kropsla/botersla rauw|13|1.4|0.4|0.3|1.2
    Sla krop- gekookt|Lettuce butterhead boiled|Kropsla/botersla gekookt|22|2|0.4|2|1.2
    Snijbiet gekookt|Swiss chard leaf boiled||29|3|0|3|2.5
    Bonen snij- rauw|Beans runner raw|Snijbonen rauw|22|1.9|0.1|2|2.7
    Bonen sperzie- rauw|Beans French raw|Sperziebonen/haricots verts rauw|25|2.3|0.2|1.8|3.6
    Spinazie rauw|Spinach raw||26|3.2|0.6|0.9|2
    Spinazie gekookt|Spinach boiled||25|2.9|0.9|0.7|1.4
    Kool spits- rauw|Cabbage oxheart raw|Spitskool rauw|42|3|1|4|2.5
    Kool spits- gekookt|Cabbage oxheart boiled|Spitskool gekookt|21|1.1|0.6|1.6|2.5
    Spruitjes gekookt|Brussel sprouts boiled||47|2.3|0.7|5.6|4.5
    Mais suiker- gekookt|Sweetcorn boiled|Suikermais gekookt|74|2.5|1.4|11.6|2.5
    Tauge rauw|Bean sprouts raw||25|2.2|0.1|3.2|1.2
    Tauge gekookt|Bean sprouts boiled||17|1.8|0.1|1.7|1.2
    Tomaat gewoon rauw|Tomatoes classic round raw|Tomaten gewoon rauw|20|0.7|0.4|2.9|1.3
    Tomaat gewoon gekookt|Tomatoes classic round boiled|Tomaten gewoon gekookt|23|0.7|0.7|2.9|1.3
    Bonen tuin- rauw|Beans broad raw|Tuinbonen rauw|51|5|0|4|7.3
    Ui rauw|Onions raw|Uien rauw|37|1.3|0.2|6.3|2.7
    Ui gekookt|Onions boiled|Uien gekookt|35|1|0.2|6.3|2.2
    Sla veld- rauw|Lettuce lambs raw|Veldsla rauw|18|2.6|0.2|0.5|1.7
    Witlof rauw|Chicory raw|Brussels lof rauw|19|1.3|0.2|2.4|1.2
    Witlof gekookt|Chicory boiled|Brussels lof gekookt|16|1.2|0.2|2|1.1
    Kool witte rauw|Cabbage white raw||30|2|0|4|2.8
    Kool witte gekookt|Cabbage white cooked||16|0.9|0|1.8|2.8
    Wortel rauw gem|Carrot raw av||32|0.8|0.3|5.3|2.8
    Wortel gekookt gem|Carrot boiled av||32|0.7|0.3|5.2|2.9
    Kool zuur- rauw|Cabbage sauerkraut raw|Zuurkool rauw|13|1.1|0|0.6|3.2
    Kool zuur- gekookt|Cabbage sauerkraut cooked|Zuurkool gekookt|14|0.9|0|1|3.2
    Groente soep- rauw|Vegetable mix for soup raw|Soepgroente rauw|32|1.5|0.2|4.6|3.2
    Bloem rijste-|Flour rice|Rijstebloem|369|6.2|0.5|83.9|2
    Ei kippen- rauw gem|Egg whole chicken av raw|Kippeneieren rauw|132|12.3|9.1|0.2|0
    Ei kippen- gekookt gem|Egg whole chicken av boiled|Kippeneieren gekookt|128|12.3|8.8|0|0
    Eidooier kippen- rauw|Egg yolk chicken raw|Kippeneidooier rauw|361|16.7|32.6|0.2|0
    Eidooier kippen- gekookt|Egg yolk chicken boiled|Kippeneidooier gekookt|361|16|33|0|0
    Eipoeder kippen-|Egg powder chicken|Kippeneipoeder|574|46|42|3|0
    Paardenvlees rauw|Horse meat raw||99|22.4|1|0|0
    Schapenvlees >10 g vet rauw gem|Mutton >10g fat raw av||293|17|25|0|0
    Kalfshersenen rauw|Brains calf's raw||108|9|8|0|0
    Eend m vel rauw|Duck w skin raw||388|13.1|37.3|0|0
    Haas rauw|Hare whole raw||115|22|3|0|0
    Kip m vel rauw|Chicken w skin raw||218|18.3|16|0|0
    Konijn tam rauw|Rabbit domesticated raw||174|21|10|0|0
    Konijn wild rauw|Rabbit wild raw||125|20|5|0|0
    Mosselen gekookt|Mussels boiled||125|17.2|3.1|7.2|0
    Paling rauw|Eel raw||372|14|35.1|0|0
    Haring pan- rauw|Herring raw|Panharing rauw|199|16|15|0|0
    Vis mager 0-5 g vet gem rauw|Fish lean 0-5 g fat raw av||92|19.7|1.5|0|0
    Vis vet >5 g vet gem rauw|Fish fat >5 g fat raw av||242|17.2|19.1|0.3|0
    Bonen witte/bruine gedroogd|Beans white/ brown dried|Bruine bonen/ witte bonen gedroogd|314|20.1|2.4|44.2|18.1
    Erwten groene gedroogd|Peas green dried||315|21|2|43|20.4
    Kapucijners gedroogd|Peas marrowfat dried||305|20|1.5|43|19.9
    Linzen groene en bruine gedroogd|Lentils green and brown dried||306|21|1.5|43|18
    Aardappelpuree vers bereid m halfvolle melk en margarine|Potatoes mashed fresh prep w semi-skimmed milk and margarin||83|2.2|1.8|13.9|1.2
    Chips gem|Crisps potato av||538|6.3|32.8|52.3|4
    Radijs rauw|Radish raw||22|1|0|4|0.9
    Rammenas rauw|Radish black raw||30|2|0|5|1
    Sterkers rauw|Cress garden raw|Tuinkers rauw|15|2|0|0|3.3
    Rauwkost gem|Vegetables mixture raw av||20|0.9|0.4|2.5|1.3
    Peterselie vers|Parsley fresh||37|4|0.8|1|5
    Asperge witte blik/glas|Asparagus white tinned||17|1.4|0.3|1.9|1.2
    Augurk zuur|Gherkins sour pickled|Zure bom|10|1|0|1|0.9
    Augurk zoetzuur|Gherkins sweet pickled||27|0.8|0|5.3|0.9
    Champignon blik/glas|Mushroom tinned||19|2.2|0.4|0.5|2.3
    Doperwten middelfijn blik/glas|Peas medium fine tinned||94|5|1|14|4.5
    Doperwten zeer fijn/extra fijn blik/glas|Peas super fine tinned||78|5.6|0.8|9.9|4.5
    Doperwten m wortelen blik/glas|Peas and carrots tinned||56|3.4|0.5|7|4.8
    Olijven groen in water blik/glas|Olives green in brine tinned/glass|Groene olijven|113|0.9|11|0.5|4
    Bonen snij- blik/glas|Beans runner tinned|Snijbonen blik/glas|20|1.1|0.3|2.3|2.1
    Bonen sperzie- blik/glas|Beans French tinned|Sperziebonen/haricots verts blik/glas|26|1.6|0.3|2.9|2.6
    Spinazie blik/glas|Spinach tinned||31|3.2|0.9|1.3|3
    Puree tomaten- geconcentreerd blik|Tomato puree concentrated tinned|Tomatenpuree geconcentreerd|87|4.5|0|15.5|3.7
    Bonen tuin- blik/glas|Beans broad tinned|Tuinbonen blik/glas|73|5.8|0.6|8.5|5.3
    Wortel blik/glas|Carrot tinned||29|0.7|0.2|5.3|1.8
    Ui zilver- zoetzuur glas|Silver-skin onion sweet pickled glass|Zilveruitjes zoetzuur glas|34|0.6|0.1|6.9|1.4
    Kool rode blik/glas|Cabbage red glass||40|0.8|0.2|7.9|2
    Spinazie diepvries gekookt|Spinach frozen boiled||24|2.3|0.4|1.7|2.4
    Appel z schil gem|Apple wo skin av||55|0.2|0.1|12|1.6
    Aardbeien|Strawberries||29|0.7|0|5.1|1.1
    Abrikozen m schil|Apricots w skin||44|0.9|0.1|8|1.7
    Ananas|Pineapple||54|0.5|0.1|12|1.6
    Banaan|Banana|Bananen|92|1.1|0.3|20|1.9
    Bessen blauwe|Blueberries|Blauwe bessen|52|0.7|0|11|2.4
    Bessen rode|Redcurrants|Aalbessen|36|1.1|0|4.4|3.4
    Bessen zwarte|Blackcurrants|Zwarte bessen|53|0.9|0|8|3.6
    Bessen bos-|Bilberries|Bosbessen|30|0.6|0|6|1.8
    Bessen vossen-|Cowberries|Vossenbessen/rode bosbessen|57|0.8|1.2|8.8|3.7
    Bramen|Blackberries|Braam|37|0.9|0.2|5.1|3.1
    Citroen|Lemon||36|0.8|0.3|3|2
    Cranberry vers|Cranberries fresh|Veenbessen vers/cranberries vers|24|0.4|0.1|3.4|3.6
    Druiven m schil gem|Grapes w skin av|Druif m schil gem|78|0.6|0.2|16.8|1.8
    Frambozen|Raspberries|Framboos|37|1.4|0.3|4.5|2.5
    Grapefruit|Grapefruit||37|0.9|0|6.6|1.4
    Kersen zoete|Cherries sweet||57|0.9|0.4|11.5|0.9
    Bessen kruis-|Gooseberries|Kruisbessen|49|0.9|0|9|2.4
    Mandarijn|Manderins||46|0.7|0.1|9.9|0.9
    Meloen net-|Melon netted|Galiameloen/netmeloen|27|0.5|0|6|0.4
    Kersen zure|Cherries sour|Morellen/krieken|52|1|0|11|2.1
    Peer z schil|Pear wo skin|Peren z schil|53|0.3|0.2|11.7|1.6
    Perzik z schil|Peach wo skin||41|1|0|7.9|1.4
    Pruimen m schil|Plums w skin|Pruim m schil|40|0.8|0|7.3|2.2
    Sinaasappel|Orange||48|0.8|1|7.9|2
    Fruit vers citrus- gem|Fruit fresh citrus av|Citrusfruit gemiddeld|48|0.8|0.5|8.9|1.4
    Fruit vers excl citrus- gem|Fruit fresh av excl citrus||63|0.7|0.2|13.5|1.8
    Aardbeien op siroop blik/glas|Strawberries in syrup tinned||71|0.5|0|16.9|0.9
    Abrikozen gedroogd|Apricots dried||285|5|0|59|14.4
    Abrikozen op siroop blik/glas|Apricots in syrup tinned||69|0.4|0.1|16.1|1.2
    Ananas op siroop blik/glas|Pineapple in syrup tinned||69|0.3|0.1|16.1|1
    Appeltjes gedroogd|Apples dried||292|2|0.5|65|9.6
    Appelmoes blik/glas|Apple sauce tinned|Appelcompote blik/glas|76|0.2|0.1|17.6|1.9
    Bessen bos- op siroop blik/glas|Bilberries in syrup tinned|Bosbessen op siroop|66|0.3|0.3|15.1|1
    Dadels gedroogd|Dates dried|Gedroogde dadels|305|2|0|70.5|7.5
    Frambozen op siroop blik/glas|Raspberries in syrup tinned|Framboos op siroop blik/glas|71|0.5|0.3|15.7|1.5
    Fruitcocktail op siroop blik/glas|Fruit cocktail in syrup tinned||75|0.4|0|17.3|2
    Kersen op siroop blik/glas|Cherries in syrup tinned||63|0.6|0.3|14.2|0.5
    Krenten gedroogd|Currants dried||326|2|0|75|9
    Mandarijnen op siroop blik/glas|Tangerines in syrup tinned||59|0.5|0|14|0.3
    Peren gedroogd|Pear dried|Peer gedroogd|287|2|0|65|9.6
    Peren op siroop blik/glas|Pears in syrup tinned|Peer op siroop blik/glas|64|0.3|0|14.7|2
    Perziken op siroop blik/glas|Peaches in syrup tinned||62|0.4|0|14.6|1
    Pruimen gedroogd|Prunes|Pruim gedroogd|199|1.6|0.4|47.9|5.1
    Pruimen op siroop blik/glas|Plums in syrup tinned|Pruim op siroop blik/glas|65|0.3|0|15.5|1
    Tuttifrutti gedroogd|Fruit mixed dried||256|2.7|0.3|56.1|9
    Vijgen gedroogd|Figs dried||259|3.3|0.9|54.1|9.8
    Vruchten op siroop gem blik/glas|Fruit in syrup tinned||65|0.3|0.1|15|1.5
    Babyvoeding fruit 8 mnd|Infant food fruit 8 months|Olvarit e.d. fruithapje/moes/puree 8 mnd|74|0.6|0.1|17.1|1.2
    Kapucijners blik/glas|Peas marrowfat canned||108|7.1|0.8|14.8|6.5
    Bonen witte in tomatensaus blik/glas|Beans white baked in tomato sauce canned|Witte bonen in tomatensaus|101|5.7|0.6|15.2|6.1
    Noten amandelen z vliesje ongezouten|Almonds blanched unsalted|Amandelschaafsel|631|21.7|55.8|7.1|7
    Noten cashew- ongezouten|Cashew nuts unsalted|Cashewnoten ongezouten|615|21.2|48.9|20.8|3.8
    Noten hazel- ongezouten|Hazelnuts unsalted|Hazelnoten ongezouten|670|16.4|63|4.8|9
    Kastanje rauw|Chestnuts raw||189|4|2.7|35|4.1
    Kokosnootvlees|Coconut meat|Cocosnoot/Klapper|406|4|40|3|9
    Noten para- ongezouten|Brazil nuts unsalted|Paranoten ongezouten|687|14.3|67.1|2.6|7.5
    Pinda's ongezouten|Peanuts unsalted|Aardnoten ongezouten|627|25.2|51.7|11.8|6.8
    Studentenhaver|Mixed nuts and raisins|Gemengde noten met rozijnen|496|11|32.1|38|5.6
    Noten wal- ongezouten|Walnuts unsalted|Walnoten ongezouten|706|15.9|68.1|5.1|4.6
    Noten gemengd ongezouten|Nuts mixed unsalted||658|18.1|59.6|8.9|6.7
    Meel boekweit-|Flour buckwheat|Boekweitmeel|344|12.8|2.8|64.5|4.7
    Ontbijtproduct Cornflakes Kellogg's|Breakfast cereal Cornflakes Kellogg's|Ontbijtgranen cornflakes Kellogg's|378|7|0.9|84|3
    Custardpoeder|Custard powder||352|0.4|0.7|86|0
    Gort parel- rauw|Barley pearl raw|Parelgort/parelgerst onbereid|335|9.1|2|63.5|13.4
    Vlokken haver-|Oat flakes|Havermout/Mout haver-/Havervlokken|366|12.8|6.2|59.2|11.1
    Maizena|Corn starch|Maiszetmeel|354|0.3|0.4|86.9|0.8
    Puddingpoeder voor kookpudding|Blancmange powder to cook pudding||374|0.2|0.1|93|0.4
    Bloem rogge-|Flour rye|Roggebloem|332|5.8|1.2|69|11
    Meel rogge-|Flour rye wholemeal|Roggemeel|314|9.1|1.5|56.6|19
    Tapioca parels droog|Tapioca pearls dry||354|0.2|0|87.8|0.9
    Bloem tarwe-|Flour wheat white|Tarwebloem/patentbloem|345|10.2|1.2|71.3|4.2
    Meel tarwe- volkoren|Flour wheat wholemeal|Volkorenmeel tarwe-/Volkoren tarwemeel|344|11.6|1.7|65.3|10.4
    Bindmiddel gem|Binding agents av||344|9.8|1.1|71.7|4
    Ontbijtproduct Olvarit pap fijne granen 6+ mnd|Breakfast cereal porridge Olvarit fijne granen 6+ months|Ontbijtgranen Olvarit pap fijne granen 6+ mnd|367|12.4|2.1|69.6|10
    Volkoren graanontbijt|Breakfast cereal whole grain for porridge|Ontbijtgranen Brinta/Ontbijtproduct Brinta|349|14|1.9|64|10
    Aardappelzetmeel|Potato starch|Zetmeel aardappel-|327|0.3|0.2|81.1|0
    Beschuit naturel|Crispbakes Dutch white||408|14.1|4.7|76.1|2.8
    Cracker cream-|Crackers cream|Creamcracker|448|9.1|14.5|68.8|3
    Knackebrod gem|Crispbread av|Cracker knackebrod gem|376|11.6|5.6|63.6|12.7
    Tarwebroodje wit zacht|Wheat bread roll white soft|Puntje/kadetje/bolletje/zacht broodje wit|262|9.7|3.5|46.1|3.7
    Kiemen tarwe-|Wheat germ|Tarwekiemen|346|29.2|9.5|27.8|16.3
    Broodje koffie-|Danish pastry|Koffiebroodje|349|5.8|14.1|48.4|2.7
    Tarwekrentenbrood wit|Wheat currant bread white|Krentenbrood wit|273|7.8|2.4|53.3|3.3
    Biscuit baby- Liga Baby 6-12 mnd|Biscuit Liga Baby 6-12 months||394|6.5|7.6|73.5|2.9
    Biscuit dreumes- Liga Kind 12-36 mnd|Biscuit Liga 12-36 months||411|8.5|9.4|71|4.2
    Tarwebrood bruin|Wheat bread brown|Bruinbrood|239|9.9|1.8|43.3|4.9
    Cracker Matzes|Crackers Matzes|Teacracker matzes|376|11|1|78.8|4
    Koek ontbijt-|Cake Dutch spiced Ontbijtkoek|Ontbijtkoek/Peperkoek/Snijkoek|308|3|1.2|69.5|3.6
    Tarwebrood wit melk|Wheat bread white milk based|Witbrood melk/Melkbrood wit|257|9.6|2.4|47.9|2.6
    Roggebrood volkoren|Rye bread wholemeal|Donker/fries roggebrood|193|5.6|1.3|35.6|8.3
    Roggetarwebrood bruin|Rye wheat bread brown|Licht/brabants/limburgs roggebrood|233|8.2|1.5|42.8|7.7
    Tarwerozijnenbrood wit|Wheat raisin bread white|Rozijnenbrood wit|272|7.7|2.7|52.2|4
    Tarwebrood volkoren gem v fijn en grof|Wheat bread wholemeal av fine and coarse|Volkorenbrood gem v fijn en grof|235|11.1|2.3|39|6.7
    Tarwebrood wit water|Wheat bread white water based|Witbrood water|248|9|1.6|48.1|2.6
    Tarwemoutbrood bruin|Wheat malt bread brown|Moutbrood bruin Tarvo|249|9.4|1.9|46.6|4
    Broodje amandel- (v bladerdeeg)|Puff pastry filled w almond paste|Amandelbroodje|393|6.9|23|38.6|2
    Taart appel- v zandtaartdeeg z roomboter|Apple pie Dutch w shortbread wo butter|Appeltaart z roomboter/Appelgebak z roomboter|226|3.4|9|31.9|1.6
    Biscuit|Biscuit|Mariakoekje/kaakje|437|7.6|11|75.5|2.5
    Cake z roomboter|Cake wo butter||397|5.6|22.3|42.8|1
    Koek eier-|Cake sponge Dutch Eierkoek|Eierkoek|307|5.9|1.4|66.8|1.6
    Taart slagroom-|Gateau w whipped cream|Slagroomtaart/slagroomgebak|316|4.6|18.9|31.4|0.8
    Taart creme au beurre-|Gateau w butter-cream filling|Mokkataart/Mokkagebak|431|3.6|26.6|44|0.4
    Koek gevulde gem|Almond paste filled tarts av|Pencee/kano/rondo/gevuld heertje|411|6.4|15.8|59.9|2
    Koekje gem|Biscuit av||475|5.7|20.7|65.2|2.6
    Kokosmakronen|Coconut macaroons||455|4|21.2|59|5.9
    Lange vingers|Biscuit sponge fingers||402|7.2|3.5|84.8|1
    Speculaas gem|Biscuit spiced Speculaas av||469|5|20.3|65.1|3
    Sprits m roomboter|Biscuit Dutch shortbread sprits||493|4.8|29.8|50.5|1.7
    Biscuit tarwe-/volkoren-|Biscuit brown/wholemeal|Volkorenbiscuit/tarwebiscuit|459|7.8|14.9|70.7|5.5
    Biscuit zoute|Biscuit salted|Tuc e.d. zout koekje|472|8.1|23|56.7|2.6
    Bladerdeeg z roomboter, bereid|Puff pastry wo butter baked||499|7.9|31|46.3|1.8
    Broodje saucijzen-|Snack sausage roll puff pastry|Saucijzenbroodje bladerdeegbasis|356|7.2|23.4|28.5|1.4
    Pepsels|Pretzel sticks|Zoute sticks/stokjes|382|11.9|5.3|69.5|4.2
    Kroepoek naturel|Prawn crackers natural||516|3.5|28|62|1
    Melk rauwe|Milk raw||71|3.4|4.4|4.4|0
    Melk koffie- Becel|Coffee creamer Becel|Koffiemelk Becel|112|7.1|4.4|11|0
    Melk chocolade- volle|Milk chocolate-flavoured full fat|Chocolademelk volle|82|3.3|2.8|10.7|0.5
    Melk chocolade- magere|Milk chocolate-flavoured low fat|Chocolademelk magere|62|3.3|0.3|11.4|0.5
    Creamer koffie-|Coffee creamer powder|Koffiecreamer/koffiemelkpoeder Completa e.d.|560|2.1|35.3|58.4|0
    Vla chocolade- volle|Custard chocolate full fat|Chocoladevla volle|88|2.4|2.6|13.4|0.8
    Yoghurt volle|Yoghurt full fat||56|3.8|2.7|3.4|0
    Melk volle|Milk whole||61|3.3|3.4|4.5|0
    Melk koffie- volle|Coffee creamer full fat|Koffiemelk volle|145|7.5|7.7|11.4|0
    Melk gecondenseerde m suiker|Milk condensed w sugar|Gecondenseerde melk met suiker|330|8.1|8.8|54.7|0
    Vla vanille- volle|Custard vanilla full fat|Vanillevla volle|86|2.3|2.8|12.8|0.4
    Yoghurt vruchten- magere|Yoghurt low fat w fruit|Vruchtenyoghurt mager|67|3|0.2|12.4|0.6
    Melk koffie- halfvolle|Coffee creamer half fat|Koffiemelk halfvolle Halvamel e.d.|110|7|4.1|11.2|0
    Melk halfvolle|Milk semi-skimmed||45|3.4|1.4|4.7|0
    Pap havermout- bereid m volle melk ongezoet|Porridge oatmeal prepared w whole milk unsweetened|Havermoutpap bereid m volle melk ongezoet|94|4.3|3.7|10.3|1.2
    Melk karne-|Buttermilk|Karnemelk|30|3|0.2|3.6|0
    Pap karnemelkse bloem-|Porridge buttermilk w wheat flour white|Karnemelkse bloempap|52|3.7|0.5|7.8|0.1
    Topping m suiker poeder Klop-Klop|Topping dessert powder w sugar Klop-Klop||535|4.4|29.3|63.4|0
    Melk koffie- magere|Coffee creamer low fat|Koffiemelk magere|57|9.9|0|4.3|0
    Room koffie-|Coffee creamer|Koffieroom|210|3.3|20.2|3.8|0
    Melk magere|Milk skimmed||35|3.7|0.1|4.9|0
    Melkpoeder magere|Milk skimmed dried||349|35.4|0.6|50.5|0
    Melkpoeder volle|Milk whole dried||478|23.9|26|37|0
    Melk moeder-|Milk human|Moedermelk/borstvoeding|66|1.1|3.5|7.4|0
    Pap rijste-|Porridge rice|Rijstepap|86|3.1|2.9|12|0.1
    Room slag- onbereid|Cream whipping unprepared|Slagroom onbereid|339|2.3|35.3|3.1|0
    Yoghurt Bulgaarse volle|Yoghurt Bulgarian whole milk||77|4.5|4.3|4.5|0
    Yoghurt magere|Yoghurt low fat||37|4.1|0.2|4|0
    IJs room/vanille- gem|Ice cream dairy av|Roomijs/vanilleijs|216|2.9|11.3|25.3|0.5
    Kaas strooi- Zwitserse|Cheese Swiss dried|Zwitserse strooikaas|228|55|0.7|0|0
    Kwark magere|Quark low fat||51|8.4|0|3.8|0
    Kwark halfvolle|Quark half fat||77|7.5|3.2|4|0
    Kwark volle|Quark full fat||118|7.5|8|3.6|0
    Olie arachide-|Oil peanut|Arachideolie|900|0|100|0|0
    Boter ongezouten|Butter unsalted|Roomboter ongezouten|737|0.7|81.2|1.1|0
    Olie soja-|Oil soya|Sojaolie|894|0.3|99.2|0|0
    Vet varkens- uitgesmolten|Lard|Reuzel uitgesmolten/Varkensvet uitgesmolten|900|0|100|0|0
    Vet rund- uitgesmolten|Beef fat|Rundvet uitgesmolten/Rundervet uitgesmolten|891|0|99|0|0
    Olie zonnebloem-|Oil sunflower seed|Zonnebloemolie|897|0.3|99.5|0|0
    Cornedbeef|Corned beef||208|24.3|11.9|0.9|0
    Fazant rauw|Pheasant whole raw||223|31|11|0|0
    Frikandel bereid m vloeibaar frituurvet|Sausage Dutch Frikandel deep-fried in liquid fat|Frikandel snackbar/Frikandel gefrituurd|251|13.8|18.4|6.7|1.8
    Worst rook- gekookt gem|Sausage smoked cooked av|Rookworst gekookt gem|304|14.1|26.3|2.6|0.5
    Kroket vlees- bereid m vloeibaar frituurvet|Croquette meat ragout deep-fried in liquid fat|Kroket snackbar/Kroket gefrituurd|272|8.9|16.6|20.9|1.9
    Ham rauwe|Ham smoked raw||188|24.6|9.5|1.2|0
    Kalkoen rauw|Turkey raw||141|21.8|6|0|0
    Lever runder- gekookt (vleeswaar)|Liver ox boiled (processed meat product)|Runderlever gekookt (vleeswaar)|133|20|5|2|0
    Lever varkens- gekookt (vleeswaar)|Liver pork boiled (processed meat product)|Varkenslever gekookt (vleeswaar)|132|19.8|4.1|3.9|0
    Pastei lever-|Liver pate|Leverpastei|318|14.2|28.3|1.7|0
    Luncheon meat blik|Luncheon meat tinned|Smac e.d. worst blik|279|12.9|23.8|3.3|0.2
    Patrijs rauw|Partridge raw||248|35|12|0|0
    Pekelvlees|Beef salted cooked||184|17.3|12.7|0.1|0
    Ree wild rauw|Venison raw||122|22.4|3.6|0|0
    Runderrookvlees|Beef smoke-dried||108|22|2|0.5|0
    Spek rook- vet rauw|Bacon fat smoked raw|Spekblokjes vet rauw|678|5|73.2|0|0
    Vleeswaren gem|Processed meat products av||239|16.6|17.9|2.7|0.2
    Bokking gerookt|Kipper smoked|Koud gerookte haring|242|20.8|17.5|0.3|0
    Garnalen Hollandse gekookt|Shrimps Dutch boiled||94|19.8|1.6|0.1|0
    Haringfilet in tomatensaus blik|Herring fillet in tomato sauce tinned||201|12|14.6|5.4|0.5
    Haring gezouten|Herring salted|Hollandse nieuwe/maatjesharing|172|17.6|10.1|2.8|0
    Krab in water blik|Crab in water tinned||85|18.1|1.4|0|0
    Kreeft gekookt|Lobster boiled||86|19.7|0.8|0|0
    Makreel rauw|Mackerel raw||233|18|17.9|0|0
    Oesters|Oysters||57|6|1.9|4|0
    Sardines in olie blik|Sardines/pilchards in oil tinned||231|21.7|16|0|0
    Lever schelvis- blik|Liver haddock tinned|Schelvislever|409|7|42.3|0|0
    Stokvis geweekt|Stockfish soaked||138|32.5|0.9|0|0
    Eiwit kippenei rauw|Egg white chicken raw|Kippenei eiwit rauw|44|10.5|0|0.4|0
    Loempia gefrituurd in plantaardige olie|Spring roll deep-fried in vegetable oil|Maaltijdloempia bereid|181|7.1|8.2|18.6|2
    Suiker basterd- bruine|Sugar castor brown|Basterdsuiker bruine|396|0|0|99|0
    Suiker basterd- witte|Sugar castor white|Basterdsuiker witte|396|0|0|99|0
    Suiker kristal-|Sugar granulated|Tafelsuiker/kristalsuiker|400|0|0|100|0
    Stroop keuken-|Syrup Keukenstroop|Keukenstroop|328|0|0|82|0
    Stroop suiker-|Syrup sugar|Suikerstroop|300|0|0|75|0
    Advocaat|Advocaat liqueur||236|4.3|3.2|23.6|0
    Sap appel-|Juice apple|Appelsap|46|0.1|0|11.2|0
    Vruchtendrank rode bessen|Fruit juice drink redcurrent|Rode bessendrank|57|0|0|14|0.4
    Jenever bessen-|Gin Dutch red currant flavoured|Bessenjenever|184|0|0|18|0
    Vruchtendrank zwarte bessen|Fruit juice drink blackcurrant|Zwarte bessendrank|61|0|0|15|0.4
    Sap rode bessen-|Juice redcurrant|Rode bessensap|42|0.2|0|10|0.6
    Bier oud bruin|Beer old brown||38|0.5|0|5.5|0.2
    Bier pils|Beer pilsner||44|0.4|0|3|0.3
    Brandewijn|Brandy||231|0|0|0|0
    Campari|Campari||180|0|0|10|0
    Jenever citroen-|Gin Dutch lemon flavoured|Citroenjenever|180|0|0|3|0
    Cognac|Cognac||224|0|0|0|0
    Frisdrank m suiker m cafeine|Soft drink w sugar w caffeine|Cola m suiker m cafeine|41|0|0|10.4|0
    Sap druiven-|Juice grape|Druivensap|65|0.2|0|15.9|0.2
    Vruchtendrank frambozen|Fruit juice drink raspberry|Frambozendrank|57|0|0|14|0.4
    Frisdrank m suiker z cafeine|Soft drink m sugar wo caffeine|Ginger ale/tonic|37|0|0|9.2|0
    Jenever jonge|Gin young Dutch||196|0|0|0|0
    Jenever oude|Gin old Dutch||200|0|0|1|0
    Likeur 15-25 vol% alc|Liqueur 15-25 vol% alcohol|Tia maria e.d.|242|0|0|29|0
    Muskaatwijn|Muscatel||162|0|0|13.7|0
    Port|Port wine||156|0|0|13|0
    Rum|Rum||234|0|0|0|0
    Sherry|Sherry||111|0|0|3.2|0
    Sap sinaasappel- gepasteuriseerd|Juice orange pasteurized|Jus d'orange/Sinaasappelsap Appelsientje e.d.|45|0.6|0.1|9.5|0.3
    Sap tomaten-|Tomato juice|Tomatensap|16|0.7|0|3.2|0.4
    Vermouth zoete|Vermouth|Zoete Martini e.d.|150|0|0|16.5|0
    Vieux|Brandy Dutch vieux||200|0|0|1|0
    Limonade vruchten- m suiker|Juice drink w sugar|Frisdrank sinas, cassis, bitter lemon, e.d.|41|0|0|10.3|0
    Whisky|Whisky||245|0|0|0|0
    Wijn rode|Wine red||76|0.1|0|0.2|0
    Wijn witte droge|Wine white dry||67|0.1|0|0.6|0
    Frisdrank Rivella|Softdrink w milk serum and sweetener Rivella|Frisdrank Rivella|4|0|0|1|0
    Stroop appel- rinse|Syrup apple rinse|Appelstroop|280|1.8|0|65.9|4.6
    Saus barbecue-|Sauce barbecue|Barbecuesaus/barbequesaus|95|0.9|0.1|22.2|1
    Bouillonblokje|Stock cube||273|8.1|17.2|21.2|0.5
    Cacaopoeder|Cocoa powder||379|18.5|21.7|10.5|34
    Chocolade melk-|Chocolate milk|Melkchocolade|548|7|34.1|52|2.8
    Chocolade puur|Chocolate dark|Bittere chocolade/Pure chocolade|531|6.5|33.7|46.7|7.2
    Vlokken chocolade- melk|Chocolate flakes milk|Chocoladevlokken melk|454|5.8|15|72|3.5
    Boter chocolade-|Chocolate butter|Chocoladeboter|515|1.6|32.2|53.6|2.4
    Vlokken chocolade- puur|Chocolate flakes dark|Chocoladevlokken puur|444|5.2|15.5|67|7
    Pasta chocolade- hazelnoot|Spread chocolate hazelnut|Hazelnootpasta|562|5.7|35.3|53.9|2.9
    Saus cocktail/party/tafel- 25% olie|Sauce cocktail/party/table 25% oil|Cocktailsaus 25% olie|293|0.7|26.1|13.7|0.2
    Gelatine|Gelatin||352|88|0|0|0
    Gember op siroop blik/glas|Ginger stem in syrup tinned|Stemgember|288|1.8|0|69|2.5
    Gistextract Marmite|Yeast extract Marmite||238|38.4|0.1|19.2|3.1
    Hagelslag vruchten-|Coloured sprinkles fruit-flavoured|Gekleurde muisjes/Vruchtenhagelslag|393|0.1|0|98.2|0
    Honing|Honey||321|0.3|0|80|0
    Pasta chocolade- puur|Spread chocolate dark|Chocoladepasta puur|575|3|38.6|51.4|4.1
    Jam|Jam|Huishoudjam|248|0.3|0.1|60.8|1.2
    Kauwgom|Chewing gum|Kauwgum|280|0|0|70|0
    Kauwgom z suiker|Chewing gum wo sugar|Suikervrije kauwgum|171|0.1|0.6|66.4|2.4
    Kokosbrood|Coconut bread sweetened sliced||426|3.2|18.6|58.7|5.6
    Zuurtjes|Sweets boiled|Hoestbonbon/rang e.d. snoepjes|380|0|0|95|0
    Mayonaise|Mayonnaise||664|1.1|71.6|3.6|0.2
    Pepermunt|Peppermint|Tic-tac mint, after dinner mints|395|0.6|0|98.2|0
    Piccalilly|Piccalilly||53|1.3|1.3|8.2|1.8
    Pindakaas|Peanut butter||654|22.5|56.4|10|8
    Jam rozenbottel- m vit C|Jam rose hip w vit C|Rozenbotteljam|260|1.8|0.3|62|1
    Saus sla- 25% olie|Salad cream 25% oil|Dressing slasaus 25% olie|278|0.4|26.7|8.9|0.2
    Toffee|Toffees|Fruittoffee|401|0.6|6.2|85.6|0.1
    Ketchup tomaten-|Ketchup tomato|Tomatenketchup|77|1|0|17.7|0.8
    Siroop vruchtenlimonade-|Fruit drink concentrate undiluted|Limonadesiroop/ranja|233|0|0|58.2|0
    Broodbeleg zoet gem|Spread sweet av||422|3|16.5|64.2|2.5
    Saus frites- 25% olie|Sauce for chips 25% oil|Fritessaus 25% olie|296|0.5|27.3|12|0.2
    Saus frites- 35% olie|Sauce for chips 35% oil|Fritessaus 35% olie|375|0.7|36|12|0
    Pannenkoek huishoudelijk bereid m margarine|Pancake homemade prepared w margarin||206|8.3|5.8|29.2|1.6
    Tompouce|Cream slice Dutch Tompouce||315|3.8|16.9|36.5|0.9
    Oliebol gevuld m krenten en rozijnen|Doughnut Dutch style filled w currants and raisins||259|5.9|8.7|37.9|2.5
    Lever kippen- rauw|Liver chicken raw|Kippenlever rauw|128|19.1|5.4|1|0
    Melk karne- m vruchten|Buttermilk w fruit|Karnemelk m vruchten|51|3.3|0.5|8.2|0
    Biscuit fourre omhuld m chocolade|Biscuit filled chocolate coated|Sandwichbiscuit omhuld m chocola/chocoprince e.d.|500|5.4|22.6|67.7|1.9
    Koek Bastogne|Biscuit shortbread Bastogne|Kandijkoek|493|4.9|20.1|72.2|1.9
    Spekkie|Sweets marshmallow type Spekkie||334|4.1|0.4|78.3|0.3
    Spread fruit- minder suiker|Fruit spread reduced sugar|Jam 50% minder suiker/halviture/halvajam/fruitspread|118|0.5|0.2|27.7|1.7
    IJs room/vanille- cornet m chocola en nootjes|Ice cream dairy/non dairy cornet w chocolate and nuts|Ijs Cornetto e.d.|302|3.9|14.3|38.9|0.9
    Vlaai vruchten-|Flan w fruit filling|Vruchtenvlaai|228|2.9|5.1|41.6|1.1
    Candybar Mars|Candybar Mars||449|4.1|16.6|70.2|1.3
    Puddingpoeder instant chocolade|Blancmange powder instant chocolate|Kloppudding e.d. poeder chocolade-|363|3.4|2.2|80|4.8
    Vlaai rijste-|Flan filled w rice pudding|Rijstevlaai|211|4.5|6|34.5|0.7
    Siroop vruchtenlimonade- vruchtenmix m rozenbottel|Fruit drink concentrate fruit mix w rose hip|Limonadesiroop vruchtenmix/Roosvicee Original|185|0.3|0|45.6|0.6
    Siroop vruchtenlimonade- Roosvicee Fruitkracht Ferro|Fruit drink concentrate Roosvicee Fruitkracht Ferro|Limonadesiroop Roosvicee Fruitkracht Ferro|222|0.2|0|55.2|0.3
    Siroop vruchtenlimonade- Roosvicee Fruitkracht Pruimen|Fruit drink concentrate Roosvicee Fruitkracht Pruimen|Limonadesiroop Roosvicee Fruitkracht Pruimen|225|0.2|0|56|0.2
    Kaas Edammer 40+|Cheese Edam 40+||324|25.5|24.3|0|0
    Kaas Goudse 48+ gem|Cheese Gouda 48+ av|Kaas 48+ Beemster e.d.|370|22.9|30.6|0|0
    Kaas 20+ Leidse/Friese nagel-|Cheese 20+ Leidse w cumin/Fries clove|Nagelkaas friese/leidse 20+|240|33.1|11.9|0|0
    Kaas smeer- volvet 48+|Cheese spread 48+ full fat|Smeerkaas volvet 48+|260|13.4|21.7|2.1|0.5
    Kaas smeer- 40+|Cheese spread 40+|Smeerkaas 40+|227|16|17|2|0
    Kaas smeer- 20+|Cheese spread 20+|Slankie e.d. 20+ smeerkaas|137|17.2|6.8|1.7|0
    Drop zoute|Liquorice Dutch type salted||330|12.2|0.2|68.1|3.1
    Drop dubbelzoute|Liquorice Dutch type double salted||330|12.2|0.2|68.1|3.1
    Drop zoete|Liquorice Dutch type sweet||333|7.3|0.4|74.6|1
    Stophoest|Liquorice Stophoest||396|0.6|0|98.4|0
    Chocolade in krokant suikerlaagje M&M's|M&M's chocolate|M&m's zonder pinda's/smarties e.d.|487|4.6|20.7|68.6|2.7
    Candybar Milky Way|Candybar Milky Way||448|4|15.9|71.9|0.6
    Candybar Bounty|Candybar Bounty||486|3.7|26.1|58.3|1.5
    Candybar Snickers|Candybar Snickers||484|8.7|22.9|60.2|1.3
    Bakmix voor pannenkoeken|Bakery mix for pancakes|Pannenkoekenmix|332|9.5|1.3|68.1|5.1
    Bakmix voor poffertjes|Bakery mix for Dutch little pancakes poffertjes|Poffertjesmix|329|9.3|1.1|68|5.1
    Pudding chocolade-|Blancmange chocolate|Chocoladepudding|112|3.4|2|19.3|1.4
    Cacaopoeder gezoet|Cocoa powder sweetened||376|4.5|2.6|80.6|6
    Rabarbermoes m suiker|Rhubarb puree w sugar|Rabarbercompote met suiker|82|0.5|0|19|2
    Dessertsaus vruchten-|Sauce fruit for pudding|Aardbeiensaus|189|0.3|0.1|46.3|0.7
    Dessertsaus chocolade-|Sauce chocolate for pudding|Chocoladesaus|269|2.1|1.9|60.8|0.5
    Pindakaas m stukjes pinda|Peanut butter w peanut pieces||651|20|55|15|7.9
    Noten borrel-|Peanuts coated|Borrelnoten/tijgernoten/knabbelnoten|532|13.2|32.7|43.7|4.8
    Saus schaschlik-|Sauce tomato based shashlik|Schaschliksaus/Shaslicksaus/Sjasliksaus|109|0.8|0|25.9|0.9
    Topping m suiker opgeklopt Klop-Klop|Topping dessert w sugar whipped KlopKlop||111|3.5|5.2|12.5|0
    Kaas Camembert 45+|Cheese Camembert 45+||306|25|22.8|0|0
    Selderij bleek- rauw|Celery raw|Bleekselderij rauw|14|1|0|2|1.1
    Selderij knol- rauw|Celeriac raw|Knolselderij rauw|38|2|0|5|4.9
    Koolraap rauw|Swede raw||30|0.7|0.1|5|3
    Koolrabi rauw|Kohlrabi raw||31|0.9|0.3|4.7|2.8
    Postelein rauw|Purslane raw||13|1|0|1|2.5
    Prei rauw|Leek raw||28|1.5|0.2|3.5|3
    Snijbiet rauw|Swiss chard leaf raw||29|3|0|3|2.5
    Spruitjes rauw|Brussel sprouts raw||46|2.3|0.7|5.6|4.1
    Worst knak- blik/glas|Sausage frankfurter tinned|Knakworst/Frankfurter/Cocktailworstje|201|12|15.4|3.8|0.1
    Worst boterham-|Sausage luncheon meat|Boterhamworst|306|11.6|26.9|3.5|0.2
    Worst bloed-|Black pudding|Bloedworst|386|12.4|32.6|9.5|2.5
    Candybar Nuts|Candybar Nuts||497|4.6|24.8|62.3|3.3
    Spread sandwich- naturel|Sandwich spread original|Sandwichspread naturel|235|1.6|19|14|0.8
    Ketchup hot chilli|Ketchup hot chilli||101|1.2|0.1|23.3|0.8
    Ketchup curry-|Ketchup curry|Curryketchup|129|0.8|0.3|29.9|1.5
    Zemelen tarwe-|Wheat bran|Tarwezemelen|274|15.4|4.4|20.5|45.4
    Ontbijtproduct All-Bran Plus Kellogg's|Breakfast cereal All-Bran Plus Kellogg's|Ontbijtgranen All-bran plus Kellogg's|334|14|3.5|48|27
    Kaas Brie 50+|Cheese Brie 50+||318|23|25.1|0|0
    Cacaoproduct poeder Ovomaltine|Cocoa product powder Ovomaltine||370|11.2|1.7|75|4.9
    Knackebrod goudbruin|Crispbread gold-brown|Cracker knackebrod goudbruin|410|12.3|6.6|72.3|5.8
    Water 0-50 mg calcium p liter|Water 0-50 mg calcium p litre|Kraanwater zacht|0|0|0|0|0
    Water 50-100 mg calcium p liter|Water 50-100 mg calcium p litre|Kraanwater 50-100 mg calcium p liter|0|0|0|0|0
    Water >100 mg calcium p liter|Water >100 mg calcium p litre|Kraanwater hard|0|0|0|0|0
    Olie olijf-|Oil olive|Olijfolie|900|0|100|0|0
    Zalm blik|Salmon tinned||146|20.4|7.2|0|0
    Paling gerookt|Eel smoked||351|19.1|30.5|0|0
    Makreel gestoomd|Mackerel steamed||315|19.5|26.1|0.5|0
    Krentjebrij Bessola|Porridge non-dairy barley w raisins Bessola|Watergruwel Bessola|75|0.6|0.3|17|1
    Olie Becel Blend Classic|Oil Becel Blend Classic|Becel olie|900|0|100|0|0
    Olie saffloer-|Oil safflower|Saffloerolie|900|0|100|0|0
    Olie mais/maiskiem-|Oil corn|Maiskiemolie/maisolie|900|0|100|0|0
    Nasischijf diepvries gefrituurd in plantaardige olie|Rice ball spiced frozen deep fried in vegetable oil|Nasibal bereid|298|5.8|16.7|30.7|0.7
    Bamibal gefrituurd in plantaardige olie|Chinese noodle ball deep-fried in vegetable oil|Bamischijf bereid|275|7|14|30|0.7
    Saus sate- kant-en-klaar bereid|Peanut sauce ready-to-eat|Satesaus bereid/Pindasaus bereid|247|7.5|13.2|23.5|2.4
    Zoutje luchtig aardappelbasis Nibb-it|Cocktail snacks based on potatoes Nibb-it|Cheetos Nibb-it sticks|482|3.3|22.5|65|3.3
    Zoutje aardappel- Wokkels|Cocktail snacks Wokkels||493|3.4|22|69|2.8
    Fritessticks gem|Crisps potato straws av||522|6.5|27.5|60.5|3.3
    Pinda's omhuld m chocolade in krokant suikerlaagje M&M's|M&M's chocolate w peanuts|M&m's met pinda's|511|9.8|25.3|59.1|3.9
    Puddingpoeder instant overige smaken|Blancmange instant various flavours powder|Kloppudding e.d. poeder overige smaken|387|0.2|1.1|94|0
    Popcorn naturel gepoft z olie|Popcorn plain popped wo oil||386|13|4|72|5
    Bokkenpootje|Meringue cake Bokkenpootje||454|5.5|20.3|61.6|1.5
    Koek kokos-|Coconut flavoured cookies|Kokoskoek/Klapperkoek|517|6|30.8|53|2
    Koekje krakeling|Biscuit Dutch Krakeling||497|6.7|24.8|61.1|1.3
    Koek muesli-|Biscuit muesli|Mueslikoek|394|6.5|16.1|54.1|3.3
    Worst cervelaat-|Salami sausage saveloy|Plockworst/snijworst|375|17.8|33|1.3|0.7
    Spek ontbijt-|Bacon rasher streaky|Ontbijtspek|312|15.7|27.5|0.5|0
    Worst lever-|Liver sausage|Leverworst|294|14.5|25.3|1.8|0.5
    Bacon|Bacon||188|18.5|12.4|0.5|0
    Pate room-|Pate|Roompate|360|9.6|33|5.7|1.1
    Casselerrib gerookt/gekookt|Pork side cured and smoked||130|18.3|5.1|2.8|0
    Koffie bereid|Coffee prepared||1|0.2|0|0.1|0
    Thee bereid|Tea prepared||0|0|0|0|0
    Kool rode m appeltjes diepvries gekookt|Cabbage red w apple pieces frozen boiled||57|1.1|1|9.9|2.2
    Spinazie a la creme diepvries gekookt|Spinach creamed frozen boiled||44|2.9|3|0.8|1.3
    Ontbijtproduct Rice Krispies Kellogg's|Breakfast cereal Rice Krispies Kellogg's|Ontbijtgranen rice krispies Kellogg's|389|7|1.2|86|2.9
    Kaas huttenkase|Cheese cottage|Cottage cheese|92|11.2|3.9|2.3|0
    Beschuit volkoren/meergranen|Crispbakes Dutch wholemeal/multigrain||394|14|5|69|8.5
    Yoghurtdrank|Yoghurt drink|Drinkyoghurt|57|1.6|0.1|12|0.5
    Rijst witte gekookt|Rice white boiled||146|3.2|0.3|32.2|0.7
    Pasta witte gem gekookt|Pasta white av boiled|Macaroni/spaghetti/tagliatelle/noedels/mie/vermicelli witte gem gekookt|142|5.1|0.9|27.7|1.4
    Bonen bruine blik/glas|Beans brown canned|Bruine bonen blik/glas|120|6.5|0.7|18|7.9
    Sap grapefruit-|Juice grapefruit|Grapefruitsap|34|0.5|0|7.3|0.4
    Banaan bak- rijp rauw|Plantain ripe raw|Bakbanaan/bakbanen plantain rijp rauw|138|1.3|0|32|2.3
    Cassave rauw|Cassava raw|Maniokwortel rauw|142|0.6|0.2|33.5|1.7
    Taro rauw|Taro raw|Chinese tajer rauw/Chinese tayer rauw|119|1.4|0.2|26.2|3.5
    Yam rauw|Yam raw||124|1.5|0.3|28.2|1.3
    Pomtajer rauw|Tannia raw|Tajerknol rauw/Pomtayer rauw|136|2|0|31|2
    Aardappel zoete rauw|Potato sweet raw|Bataat zoete rauw|91|1.2|0.3|19.7|2.4
    Agoemawiwiri rauw|Black nightshade raw||60|5|1|7|1.4
    Amsoi rauw|Mustard leaves raw|Mosterblad rauw|32|2.5|0.3|3.2|3.2
    Antroewa rauw|Antroewa raw|Afrikaanse aubergine|30|1|0|6|1.2
    Dagoeblad rauw|Dagoe leaf raw|Waterspinazie/kangkoeng rauw|34|3|0|5|1.1
    Kaisoi rauw|Kaisoi raw||32|3|0|5|0.1
    Klaroen rauw|Amaranth leaves raw||56|4|1|7|1.5
    Kousenband rauw|Beans long yard Kousenband raw|Bonen kousenband rauw|43|3|0|7|1.3
    Okra rauw|Okra raw|Oker rauw|23|1.9|0.2|1.8|3.2
    Poeng rauw|Bottlegourd poeng||31|1|0|6|1.5
    Pompoen rauw|Pumpkin raw||14|0.7|0.2|2|1
    Sopropo rauw|Bitter gourd pods raw|Bitterkomkommer rauw|15|1|0.2|0.9|2.8
    Tajerblad rauw|Tannia leaves raw|Tayerblad/boterblad|19|2|0|2|1.4
    Bonen black eyed gedroogd|Beans black eyed dried||367|23|2|62|4.4
    Erwten split- gele/groene gedroogd|Peas split yellow/green dried|Splitpesie erwten gedroogd|359|22|2|61|4.7
    Avocado|Avocado||186|2|18.4|1.8|3.1
    Guave (met roze vruchtvlees)|Guava (pink fleshed)||75|2.6|1|10.9|5.3
    Limoen|Lime|Lemmetje|41|0.7|0.2|7.7|2.8
    Mango|Mango||66|0.6|0.2|14.3|1.6
    Papaja|Papaya||39|0.5|0.3|7.8|1.7
    Tamarinde|Tamarind||301|3|0|72|0.3
    Meel cassave-|Flour cassava|Cassavemeel|354|0.9|0.5|82.7|7.7
    Meel mais-|Flour corn|Maismeel|363|6.1|1.7|76.7|8.3
    Bojo cassavetaart Surinaams|Cassava cake Bojo Surinam||214|1.9|8.6|31|2.3
    Rundvlees gezouten rauw Surinaams|Beef salted raw Surinam|Surinaams zoutvlees rauw|201|14.5|15.8|0|0.2
    Rundvlees gezouten gedroogd Surinaams|Beef salted dried Surinam|Surinaams zoutvlees gedroogd|305|65|5|0|0
    Garnalen gezouten gedroogd|Shrimps salted dried||274|63|2|1|0
    Bakkeljauw (gedroogde gezouten kabeljauw)|Cod dried salted|Kabeljauw/klipvis gedroogd gezouten|355|82|3|0|0
    Garnalenpasta trassie|Shrimp paste trassie||208|37|5|2.5|2.7
    Rijst zilvervlies- rauw|Rice brown raw|Zilvervliesrijst onbereid|357|8.3|2.6|73.5|3
    Wafel stroop- gem|Waffle syrup av|Stroopwafel gemiddeld|473|3.8|19.3|70.2|1.6
    Kaas blauwschimmel Roquefort|Cheese Roquefort||357|19|31|0|0
    Kaas Saint Paulin/Port Salut|Cheese Saint Paulin/Port Salut||341|21.5|28.2|0|0
    Chocolade melk- m hazelnoten|Chocolate milk w hazelnuts|Melkchocolade m hazelnoten|562|7.7|35.9|50.2|3.7
    Kaas Parmezaanse|Cheese Parmesan||404|40|27|0|0
    Kaas room- zachte Mon Chou|Cheese cream soft Mon Chou|Roomkaas verse Mon Chou|316|6.8|31|2.4|0
    Kaas Limburgse|Cheese Limburger||283|21|21|2|0
    Kaas Gruyere|Cheese Gruyere||433|29|34.5|1.4|0
    Kaas Emmentaler|Cheese Emmenthaler||387|29|30|0|0
    Kaas Cheddar|Cheese Cheddar||415|25.5|34.4|0.1|0
    Kaas blauwschimmel Bluefort|Cheese Bluefort|Blauwschimmelkaas Bluefort|405|17.9|37|0|0
    Bonbon m likeur|Chocolate w liqueur||383|3.3|16.6|49.2|3.6
    Kaas room- zachte Boursin|Cheese cream soft Boursin|Roomkaas zachte boursin/kaas verse boursin|411|7.5|41|3|0
    Halvanaise|Mayonnaise low fat 40% oil||400|1|40|9|0.2
    Pudding vanille-|Blancmange vanilla|Vanillepudding|89|3.9|2|13.7|0
    Aardappelpuree instant- gem bereid|Potatoes mashed instant prepared average||83|2.9|1.5|14.1|1.1
    Mineraalwater m en z koolzuur gem|Mineral water sparkling and not sparkling av|Mineraalwater naturel (zonder/met koolzuur)|0|0|0|0|0
    Vlaaivulling blik|Flan filling tinned||99|0.5|0.1|23|1.3
    Marshmallows|Marshmallows||329|4.6|0.1|77.3|0.2
    Drop Engelse|Liquorice allsorts||394|3.7|5.2|82|2
    Winegum/fruitgom|Wine gum/ fruit gum|Fruitgum|319|5|0.2|74.2|0.2
    Soep heldere m soepgroente en vermicelli|Soup clear w vegetables and noodles||17|0.7|0.4|2.5|0.6
    Soep heldere m vlees (rund/kip)|Soup clear w meat (beef/chicken)||39|4.9|2|0.3|0
    Soep heldere m soepgroente|Soup clear w vegetables||10|0.4|0.3|1|0.6
    Soep heldere m vlees (rund/kip) en vermicelli|Soup clear w meat (beef/chicken) and noodles||46|5.1|2|1.9|0.1
    Soep heldere m vlees (rund/kip) en soepgroente|Soup clear w meat (beef/chicken) and vegetables||36|4.1|1.7|0.9|0.5
    Soep heldere m vlees (rund/kip), soepgroente en vermicelli|Soup clear w meat (beef/chicken) vegetables and noodles||42|4.4|1.7|2.1|0.5
    Soep gebonden m soepgroente|Soup thickened w vegetables||36|0.7|2.4|2.7|0.7
    Soep gebonden m vlees (rund/kip)|Soup thickened w meat (beef/chicken)||64|4.9|3.9|2.1|0.1
    Soep maaltijd- m peulvruchten z vlees|Soup main course w legumes wo meat|Erwtensoep/bonensoep z vlees en m groente|58|3.3|1|7|3.8
    Soep maaltijd- m peulvruchten en vlees|Soup main course w legumes and meat|Erwtensoep/bonensoep m vlees en m groente|99|6.3|3.3|9.3|3.4
    Mousse chocolade- huishoudelijk bereid|Mousse chocolate home-made|Chocolademousse huishoudelijk bereid|301|8.9|16.8|27.4|2.6
    Worst thee-|Sausage spiced and smoked|Theeworst|329|12|31|0.5|0
    Worst paling-|Sausage w smoked bacon-bits|Palingworst|308|13|26.6|4|0.1
    Ham achter-|Ham lean boiled|Achterham|134|18|5.7|2.5|0.1
    Ham schouder-|Ham shoulder medium fat boiled|Schouderham|133|16.4|6.2|2.4|0.4
    Koek boter-|Cake butter Dutch Boterkoek|Boterkoek|456|4.6|26.1|49.7|1.5
    Amandelspijs m ei|Almond paste w egg||446|10.3|24.2|45.1|2.9
    Soep heldere m vermicelli|Soup clear w noodles||15|0.5|0.4|2.4|0.1
    Soep gebonden m vlees (rund/kip) en soepgroente|Soup thickened w meat (beef/chicken) and vegetables||55|2.9|3.3|3.2|0.6
    Worst incl leverproducten gem|Sausage incl liver products av||343|15.7|29.9|2.5|0.3
    Soep op groentebasis bereid pakje|Soup vegetable based dried packet prep|Groentesoep pakje bereid|23|0.5|0.8|3.3|0.1
    Soep op vleesbasis bereid pakje|Soup meat based dried packet prepared|Kippensoep/rundvleessoep pakje bereid|13|0.7|0.2|2|0.4
    Soep op peulvruchtenbasis bereid pakje|Soup legume based dried packet prepared|Erwtensoep/bonensoep pakje bereid|45|2.7|0.5|6.2|2.5
    Soep op groentebasis kant-en-klaar blik/zak/pak|Soup vegetable based ready-to-eat|Groentesoep blik/zak/pak kant-en-klaar|47|1.3|1.9|5.7|0.8
    Soep op vleesbasis kant-en-klaar blik/zak/pak|Soup meat based ready-to-eat|Kippensoep blik/zak/pak kant-en-klaar|25|2|0.7|2.5|0.2
    Soep op peulvruchtenbasis kant-en-klaar blik/zak/pak|Soup legume based ready-to-eat|Erwtensoep/bonensoep blik/zak/pak kant-en-klaar|80|4|2.3|9.5|3
    Kaas schapen- vers|Cheese sheep fresh|Schapenkaas vers|238|17|18.8|0|0
    Kruidenbitter Jagermeister|Jagermeister herb liquor||294|0|0|14|0
    Spread fruit- m zoetstof|Fruit spread w sweetener|Jam m zoetstof/Suikervrije jam/Fruitspread z suiker|156|0.4|0.2|59.2|1.2
    Santen kokoscreme vast|Santen creamed coconut block|Santen klappercreme vast|686|6.8|67.3|12.9|0.5
    Filet americain|Beef steak tartare spiced filet americain||240|14.2|18.8|3|0.9
    Pasta volkoren rauw|Pasta wholemeal raw|Macaroni/spaghetti volkoren onbereid|344|13.3|2.2|64|7.5
    Room zure|Cream sour||134|3|12|3.4|0
    Schol rauw|Plaice raw||76|16.4|1.2|0|0
    Vissticks gebakken in zonnebloemolie|Fish fingers fried in sunflower oil||239|16.4|13|13.9|0.4
    Vissticks onbereid|Fish fingers unprepared||194|13|8|17|0.8
    Schol gebakken|Plaice fried||194|22|10.9|2|0
    Lekkerbekje gefrituurd in plantaardige olie|White fish fillet in batter deep-fried in vegetable oil||210|19|11.2|8.2|0.2
    Kabeljauw gekookt|Cod boiled||105|23|1|1|0
    Kabeljauw rauw|Cod raw||75|17.5|0.6|0|0
    Bokking bak- gebakken|Bloater fried|Panharing gebakken|299|21.6|22.2|3|0.1
    Peper zwarte/witte|Pepper black/white||332|11|3|52|26.4
    Mosterd|Mustard||129|6.7|7.8|6.6|3
    Nootmuskaat|Nutmeg powder||536|6|36|45|4
    Kaneel|Cinnamon||316|4|3|56|24.4
    Komijnzaad gedroogd|Cumin seed dried||427|18|22|34|10.5
    Kruidnagel|Cloves||431|6|20|52|9.6
    Bieslook vers|Chives fresh||62|4|1|8|2.3
    Knoflook rauw|Garlic raw||158|6.4|0.5|31|2.1
    Kervel vers|Chervil fresh||44|4|1|3.6|2.4
    Gemberwortel|Ginger root||81|1.8|0.8|15.7|2
    Appelcarre|Apple strudel||278|3.7|11.7|38.6|1.7
    Taart kwark-|Cheesecake made w quark|Kwarktaart/kwarkgebak|218|5.5|12.2|21.4|0.5
    Koekje zand-|Shortbread|Zandkoekje|479|4.6|27|53.5|1.9
    Sesamzaad z schil|Sesame seeds wo hull||632|22.7|57.4|1.8|8.9
    Bonen soja- gedroogd|Beans soya dried|Sojabonen gedroogd|418|35.9|18.6|15.8|22
    Zout m toegevoegd jodium|Salt fortified w iodine|Jozo zout|0|0|0|0|0
    Bouillonpoeder|Stock powder||197|20.2|5.1|17.8|0
    Broodje worsten- diepvries bereid in oven|Snack sausage roll w bread dough frozen prepared in oven|Worstenbroodje diepvries bereid in oven|369|11|19|38|0.9
    Dressing naturel z olie|Salad dressing natural wo oil||32|0|0|7.9|0
    Candybar Twix|Candybar Twix||495|4.5|23.9|64.6|1.5
    Gierst rauw|Millet raw|Gierst onbereid|368|11.8|4.2|69.4|2.6
    Grapefruit op siroop blik/glas|Grapefruit in syrup canned||66|0.5|0|15.5|0.9
    Venkel rauw|Fennel raw||17|1|0|2|2.4
    Groente zoetzuur atjar tjampoer glas|Vegetables mixed pickled Atjar tjampoer glass||42|1|0.2|7.6|2.4
    Paprika zoetzuur glas|Sweet pepper pickled glass||16|0.9|0.1|2|1.7
    Salade selderij- lunch/borrel|Salad celeriac|Selderij-/selleriesalade lunch/borrel|206|1|17.6|9.1|3.2
    Taart vruchten- v biscuitdeeg m slagroom|Gateau fatless sponge w fruit & cream|Vruchtentaart/gebak v biscuitdeeg m slagroom|228|3.1|14.1|21.8|0.8
    Speculaas gevulde|Biscuit spiced Speculaas w almond paste||437|7.2|23.9|47.1|2.2
    Rosti onbereid|Rosti unprepared||123|2.5|2.5|21.5|2.2
    Madeira|Madeira||166|0|0|10|0
    Juspoeder|Gravy instant powder||342|10.8|8.2|55.2|2.4
    Aroma vloeibaar|Seasoning flavoured liquid|Maggi e.d. vloeibaar aroma|70|10.6|0.1|6.4|0.5
    Aroma strooi-|Seasoning flavoured powder|Aromat e.d. strooiaroma|176|9.9|3.9|25|0.6
    Sap bieten-|Juice beetroot|Bietensap|34|0.9|0|7.7|0
    Milkshake m vers fruit|Milkshake w fresh fruit||97|2.4|1.9|17.2|0.4
    Yoghurt vruchten- volle|Yoghurt full fat w fruit|Vruchtenyoghurt vol|97|3.7|3.1|12.7|0.6
    Fruitgom pectine gesuikerd|Sweets fruit pectinbased|Vruchtenkoekje/snoep op pectinebasis vruchtensmaak|341|0.3|0.3|84.2|0.7
    Lijnzaad|Linseeds||477|19|31|13|34.8
    Meel soja-|Flour soya|Sojameel volvet|429|39.1|22.9|7.6|17.9
    Drink soja- z suiker|Drink soya wo sugar|Sojadrink naturel|35|3.4|1.8|1|0.6
    Sojapasta miso|Miso soya paste||130|11.7|5|6.2|6.6
    Zonnebloempitten|Sunflower seeds||647|18|56.5|13|7.4
    Biscuit meergranen- Liga Evergreen krenten|Biscuit w currants Liga Evergreen||390|6.9|9.1|67|6.3
    Appel m schil gem|Apple w skin av||56|0.3|0.2|12|2
    Pinda's gezouten|Peanuts salted|Aardnoten gezouten/zoute pinda's|620|24.8|50.5|13.2|6.8
    Croissants uit blik afgebakken|Croissants canned baked||421|7|22.6|46|2.6
    Boter gezouten|Butter salted|Roomboter gezouten|737|0.7|81.2|1.1|0
    Smeltjus onbereid pakje|Fat for gravy unprepared Smeltjus||650|1|70|4|0
    Kaas Kernhemmer 60+|Cheese Kernhem 60+||443|18.6|40.6|0|0
    Kaas Old Amsterdam 48+|Cheese Old Amsterdam 48+||404|26|33|0|0
    Paprika rode rauw|Sweet pepper red raw|Paprika rood rauw|25|0.8|0.1|4.3|1.8
    Paprika rode gekookt|Sweet pepper red boiled|Paprika rood gekookt|28|0.9|0.1|5.1|1.7
    Pasteibakje roomboter-|Vol -au-vent shell made w butter|Pasteitje roomboter- bakje ongevuld|570|8.9|39.6|43.4|2.4
    Pasteibakje z roomboter|Vol -au-vent shell wo butter|Pasteitje z roomboter bakje ongevuld|566|8.4|39.1|43.9|2.5
    Broodje worsten-|Snack sausage roll w bread dough pastry|Worstenbroodje|382|11.8|21.8|34.2|0.9
    Soepballetjes blik|Forcemeat balls for soup canned|Gehaktballetjes soep- blik|189|10|15|3.5|0.2
    Pudding frambozen- m rode bessensaus|Blancmange raspberry w red currant sauce|Frambozenpudding met bessensaus|104|3.4|2.2|17.6|0
    Kwark vruchten- halfvolle|Quark half fat w fruit|Vruchtenkwark halfvol/Kwark vanille- halfvol|109|5.9|3.5|12.8|0.8
    Schol gekookt|Plaice boiled||98|19|2|1|0
    Koolvis (Atlantisch) gekookt|Pollock (Atlantic) boiled||114|25|1.5|0|0
    Broccoli gekookt|Broccoli boiled||27|3.9|0.3|0.8|2.7
    Broccoli rauw|Broccoli raw||27|2.9|0.7|0.7|3.1
    Courgette rauw|Courgettes raw||18|1.3|0.2|2.3|0.9
    Sap peren-|Juice pear|Perensap|39|0.1|0|9.5|0.1
    Koek ontbijt- volkoren|Cake Dutch spiced Ontbijtkoek wholemeal|Ontbijtkoek volkoren|308|3.1|1.7|67.7|4.5
    Kaas 20+ natriumarm|Cheese 20+ low sodium||264|36.7|13|0|0
    Kaas 40+ natriumarm|Cheese 40+ low sodium||339|29.4|24.6|0|0
    Chocolade melk- suikervrij|Chocolate milk sugar-free|Suikervrije melkchocolade|485|7.1|34.7|47.8|6.7
    Wijn pleegzusterbloed-|Wine medicinal pleegzusterbloedwijn|Pleegzuster Bloedwijn|154|0|0|14|0
    Kwark vruchten- magere|Quark low fat w fruit|Vruchtenkwark mager|80|8.6|0.2|10.3|0.3
    Pudding griesmeel- m rode bessensaus|Blancmange semolina w red currant sauce|Griesmeelpudding met rode bessensaus|113|2.8|2.2|20.5|0.1
    Pudding vanille- m aardbeiensaus|Blancmange vanilla w strawberry sauce|Vanillepudding met aardbeiensaus|112|4.1|2.3|18.8|0
    Bitterbal bereid in oven|Croquette Dutch Bitterbal prepared in oven||302|11|18|23|1.9
    Kroket vlees- bereid in oven|Croquette meat ragout prepared in oven||204|8.9|9|20.9|1.9
    Rosti bereid z vet|Rosti prepared wo fat||149|1.9|5.1|22.8|2.2
    Gist vers|Yeast fresh||66|11.4|0.4|1|6.2
    Bonen sperzie- gekookt|Beans French boiled|Sperziebonen/haricots verts gekookt|25|1.8|0.4|2.2|2.9
    Kool boeren- diepvries gekookt|Kale curly frozen boiled|Boerenkool diepvries gekookt|37|2|1.6|2.5|2.5
    Doperwten diepvries gekookt|Peas frozen boiled||92|6|0|14.8|4.5
    Bonen sperzie- diepvries gekookt|Beans French frozen boiled|Sperziebonen diepvries gekookt|34|1.8|0.1|5.4|2.1
    Asperge witte gekookt|Asparagus white boiled||21|1|0.3|3|1.2
    Biet rode gekookt|Beetroot boiled|Rode bieten gekookt/Kroten gekookt|30|1.2|0.1|4.6|2.9
    Kool boeren- rauw|Kale curly raw|Boerenkool rauw|33|3|0.6|1.6|4.7
    Schorseneren gekookt|Salsify boiled||84|1|1|17|1.7
    Bonen snij- gekookt|Beans runner boiled|Snijbonen gekookt|23|1.8|0|1.9|4.2
    Bonen tuin- gekookt|Beans broad boiled|Tuinbonen gekookt|45|5|0|4|4.7
    Doperwten gekookt|Peas fresh boiled||69|4|0|11|4.5
    Peultjes gekookt|Mange-tout boiled||33|2|0|5|2.5
    Courgette gekookt|Courgettes boiled||19|1.5|0.1|2.3|1.1
    Venkel gekookt|Fennel boiled||17|1|0|2|2.4
    Kapucijners gekookt|Peas marrowfat boiled||127|9.5|0.9|15.7|8.9
    Linzen groene en bruine gekookt|Lentils green and brown boiled||99|8.8|0.7|11.6|5.3
    Bonen soja- gekookt|Beans soya boiled|Sojabonen gekookt|123|10.6|5.5|4.6|6.5
    Erwten groene gekookt|Peas green boiled||126|8.4|0.8|17.2|8.2
    Knackebrod sesam|Crispbread sesame|Cracker knackebrod sesam|421|12.8|9.8|67.8|5.1
    Knackebrod lichtgewicht|Crispbread lightweight|Cracker knackebrod lichtgewicht|334|10|1.5|59|22
    Sportvoeding reep Isostar Energy Bar|Sports food energy bar Isostar|Sportvoeding energiereep isostar high/long energy|399|5|9.3|72.5|3
    Aardappelen z schil gekookt gem|Potatoes wo skin boiled av||83|1.9|0.3|17.4|1.6
    Soep op groentebasis natriumarm bereid|Soup vegetable based low sodium prepared|Groentesoep natriumarm|22|0.8|0.2|4|0.7
    Granaatappel|Pomegranate||91|1|1|17|3.4
    Toetje m room|Dairy dessert w cream||105|2.5|3.8|15.3|0.2
    Vijgen vers|Figs fresh||84|1|0|19|2
    Roggebrood volkoren natriumarm|Rye bread wholemeal low sodium|Fries/donker roggebrood natriumarm|201|5.6|1.3|37.6|8.3
    Paneermeel|Bread crumbs||357|11.6|1.6|69.9|8.1
    Rijst zilvervlies- gekookt|Rice brown boiled|Zilvervliesrijst gekookt|131|3.1|1|26.4|2.1
    Tarwe gebroken bulgur rauw|Bulgur wheat raw|Bulgur onbereid|340|12.3|1.3|63.4|12.5
    Tarweroggebrood volkoren|Wheat rye bread wholemeal|Volkorenbrood tarwerogge|234|9.7|1.9|40.9|7.2
    Vlokken rogge-|Rye flakes|Roggevlokken|318|8.1|1.7|57|21.2
    Grutten boekweit-|Buckwheat groats|Boekweitgrutten|353|7.5|1.4|76.4|2.3
    Meel bak- zelfrijzend|Flour wheat self-raising|Zelfrijzend bakmeel|334|9.8|1|69.2|4.1
    Artisjok rauw|Artichoke raw||49|2|0|9.5|1.5
    Beschuit natriumarm|Cripsbakes Dutch low sodium||399|14|6|71|2.3
    Bloem rijste- verrijkt m vit B1|Flour rice fortified w vit B1|Rijstebloem verrijkt|380|7.5|0.9|85.3|0.5
    Gist gedroogd|Yeast dried||390|48|6|36|0
    Kiwi groene|Kiwi fruit green||62|0.9|0.8|10.8|2.3
    Kaki / Sharonvrucht|Kaki / Sharon fruit|Persimon|77|0.5|0|18.6|0.5
    Glucosepoeder|Preparation glucose powder|Druivensuiker/Dextrose|364|0|0|91|0
    Passievrucht|Passion fruit|Maracuja|52|2.6|0.4|5.7|3.3
    Kefir|Kefir||40|3.5|1.5|3.1|0
    Sla mol- rauw|Dandelion leaves raw|Molsla/ paardenbloemblad rauw|55|3|1|8|1.2
    Lychee|Lychees||72|0.9|0.1|16.1|1
    Pate/smeerworst vegetarisch obv voedingsgist|Pate vegetarian based on nutritional yeast|Pate Tartex e.d.|218|4.6|17.5|9.3|2.8
    Erwten kikker- gekookt|Peas chick boiled|Kikkererwten gekookt|138|7.6|3|15.9|8.8
    Zalm gerookt|Salmon smoked||188|21.8|10.8|0.8|0
    Kaviaar|Caviar|Kuit van de steur|281|24|20.5|0|0
    Inktvis rauw|Squid raw||73|16|1|0|0
    Kumquat|Kumquat||52|0.9|0.5|9.1|3.8
    Haring in (zoet)zuur|Herring pickled (sweet)sour|Zure haring|208|16|16|0|0
    Slakken wijngaard-|Snails|Escargots|85|16|1.4|2|0
    Kaas rook- 45+|Cheese smoked 45+|Rookkaas|331|21.2|26.2|1.8|0.1
    Meloen water-|Melon water|Watermeloen|36|0.5|0|8|0.6
    Meloen suiker-|Melon honeydew|Suikermeloen/honingmeloen|30|0.9|0|6.3|0.6
    Kaas Rambol|Cheese Rambol||291|13.6|25|2.3|0.7
    Kaas smeer- 60+ Kiri|Cheese spread 60+ Kiri|Smeerkaas Kiri 60+|330|8.5|32|2|0
    Kaas Stilton|Cheese Stilton||388|21.3|33.4|0.1|0
    Kaas Camembert 30+|Cheese Camembert 30+||223|24|14|0|0
    Kaas rauwmelkse 48+|Cheese raw milk 48+|Boerenkaas 48+/Rauwmelkse kaas 48+|392|26|32|0|0
    Kaas 48+ natriumarm|Cheese 48+ low sodium||381|26.1|30.7|0|0
    Meloen op siroop blik/glas|Melon in syrup canned||80|0.5|0|19|1
    Doperwten extra fijn natriumarm blik/glas|Peas extra fine low sodium tinned||51|4|0|6.5|4.7
    Sap citroen- vers|Juice lemon fresh|Citroensap|47|0.4|0|8|0.3
    Sap tomatengroenten-|Juice tomato/vegetable|Tomatengroentensap|21|1|0|4|0.4
    Champignon natriumarm blik/glas|Mushroom low sodium tinned||18|2.1|0.4|0.2|2.8
    Kruidenbitter Berenburg|Berenburg herb liquor||189|0|0|0|0
    Andijvie diepvries onbereid|Endive frozen unprepared||9|1|0|0.3|1.7
    Doperwten m wortelen diepvries onbereid|Peas and carrots frozen unprepared||58|3.8|0.4|7.1|5.2
    Groentemix Mexico Melange diepvries onbereid|Vegetable mixed Mexico frozen unprepared||85|4.5|0.9|12|5.3
    Bonen snij- diepvries onbereid|Beans runner frozen unprepared|Snijbonen diepvries onbereid|28|1.9|0.1|3.6|2.7
    Groente soep- diepvries onbereid|Vegetables mixture for soup frozen unprepared|Soepgroente diepvries onbereid|25|2|0|3|2.6
    Spinazie gesneden diepvries onbereid|Spinach cut frozen unprepared||20|2.3|0.3|1.1|2.1
    Spruitjes diepvries gekookt|Brussel sprouts frozen boiled||47|2.3|0.7|5.6|4.5
    Bonen tuin- diepvries onbereid|Beans broad frozen unprepared|Tuinbonen diepvries onbereid|87|7.5|0.6|9.3|7.3
    Aardappelschijfjes/-partjes ed diepvries onbereid|Potatoes slices/parts frozen unprepared|Aardappelpartjes/-schijfjes ed diepvries onbereid|134|2.5|3.8|21.2|2.5
    Vleeswaren >30 g vet gem|Processed meat products >30 g fat av||393|16.4|35.1|2.6|0.5
    Worst salami|Sausage salami||392|18.7|34.8|0.9|0
    Gehakt gebraden (vleeswaar)|Meatloaf (processed meat product)|Gebraden gehakt (vleeswaar)|304|12.8|25.6|5.6|0.3
    Sap tomatengroenten- natriumarm|Juice tomato/vegetable low sodium|Tomatengroentensap natriumarm|21|1|0|4|0.4
    Augurk zoetzuur natriumarm|Gherkins sweet pickled low sodium||17|1.1|0|2.8|0.9
    Ui zilver- zoetzuur natriumarm glas|Onion silver-skin sweet pickled low sodium glass|Zilveruitjes zoetzuur glas natriumarm|21|1|0|3|2.7
    Ui zilver- zoetzuur z suiker glas|Onion silverskin sweet pickled wo sugar glass|Zilveruitjes zoetzuur suikervrij|21|1|0|3|2.7
    Augurk zoetzuur z suiker|Gherkins pickled wo sugar||14|1.2|0.3|1.1|1.2
    Komkommerschijven zoetzuur glas|Cucumber sliced pickled glass||9|0.7|0|1|0.9
    Worst gekookte|Sausage cooked|Gelderse gekookte worst/kookworst|357|11.3|33|3.7|0
    Vleeswaren 20-30 g vet gem|Processed meat products 20-30 g fat av||310|13.7|26.9|2.9|0.2
    Vleeswaren 10-20 g vet gem|Processed meat products 10-20 g fat av||213|14.9|15.5|3.2|0.3
    Appelmoes z suiker blik/glas|Apple sauce wo sugar tinned|Appelpuree/appelcompote suikervrij blik/glas|48|0.2|0|10.7|1.4
    Bamboespruiten blik/glas|Bamboo shoots tinned||33|2|0|6|0.5
    Vleeswaren <10 g vet gem|Processed meat products <10 g fat av||144|18.4|6.5|2.5|0.2
    Zout mineraal- natriumarm LoSalt|Salt low sodium LoSalt|Mineraalzout natriumarm Losalt|0|0|0|0|0
    Ketjap zout|Soy sauce salt Ketjap|Ketjap asin/Sojasaus zout|211|2.8|0|50|0
    Ketjap zoet natriumarm|Soy sauce sweet low sodium Ketjap|Ketjap manis natriumarm/Sojasaus zoet natriumarm|238|4.5|0|55|0.1
    Ketjap zoet|Soy sauce sweet Ketjap|Ketjap manis/Sojasaus zoet|234|3.5|0|55|0
    Smaakversterker mononatriumglutamaat Ve-tsin|Monosodium glutamate Ve-tsin||0|0|0|0|0
    Basilicum gedroogd|Basil dried||244|23|4.1|10.1|37.7
    Chilipoeder|Chilli powder||373|12|17|32|22
    Kerrie djawa|Curry powder djawa||370|12|14|36.5|25
    Kervel gedroogd|Chervil dried||303|23|4|38|11.3
    Peper cayenne- rood|Pepper red cayenne|Cayennepeper rode|379|12|17|32|24.9
    Majoraan gedroogd|Marjoram dried|Marjolein gedroogd|319|13|7|42|18.1
    Mosterd natriumarm|Mustard low sodium||126|6.5|9.5|3.1|1
    Oregano gedroogd|Oregano dried||360|11|10|49|15
    Paprikapoeder|Paprika powder||359|15|13|35|20.9
    Peterselie gedroogd|Parsley dried||309|22|4|41|10.3
    Rozemarijn gedroogd|Rosemary dried||374|5|15|46|17.6
    Sambal oelek|Pepper red hot paste||36|1.6|0.7|4.9|1.9
    Sambal oelek natriumarm|Pepper red hot paste low sodium||50|3|2|4|1.9
    Sambal gebakken|Pepper red hot fried paste||250|4.4|18.5|15.5|1.9
    Selderij blad- vers|Celery leaves fresh||16|1|0|2|1.8
    Serehpoeder|Lemon grass powder|Citroengras poeder|216|5|3|30|24.4
    Worst lever- hausmacher|Liver sausage coarse hausmacher|Leverworst hausmacher|266|15.4|20.4|5.2|0
    Worst smeerlever-|Liver pate sausage|Smeerleverworst|319|12.3|28.6|3|0.3
    Vruchten op eigen sap blik/glas|Fruit in own juice tinned|Vruchten op sap blik/glas|48|0.6|0.1|10.3|1.7
    Knackebrod vezelrijk|Crispbread high fibre|Cracker knackebrod vezelrijk|350|13|6.5|48|23.9
    Makreel in water blik|Mackerel in water tinned||257|18.6|20.3|0|0
    Marsepein|Marzipan||420|5.3|15.3|64.2|2.2
    Mayonaiseproduct m yoghurt|Mayonnaise product w yoghurt|Yofresh/Mayonaise met yoghurt|281|0.9|25|13|0.3
    Babyvoeding fruit 4 mnd|Infant food fruit 4 months|Olvarit e.d. fruithapje/moes/puree 4 mnd|58|0.5|0.1|13|1.8
    Babyvoeding groente 4 mnd|Infant food vegetables 4 months|Olvarit e.d. groentehapje/moes/puree 4 mnd|50|1.3|0.2|9.7|2.3
    Vruchtendrank m zuivel Taksi m suiker|Fruit drink w dairy Taksi w sugar|Limonade vruchten-/frisdrank Taksi m suiker|32|0.1|0|7.9|0
    Spek rook- vet bereid|Bacon fat smoked prepared|Spekblokjes vet bereid|505|25|45|0|0
    Kaas room- zachte Paturain|Cheese cream soft Paturain|Roomkaas zachte Paturain/kaas verse Paturain|354|7|35.3|2.3|0
    Kip z vel rauw|Chicken wo skin raw||139|20.5|6.3|0|0
    Kip soep- m vel rauw|Chicken for soup w skin raw|Soepkip met vel rauw|247|19|19|0|0
    Scholfilet gebakken/gestoofd|Plaice fillet fried/simmered||112|18.9|3.8|0.5|0
    Hagelslag chocolade- gem|Chocolate sprinkles av|Chocoladehagelslag gem|449|5.7|15.3|69.3|5.2
    Cracker luchtige Cracottes natural|Crispbread Cracottes naturel||381|12|2.8|75|4.1
    Ei kippen- gebakken|Egg whole chicken fried in margarine|Kippeneieren gebakken|220|14.4|17.6|0.9|0
    Kabeljauwfilet gebakken/gestoofd|Cod fillet fried/simmered||118|21.5|3.3|0.6|0
    Kip/bout z vel gegrild|Chicken wo skin grilled||188|28.5|7.9|0.6|0
    Biscuit haver- Liga HaverKick|Biscuit Liga Haverkick||397|5|12|65|4.7
    Gehakt hoh rul gebakken|Minced beef/pork shallow fried|Half om half gehakt rul bereid|317|30.1|21.6|0.4|0.6
    Ontbijtproduct Olvarit pap tarwe en rogge 8+ mnd|Breakfast cereal porridge Olvarit tarwe en rogge 8+ months|Ontbijtgranen Olvarit pap licht volkoren 8+ mnd|376|11.6|2.1|72|11.1
    Biscuit meergranen- Liga Evergreen ov smaken|Biscuit Liga Evergreen assortment||387|6.4|8.6|68|6.3
    Tarwebrood wit Turks|Wheat bread white Turkish|Turks brood wit/pide/somun|250|8.5|1.5|49.3|3
    Turks fruit|Turkish Delight|Turkisch delight/helva/lokum|372|0|0|92.9|0.3
    Baklava|Baklava nut-honey cake|Gebak noten-honing|461|10.4|24.5|49.2|1
    Tulumba tatlisi gefrituurde soesjes Turks|tulumba tatlisi fried eclair Turkish|Turkse soesjes in suikerstroop tulumba tatlisi|391|4.4|16.9|54.8|1.1
    Worst droge sucuk Turks|Sausage dry sucuk Turkish||446|20.4|37.5|6.7|0
    Worst salam Turks|Sausage salam Turkish||271|14.8|20.6|6.5|0
    Kikkererwten geroosterd leblebi Turks|Chick peas roasted leblebi Turkish||400|21.3|8.1|53.6|13.7
    Druivenblad glas|Grape leaves glass||33|3.3|0|1.8|6.3
    Tafelzuur tursu Turks|Vegetables pickled Turkish Tursu||24|0.6|0|3.9|2.9
    Gehakt runder- kofte Turks bereid|Minced beef kofte Turkish prepared|Turkse kofte rundergehakt bereid|251|25.8|12.6|8.2|0.7
    Gehakt schapen- kofte Turks bereid|Minced mutton prepared Kofte Turkish|Turkse kofte schapengehakt bereid|203|22.6|10.6|3.8|0.9
    Dessert soja- verrijkt m calcium en vitamines|Dessert soya fortified w calcium and vitamins|Sojadessert/Plantaardige alternatief voor vla|85|3.1|1.9|13.4|0.9
    Drink soja- m suiker verrijkt m calcium en vitamines|Drink soya w sugar fortified w calcium and vitamins|Sojadrink gezoet verrijkt m calcium en vitamines|37|3|1.4|3|0.4
    Kaas 30+ gem|Cheese 30+ av|Kaas 30+ Milner/Beemster/Linessa e.d.|280|30.1|17.7|0|0
    Drop gem|Liquorice Dutch type av||333|8.4|0.4|73.2|1.5
    Gehaktbal runder- m ei gebakken|Minced beef ball prepared w egg/crumbs|Rundergehaktbal met ei gebakken|308|27|19.8|5.2|0.6
    Spek mager bereid|Bacon lean prepared||424|25.7|35.5|0.3|0
    Kipfilet bereid|Chicken fillet prepared||158|30.9|3.8|0|0
    Ui gebakken in plantaardige olie|Onions fried in vegetable oil|Uien gebakken|58|1.3|3|5.4|2.2
    Roggebrood volkoren/roggetarwebrood bruin gem|Rye bread wholemeal/rye wheat bread brown av|Roggebrood donker en licht gem|196|5.8|1.3|36.1|8.2
    Tomaat gestoofd|Tomatoes stewed w vegetable oil|Tomaten gestoofd|59|0.9|5.1|1.9|1.3
    Kool boeren- glas|Kale curly glass|Boerenkool glas|25|2.4|0.6|0.9|3
    Sla ijsberg- rauw|Lettuce iceberg raw|Ijsbergsla rauw|14|1|0.2|1.4|1.2
    Runderbiefstuk rauw|Beef rump steak raw||108|22.9|1.8|0|0
    Runderbiefstuk v de haas rauw|Beef tenderloin steak raw|Rundertournedos rauw/Ossenhaas rauw|116|23.7|2.3|0|0
    Runderentrecote rauw|Beef prime rib raw||165|23|8.1|0|0
    Runderbaklappen rauw|Beef frying steak raw||103|21.2|2|0|0
    Gehakt runder- rauw|Minced beef raw|Rundergehakt rauw|225|18.9|16.5|0.2|0.3
    Runderklapstuk rauw|Beef rib raw||137|19.8|6.4|0|0
    Lever runder- rauw|Liver ox raw|Runderlever rauw|129|21|4.2|1.9|0
    Runderpoulet rauw|Beef stewing meat raw||106|22.1|2|0|0
    Runderrollade rauw|Beef sirloin rolled raw|Runder lenderollade rauw|109|23.2|1.7|0.2|0.3
    Runderrosbief rauw|Beef roast raw||122|22.9|3.4|0|0
    Runderschenkel rauw|Beef shank raw||117|22.6|3|0|0
    Runderriblappen rauw|Beef rib steak raw||166|20.1|9.5|0|0
    Runder doorregen lappen rauw|Beef streaked/marbled raw||147|20.6|7.2|0|0
    Rundersukadelappen rauw|Beef stewing steak raw||135|21.3|5.5|0|0
    Rundertartaar rauw|Beef steak tartare raw||137|21.1|5.7|0.3|0.1
    Rundertong rauw|Beef tongue raw||188|17.3|13.2|0|0
    Varkensbraadworst rauw|Sausage pork Braadworst raw|Varkenssaucijs rauw|226|16.8|17.2|0.6|0.3
    Varkensfiletlappen rauw|Pork fillet raw||128|23.3|3.9|0|0
    Varkensfricandeau rauw|Pork fricandeau part of leg raw|Fricandeau varkens- rauw|120|22.9|3.2|0|0
    Varkenshamlappen rauw|Pork chop raw||114|22.2|2.8|0|0
    Gehakt varkens- rauw|Minced pork raw|Varkensgehakt rauw|177|20.1|10.7|0.3|0
    Varkenshaas rauw|Pork tenderloin raw||105|22.4|1.7|0|0
    Varkenshamschijf rauw|Pork gammon steak raw||191|19.8|12.4|0|0
    Varkenshaaskarbonade rauw|Pork loin chop raw||156|23.2|7|0|0
    Varkensschouderkarbonade rauw|Pork shoulder chop raw||186|19.1|12.2|0|0
    Lever varkens- rauw|Liver pork raw|Varkenslever rauw|129|21.3|4.8|0.2|0
    Varkenskrabbetjes rauw|Pork spare rib raw||250|18.3|19.6|0|0
    Varkensoester rauw|Pork tenderloin medaillon raw||115|23.5|2.4|0|0
    Varkensschouderlappen rauw|Pork shoulder raw||133|20.7|5.5|0|0
    Vink sla- rauw|Kromesky meat filled raw|Slavink rauw|266|15.3|21.2|3.3|0.4
    Speklap rauw|Bacon rasher raw||320|16.5|28.2|0|0
    Gehakt hoh rauw|Minced beef/pork raw|Half om half gehakt rauw|233|19.2|17.2|0.3|0.3
    Hamburger rauw|Hamburger raw||239|16.8|18|2.2|0.6
    Kalfsentrecote rauw|Veal prime rib raw||150|21.4|7.2|0|0
    Vink kalfs- rauw|Veal olive raw|Blinde vink kalfs- rauw/kalfsvink rauw|159|20.7|8.5|0|0
    Kalfsfricandeau rauw|Veal fricandeau raw||111|22|2.6|0|0
    Lever kalfs- rauw|Liver calf's raw|Kalfslever rauw|108|17.7|3.3|2|0
    Kalfsschenkel rauw|Veal shank raw||112|21.3|2.9|0|0
    Kalfstong rauw|Tongue calf raw||168|17.6|10.9|0|0
    Kalfszwezerik rauw|Sweetbread raw||89|18.4|1.7|0|0
    Lamsbout rauw|Lamb leg raw||174|19.2|10.8|0|0
    Gehakt lams-/schapen- rauw|Minced lamb raw|Lamsgehakt/schapengehakt rauw|218|19.3|15.7|0|0
    Lamskarbonade rauw|Lamb chop raw|Lamskotelet rauw|223|19.2|16.3|0|0
    Lamszadel rauw|Lamb saddle raw||256|18.6|20.2|0|0
    Lamsschouder rauw|Lamb shoulder raw||187|20|11.9|0|0
    Chocolade puur suikervrij|Chocolate dark sugar-free|Suikervrije pure chocolade|454|5.3|33|42.1|14.7
    Chocolade melk- m hazelnoten z suiker|Chocolate milk w hazelnuts wo sugar|Suikervrije melkchocolade m hazelnoten|498|8.9|35.4|46.5|8
    Biet rode zoetzuur glas|Beetroot pickled glass|Rode bieten zoetzuur glas/Kroten zoetzuur glas|37|0.5|0.1|7.6|1.8
    Aardappelpureepoeder gem|Potato puree powder av||368|8.6|4.6|70.2|6.3
    Frites voorgebakken diepvries onbereid|Chips pre-fried frozen unprepared|Patat/friet voorgebakken diepvries onbereid|146|2.3|3.8|24.4|2.5
    Aardappelen gebakken|Potatoes fried||119|1.8|4.8|16.5|1.5
    Seitan gekruid|Seitan seasoned|Seitan vegetarisch product|198|28.4|7.2|4|2.1
    Tarwekrentenbrood volkoren|Wheat currant bread wholemeal|Krentenbrood volkoren|253|9.3|1.9|46.2|7.1
    Koek ontbijt- gember|Cake Dutch spiced Ontbijtkoek w ginger|Ontbijtkoek met gember/Gemberkoek|318|2.7|2.1|70.7|2.6
    Pasta sesam- tahin m toegevoegd zout|Sesame paste tahin salt added|Sesampasta tahin|585|21.9|51.7|1.8|12.4
    Sap ananas-|Juice pineapple|Ananassap|47|0.5|0|11.2|0.3
    Vruchtendrank 2 of meer vruchten|Fruit juice drink minimal 2 fruits|Multivruchtendrank/duodrank|43|0.2|0|10.7|0.1
    Melk chocolade- halfvolle|Milk chocolate-flavoured semi-skimmed|Chocolademelk halfvolle|76|3.3|1.6|11.9|0.5
    Likeur <15 vol% alc|Liqueur <15 vol% alcohol|Likoret e.d.|200|0|0|29|0
    Likeur >25 vol% alc|Liqueur >25 vol% alcohol|Amaretto e.d./Grand marnier e.d./Cointreau e.d.|291|0|0|29|0
    Bier zwaar >7 vol% alcohol|Beer >7 vol% alcohol||64|0.5|0|4.3|0.3
    Room banketbakkers-|Cream custard|Banketbakkersroom/gele room|143|3.6|4.1|22.9|0.2
    Berliner bol|Berliner pastry||293|5.3|10|44.4|1.7
    Biscuit m chocolade|Biscuit w chocolate|Chocoladebiscuit|479|7.3|20|65.8|3.2
    Creme au beurre|Butter cream|Botercreme|567|0.6|44.8|40.4|0
    Donut ongevuld|Doughnut plain||358|6|21.1|35.5|1.1
    IJs water-|Ice lolly|Waterijs|75|0.2|0.2|18|0.2
    Soes slagroom-|Eclair w whipped cream filling|Slagroomsoes|283|4.1|22.9|15.1|0.4
    Taart schuim- m creme au beurre|Meringue w butter-cream|Schuimtaart/schuimgebak m creme au buerre|391|4.6|18.7|50.7|1
    Koekje suikervrij|Biscuits sugar-free||433|6.6|21.4|63.7|3.4
    Vlaai kruimel- m vruchten|Flan fruit and crumble topping|Kruimelvlaai|199|3.3|6.4|30.9|1.7
    Taart Mon Chou-|Cheesecake made w cream cheese|Gebak mon chou|330|2.5|20.5|33.2|1.2
    Koekje PiM's sinaasappel|Biscuit Jaffa cakes/Cake PiM's|Lu pim's original|373|3.6|12.5|60|2.9
    Wafel rijst- naturel m (zee)zout|Rice cakes puffed natural w (sea)salt|Rijstwafel naturel met (zee)zout|392|7.8|3.2|81.3|3.5
    Uitjes gebakken kant-en-klaar|Onions crisp fried ready-to-eat|Fruitjes kant-en-klaar|590|6|44|40|4.9
    Kaas Brie 60+|Cheese Brie 60+||369|17|33|1|0
    Kaassouffle diepvries onbereid|Pastry puff cheese filled frozen unprepared||304|8.1|15.4|32.8|1.1
    Kaas verse light 8% vet|Cheese fresh light 8% fat|Kaas verse light boursin/paturain e.d.|132|11.3|8.5|2.5|0
    Jus gem ongebonden bereid z juspoeder|Gravy average clear prep wo gravy instant powder||340|0.2|37.6|0.3|0
    Salade vis- lunch/borrel|Salad fish|Vissalade lunch/borrel|304|8.6|26.8|6.9|0.3
    Salade ham-prei- lunch/borrel|Salad ham and leek|Ham-preisalade lunch/borrel|243|3.6|21.9|7|1.9
    Salade kip-kerrie- lunch/borrel|Salad chicken curry|Kip-kerriesalade lunch/borrel|285|8.8|24.3|6.9|1.8
    Salade ei- lunch/borrel|Salad egg|Eiersalade/eisalade lunch/borrel|255|7.3|22.3|5.6|1.3
    Mix kruiden- m gedroogde groente onbereid|Herb and dried vegetable mix unprepared|Mix voor macaroni/spaghetti/chili con carne e.d.|311|9.5|3.8|57|5.2
    Yoghurt halfvolle|Yoghurt half fat||50|4.2|1.5|4.3|0
    Chips light naturel|Crisps potato light unflavoured||490|7.3|22|63.5|4.2
    Soesje kaas-|Eclair cheese cream filled|Kaassoesje|317|6|28.5|8.6|0.5
    Borstplaat room-|Fondant cream||346|0.7|3.1|79|0
    Bonbon|Chocolates filled/Belgium chocolate||512|5.5|30.7|51.8|3.3
    Mueslireep m chocolade|Muesli bar w chocolate|Chocolademueslireep|472|7.9|20.2|61.7|5.8
    Schnitzel vegetarisch obv soja/tarwe onbereid verrijkt m ijzer en vit B12|Schnitzel vegetarian based on soya/wheat unprepared fortified w iron and vit B12||192|15.5|7|14.5|4.7
    Saus op basis roux bereid|Sauce based on roux prepared||84|2.4|5.3|6.5|0.2
    Saus op basis groentenat/melk bereid z vet|Saus op basis groentenat/melk bereid z vet||46|2.2|0.9|7.2|0.1
    Saus op basis pakje <3% vet bereid|Sauce mix packet <3% fat prepared||62|1.7|1.4|10.6|0.2
    Saus op basis pakje >3% vet bereid|Sauce mix packet >3% fat prepared||76|1.2|4.4|7.8|0.2
    Bier alcoholvrij <0,1 vol% alcohol|Beer alcohol free <0,1 vol%|Maltbier|26|0.3|0|6.1|0.1
    Bier alcoholarm 0,1-1,2 vol% alcohol|Beer low alcohol 0,1-1,2 vol%||22|0.3|0|4.5|0.3
    Limonade vruchten- light|Juice drink light|Frisdrank light sinas, cassis, bitter lemon e.d.|3|0|0|0.7|0
    Frisdrank light z cafeine|Soft drink light wo caffeine|Cola light z cafeine/7-up e.d. light/tonic light|0|0|0|0|0
    Frisdrank light m cafeine|Cola light soft drink w caffeine|Cola light m cafeine|0|0|0|0|0
    Saus tomaten- kant-en-klaar glas|Sauce tomato ready-to-eat jar|Tomatensaus kant-en-klaar|68|1.6|3.3|6.9|1.8
    Bouillon v blokje bereid|Stock from cube prepared||5|0.1|0.3|0.3|0
    Boterproduct halfvolle|Butter product half fat||337|0.3|37|0.7|0
    Runderbiefstuk bereid|Beef rump steak prepared||146|29.3|3.2|0|0
    Runderentrecote bereid|Beef prime rib prepared||192|31|7.5|0|0
    Runderbaklappen bereid|Beef frying steak prepared||140|27.5|3.3|0|0.2
    Gehakt runder- rul gebakken|Minced beef shallow fried|Rundergehakt rul bereid|331|30.4|23.1|0.3|0
    Runderklapstuk bereid|Beef rib prepared||187|29.6|7.6|0|0.1
    Lever runder- bereid|Liver ox prepared|Runderlever bereid|161|28.1|5.4|0|0.2
    Runderpoulet bereid|Beef stewing meat prepared||216|30.9|10.2|0|0.1
    Runderrollade gebakken|Beef rolled prepared|Runder lenderollade bereid|157|33.5|2.3|0.2|0.5
    Runderrosbief bereid|Beef roast prepared||156|27.2|5.1|0.2|0
    Runderschenkel bereid|Beef shank prepared||140|27.5|3.3|0|0.2
    Runderriblappen bereid|Beef rib steak prepared||230|34.1|10.4|0|0
    Runder doorregen lappen bereid|Beef streaked/marbled prepared||212|34.6|8.2|0|0
    Rundersukadelappen bereid|Beef stewing steak prepared||189|33.4|6.1|0|0
    Rundertartaar bereid|Beef steak tartare prepared||186|30.1|7.2|0.3|0
    Varkensbraadworst bereid|Sausage pork Braadworst prepared|Varkenssaucijs bereid|246|22.4|17.1|0.6|0
    Varkensfiletlappen bereid|Pork fillet prepared||157|28.7|4.7|0|0.1
    Varkensfricandeau bereid|Pork fricandeau part of leg prepared||158|31.2|3.7|0|0
    Varkenshamlappen bereid|Pork chop prepared||167|31.1|4.7|0|0
    Gehakt varkens- gebakken|Minced pork prepared|Varkensgehakt bereid|243|26.4|15.2|0.2|0.1
    Varkenshaas bereid|Pork tenderloin prepared||142|28.7|3|0|0.1
    Varkenshamschijf bereid|Pork gammon steak prepared||308|37.1|17.7|0|0
    Varkenshaaskarbonade bereid|Pork loin chop prepared||179|28.5|7.3|0|0.1
    Varkensschouderkarbonade bereid|Pork shoulder chop prepared||308|37.1|17.7|0|0
    Lever varkens- bereid|Liver pork prepared|Varkenslever bereid|164|27.9|5.8|0|0.1
    Varkenskrabbetjes bereid|Pork spare rib prepared||246|22.4|17.1|0.6|0
    Varkensoester bereid|Pork tenderloin medaillon prepared||142|28.7|3|0|0.1
    Varkensschouderlappen bereid|Pork shoulder prepared||170|27.6|6.6|0|0
    Vink sla- gebakken|Kromesky meat filled prepared|Slavink bereid|277|20.7|21.1|1|0
    Gehaktbal hoh m ei gebakken|minced meat ball beef/pork w egg prepared|Half om half gehaktbal bereid|262|20.5|17.4|5.3|1.1
    Hamburger bereid|Hamburger prepared||255|22.5|17.9|0.9|0.1
    Kalfsentrecote bereid|Veal prime rib prepared||166|27.5|6.3|0|0
    Vink kalfs- gebakken|Veal olive prepared|Blinde vink kalfs- bereid/kalfsvink bereid|186|30.1|7.2|0.3|0
    Kalfsfricandeau bereid|Veal fricandeau prepared||121|25.2|2.2|0|0
    Lever kalfs- bereid|Liver calf's prepared|Kalfslever bereid|172|27.9|5.8|2|0.1
    Kalfsschenkel bereid|Veal shank prepared||140|27.5|3.3|0|0.2
    Lamsbout bereid|Lamb leg prepared||256|25.6|17.1|0|0
    Gehakt lams- gebakken|Minced lamb prepared|Lamsgehakt bereid|252|30.4|14.4|0.3|0
    Lamskarbonade bereid|Lamb chop prepared|Lamskotelet bereid|350|25.8|27.5|0|0
    Lamszadel bereid|Lamb saddle prepared||308|24.7|23.2|0|0
    Lamsschouder bereid|Lamb shoulder prepared||284|27.9|19.1|0|0
    Mosselen gebakken/gefrituurd in plantaardige olie|Mussels fried in vegetable oil||268|17.2|19|7.2|0
    Inktvisringen gefrituurd in plantaardige olie|Squid rings deep-fried in vegetable oil||440|26.2|31.1|13.8|0.2
    Heilbot gerookt|Halibut smoked||211|19.4|14.8|0|0
    Makreelfilet gerookt|Mackerel fillet smoked||301|21.1|24.1|0|0
    Zalm kweek- rauw|Salmon farmed raw||179|20|11|0|0
    Ansjovis in olie blik|Anchovy in oil canned||208|25|11.9|0.1|0.1
    Tonijn in olie blik|Tuna in oil tinned||206|27|10.8|0.1|0.1
    Tonijn in water blik|Tuna in water tinned||109|24.9|1|0|0
    Fructosepoeder|Fructose powder||396|0|0|99|0
    Gehaktbal runder- z ei gebakken|Minced beef ball prepared wo egg|Rundergehaktbal z ei gebakken|304|26.5|19.4|5.5|0.6
    Bokking gestoomd|Kippers steamed|Warm gerookte haring|231|20.8|16.2|0.5|0
    Sprotfilet gerookt|Sprat fillet smoked||212|19.9|14.8|0|0
    Makreel bereid in magnetron z toev|Mackerel prepared in microwave oven no ingredients added||248|24.4|16.7|0|0
    Makreel in olie blik|Mackerel in oil tinned||267|20|20.7|0.1|0.1
    Zalm kweek- bereid in magnetron z toev|Salmon farmed prep in microwave oven no ingredients added||220|25.2|13.2|0|0
    Forel bereid in magnetron z toev|Trout prepared in microwave oven no ingredients added||140|24.5|4.6|0|0
    Forel regenboog- bereid in magnetron z toev|Rainbow trout prepared in microwave oven no ingredients added|Regenboogforel/zalmforel bereid in magnetron|167|23.7|8|0|0
    Kabeljauw bereid in magnetron z toev|Cod prepared in microwave oven no ingredients added||98|23.5|0.4|0|0
    Schelvis bereid in magnetron z toev|Haddock prepared in microwave oven no ingredients added||100|22.3|1.2|0|0
    Koolvis (Atlantisch) bereid in magnetron z toev|Pollack (Atlantic) prep in microwave oven no ingredients added||108|24.5|1.2|0|0
    Wijting bereid in magnetron z toev|Whiting prepared in microwave oven no ingredients added||101|22.1|1.4|0|0
    Schol bereid in magnetron z toev|Plaice prepared in microwave oven no ingredients added||140|29|2.6|0|0
    Schar/tongschar bereid in magnetron z toev|Schar/tongschar bereid in magnetron z toev||119|23.9|2.6|0|0
    Tong bereid in magnetron z toev|Sole prepared in microwave oven no ingredients added||116|24.5|2.1|0|0
    Bot bereid in magnetron z toev|Flounder prepared in microwave oven no ingredients added||106|21.9|2|0|0
    Poon bereid in magnetron z toev|Gurnard prepared in microwave oven no ingredients added||171|26.1|7.4|0|0
    Baars rood- bereid in magnetron z toev|Ocean perch prepared in microwave oven no ingredients added|Roodbaars bereid in magnetron|128|22.3|4.3|0|0
    Zeewolf bereid in magnetron z toev|Wolf fish prepared in microwave oven no ingredients added||127|25.2|2.9|0|0
    Paling bereid in magnetron z toev|Eel prepared in microwave oven no ingredients added||207|24.3|12.2|0|0
    Paling zee- bereid in magnetron z toev|Paling zee- bereid in magnetron z toev||199|24.3|11.4|0|0
    Kuit/hom gebakken|Soft/hard roe fried||262|13.9|21.2|3.9|0.2
    Kuit/hom v bokking|Soft/hard roe from fat bloater||155|24.5|6.3|0|0
    Kuit vis- gekleurd glas|Spawn/hard roe coloured glass|Kaviaar surrogaat/viskuit gekleurd|126|19|5.5|0|0
    Mosselen in zuur glas|Mussels pickled glass||106|17.2|3.1|2.2|0
    Garnalen in water blik|Shrimps in water tinned||115|24.3|1.9|0.1|0
    Inktvis pijl- bereid in magnetron z toev|Squid prepared in microwave oven no ingredients added||146|25.8|4.7|0|0
    Kip m vel bereid|Chicken w skin prepared||226|25.3|13.8|0|0
    Kipfilet rauw|Chicken fillet raw||109|23.3|1.8|0|0
    Kip z vel bereid|Chicken wo skin prepared||183|27.3|8.2|0|0
    Kiprollade bereid|Chicken rolled prepared||166|24|7|1.7|0
    Kiprollade rauw|Chicken rolled raw||175|20.6|10.3|0.2|0
    Kipnuggets bereid in oven|Chicken nuggets prepared in oven||259|14.4|13.7|18.4|2.5
    Kipnuggets bereid m frituurvet|Chicken nuggets prepared in frying fat|Kipnuggets gefrituurd|277|17.5|17.1|12.2|2.5
    Kipburger gepaneerd bereid|Chicken burger breaded prepared||307|14.5|23.2|9.9|0
    Varkenslappen bereid|Pork steak/chop prepared||204|29.8|9.2|0.4|0
    Varkensribkarbonade bereid|Pork rib chop prepared|Varkenskotelet bereid|177|28.4|7.1|0|0.1
    Kaas geiten- verse|Cheese goat fresh|Geitenkaas naturel vers|207|13.4|16.6|1|0
    Stroop gerstemout-|Syrup barley malt|Gerstemoutstroop|283|4.4|0|66.4|0
    Stroop maismout-|Syrup corn|Maismoutstroop|287|2.3|0|69.4|0
    Stroop rijstmout-|Syrup rice malt|Rijstmoutstroop|292|0.3|0|72.6|0
    Diksap geconcentreerd|Fruit juice concentrated|Limonadesiroop diksap geconcentreerd|242|0.2|0|60|0.4
    Sap wortel-|Juice carrot|Wortelsap|29|0.4|0.2|6.4|0
    Sap zuurkool-|Juice sauerkraut|Zuurkoolsap|7|0.7|0|1.1|0
    Rundvlees <5 g vet rauw gem|Beef <5% fat raw av||108|22.6|2|0|0
    Rundvlees >5 g vet rauw gem|Beef >5% fat raw av||218|18.4|15.3|1.5|0.4
    Rundvlees <10 g vet bereid gem|Beef <10% fat prepared av||163|30.2|4.7|0|0
    Rundvlees >10 g vet bereid gem|Beef >10% fat prepared av||290|26.9|19.7|1.2|0.1
    Varkensvlees <5 g vet rauw gem|Pork <5% fat raw av||126|21.8|3|2.8|0.3
    Varkensvlees 5-14 g vet rauw gem|Pork 5-14% fat raw av||165|20|9.1|0.5|0.3
    Varkensvlees >15 g vet rauw gem|Pork >15% fat raw av||283|16.1|24|0.5|0.2
    Varkensvlees <10 g vet bereid gem|Pork <10% fat prepared av||158|28.8|4.7|0|0.1
    Varkensvlees 10-19 g vet bereid gem|Pork 10-19% fat prepared av||260|28.4|16.1|0.3|0
    Varkensvlees >19 g vet bereid gem|Pork >19% fat prepared av||365|21.2|30.5|1.1|0.2
    Kalfsvlees <5 g vet gem rauw|Veal <5% fat raw av||105|22|1.8|0|0
    Kalfsvlees >5 g vet gem rauw|Veal >5% fat raw av||159|20.4|8.6|0|0
    Lamsvlees >10 g vet rauw gem|Lamb >10 g fat raw av||221|19.3|16|0|0
    Vlees <5 g vet excl lever rauw gem|Meat av raw <5% fat excl liver||113|22.8|2.1|0.7|0.1
    Vlees >5 g vet excl lever rauw gem|Meat av raw >5% fat excl liver||211|18.6|14.7|1.1|0.3
    Aardappelschijfjes diepvries gefrituurd in plantaardige olie|Potatoes sliced frozen deep-fried in vegetable oil|Aardappelpartjes/-schijfjes diepvries gefrituurd|229|3.1|10.9|28|3.2
    Frites oven- diepvries bereid in oven|Chips oven frozen prepared in oven|Patat/ovenfriet diepvries bereid in oven|213|3.8|6.6|32.6|4.2
    Aardappelkroketten diepvries bereid|Potato croquettes frozen prepared||239|3.4|12|28.2|2.2
    Koekje kaas-|Biscuits & snacks cheesy|Kaaskoekje/Kaaszoutje/Kaas-krakeling/stengel/bolletje|495|13.3|30.1|41.9|1.8
    Melk halfvolle verrijkt m calcium|Milk semi-skimmed fortified w calcium|Calciumverrijkte melk halfvolle|46|3.4|1.5|4.9|0
    Vla volle overige smaken|Custard several flavours full fat||87|2.1|2.6|13.6|0.5
    Yoghurt vanille- halfvolle|Yoghurt vanilla half fat|Vanilleyoghurt halfvol|72|2.9|1.3|11.4|0.3
    Pap griesmeel-|Porridge semolina|Griesmeelpap|93|3|2.9|14|0.1
    Kaas 20+|Cheese 20+||246|34.5|12|0|0
    Kaas 50+|Cheese 50+||380|22.9|32.1|0|0
    Kaas gaten- Hollandse 45+|Cheese Dutch in Swiss-style 45+|Hollandse gatenkaas Maasdammer/Leerdammer e.d.|370|27.6|28.5|0|0
    Kaas 40+ Leidse/Friese nagel-|Cheese 40+ Leiden w cumin/Fries clove|Nagelkaas friese/leidse 40+|341|27.3|25.7|0|0
    Babyvoeding fruit 12 mnd|Infant food fruit 12 months|Olvarit e.d. fruithapje/moes/puree 12 mnd|64|0.6|0.1|14.4|1.6
    Leverkaas/Berliner leverworst|Liver pate/Berliner liver sausage||319|12.3|27.6|4.5|0.2
    Varkensfricandeau gebraden (vleeswaar)|Pork fricandeau fried (processed meat product)|Gebraden fricandeau (vleeswaar)|117|21.6|2.8|1.3|0.4
    Zult zure|Brawn, pork pickled in vinegar|Zure zult/hoofdkaas|264|12.5|23|1.7|0
    Worst tongen-|Sausage tongue|Tongenworst|247|17.2|18.8|2|0.1
    Spek ontbijt- gegrild|Bacon rasher streaky grilled|Ontbijtspek gegrild|261|15.2|22.1|0.5|0
    Ham achter- gegrild|Ham lean grilled|Achterham gegrild|119|18.9|3.9|1.8|0.1
    Ham been-|Gammon boiled deboned|Beenham|127|18.3|5|2.2|0.1
    Knackebrod volkoren|Crispbread wholemeal|Cracker knackebrod volkoren|363|10.9|4|64|13.7
    Varkensribkarbonade rauw|Pork rib chop raw|Varkenskotelet rauw|150|22.6|6.6|0|0
    Varkensschnitzel ongepaneerd bereid|Pork schnitzel not breaded prepared||142|28.3|3.2|0|0.1
    Varkensschnitzel ongepaneerd rauw|Pork schnitzel not breaded raw||109|22.6|2|0|0
    Room spuitbus m suiker|Cream whipped w sugar canned||305|2.3|28|11|0
    Knackebrod Sandwich Wasa|Crispbread Sandwich Wasa|Cracker knackebrod sandwich wasa|476|10.7|25|46.8|10.3
    Saus oosterse kant-en-klaar glas/zak|Sauce oriental ready-to-eat jar/bag|Orientaalse saus kant-en-klaar glas/zak|64|1.5|0.4|13.3|0.7
    Creme fraiche|Creme fraiche||293|2.6|30|2.8|0
    Kaas 45+|Cheese 45+||357|25.4|27.3|0|0
    Siroop vruchtenlimonade- Karvan Cevitam|Fruit drink concentrate Karvan Cevitam|Limonadesiroop/ranja Karvan Cevitam|177|0.1|0|44|0.1
    Kousenband gekookt|Beans long yard Kousenband boiled|Bonen kousenband gekookt|29|2.7|0.2|2.5|3.5
    Nectarine|Nectarine||36|1|0.1|6.5|1.1
    Melkdrank Yakult original|Milk based drink Yakult original||66|1.3|0|15|0
    Yoghurtdrank Vifit vruchten|Yoghurt drink Vifit fruit|Drinkyoghurt vifit vruchten|55|3.1|0.8|8.3|1
    Salade komkommer- lunch/borrel|Salad cucumber|Komkommersalade lunch/borrel|238|0.8|23|6.5|0.5
    Salade vlees- lunch/borrel|Salad meat|Vleessalade lunch/borrel|286|5|25.7|8.2|0.4
    Vruchtendrank Roosvicee Multivit|Fruit juice drink Roosvicee Multivit||36|0.1|0.1|8.6|0
    Aroma strooi- natriumarm|Seasoning flavoured powder low sodium|Aromat e.d. smaakverfijner natriumarm|235|22.1|3.6|27.9|1.1
    Bouillonpoeder natriumarm|Stock powder low sodium||348|5.3|6.3|67.4|0.6
    Water gem|Water av|Kraanwater gem|0|0|0|0|0
    Chutney mango-|Mango chutney|Mangochutney|215|0.7|0.1|52|1.4
    Dadels vers|Dates fresh|Verse dadels|139|1.5|0.1|31.3|3.6
    Carambola|Carambola|Stervrucht/Sterfruit|37|0.5|0.3|7.2|1.7
    Couscous rauw|Couscous unprepared|Couscous onbereid|363|12|2.1|72.1|3.7
    Gerst hele korrel rauw|Barley whole grain raw|Gerstekorrels onbereid|330|10.6|2.1|59.7|14.8
    Mierikswortel rauw|Horse-radish raw||80|4.5|0.3|11|7.5
    Paksoi rauw|Cabbage pak-choi raw||14|1|0.2|1.4|1.2
    Kaas Bel Paese|Cheese Bel Paese||374|25.4|30.2|0.1|0
    Bonen kidney- rode gedroogd|Beans kidney red dried|Rode kidneybonen gedroogd|295|22.1|1.4|36.9|23.4
    Noten pecan- ongebrand ongezouten|Pecan nuts unroasted unsalted|Pecannoten ongezouten|721|9.2|72|4.4|9.6
    Noten pistache- gezouten|Pistachio nuts salted|Pistachenoten gezouten|592|23.8|48.3|10.8|9.5
    Zeewier kelp rauw|Seaweed kelp raw||47|1.7|0.6|8.3|1.3
    Zeewier agar agar gedroogd|Seaweed agar agar dried||336|6.2|0.3|73.2|7.7
    Jacobsschelpen rauw|Coquilles scallop shell St. Jacques raw||83|16.8|0.8|2.4|0
    Geitenvlees rauw gem|Goat meat raw av||103|20.6|2.3|0|0
    Nier varkens- rauw|Kidney pork raw||86|15.5|2.7|0|0
    Nier runder- rauw|Kidney ox raw||88|17.2|2.1|0|0
    Nier lams- rauw|Kidney lamb raw||91|17|2.6|0|0
    Groenten gekookt gem|Vegetables av boiled||30|1.7|0.4|3.6|2.4
    Groenten rauw gem|Vegetables av raw||20|1|0.4|2.6|1.4
    Fruit vers incl citrus- gem|Fruit fresh av including citrus||61|0.7|0.2|12.8|1.7
    Vleeswaren excl leverproducten gem|Processed meat prod excl liver av||230|16.9|16.7|2.6|0.2
    Vleeswaren <10 g vet excl leverprod gem|Processed meat prod <10 g fat excl liver av||133|18.4|5.3|2.5|0.1
    Worst excl leverproducten gem|Sausage excl liver products av||352|16.3|30.7|2.5|0.3
    Vleeswaren 20-30 g vet excl leverprod gem|Processed meat prod 20-30 g fat excl liver av||311|13.8|26.9|3.2|0.1
    Vleeswaren >30 g vet excl leverprod gem|Processed meat prod >30 g fat excl liver av||395|17.6|35.1|2|0.3
    Saus Chinese zoetzure huishoudelijk bereid|Sauce Chinese soursweet home-made||32|0.4|0.3|6.9|0.2
    Saus sate- huishoudelijk bereid m water m vet|Peanut sauce homemade w water w fat|Satesaus/pindasaus huish bereid m water m vet|295|8.7|23.3|10.8|3.2
    Brooddeeg (bodem voor pizza/hartige taart) onbereid|Dough for pizza and savoury pie unprepared|Pizzabodem|231|5.6|5.9|37.6|2.3
    Soes ongevuld|Eclair wo filling||223|6|15.9|13.8|0.8
    Room slag- geklopt m suiker|Cream whipped w added sugar|Slagroom geklopt m suiker|348|2|30.4|16.5|0
    Vlaaibodem Limburgse|Flan bottom Limburg||297|7.3|10.9|41.3|2.3
    Sap sinaasappel- m vruchtvlees|Juice orange w pulp|Sinaasappelsap/jus d'orange m vruchtvlees|42|0.7|0|8.7|0.4
    Sap tomatengroenten- Appelsientje Tomatientje|Juice tomato/vegetable Appelsientje Tomatientje|Tomatengroentensap Appelsientje Tomatientje|14|0.7|0|2.5|0.8
    Sap tomaten- Appelsientje Zontomaat|Juice tomato Appelsientje Zontomaat|Tomatensap Appelsientje Zontomaat|17|0.9|0|2.8|0.9
    Noten gemengd gezouten|Nuts mixed salted||656|18.3|58.3|11|6.8
    Kalkoenfilet rauw|Turkey fillet raw||110|24.8|1.2|0|0
    Chips tortilla naturel|Crisps tortilla unflavoured|Maischips/mais-chips/tacoschelp/tortillachips|480|6.8|22|61.8|4.3
    Saus sate- op basis pakje bereid|Peanut sauce packet prepared|Satesaus/pindasaus op basis pakje bereid|148|4.2|5.6|19.8|1
    Kaas blauwschimmel Gorgonzola|Cheese Gorgonzola||359|19.4|31.2|0.1|0
    Zoutjes Japanse mix m pinda's|Japanese rice cracker mix w peanuts||421|10.9|8|75.6|1.6
    Broodje pudding-|Bun w vanilla custard|Puddingbroodje|214|5.2|4.3|38|1.4
    Plantaardig alternatief voor vruchten-/vanilleyoghurt obv soja m suiker verrijkt m calcium en vitamines|Plant-based alternative to fruit/vanilla yoghurt based on soya sweetened fortified w calcium and vitamins|Yoghurtvariatie obv soja m vruchten/vanile|66|3.4|1.7|8.7|0.8
    Kaas Mozzarella gemaakt v koemelk|Cheese Mozzarella made from cow's milk||253|18.7|19.5|0.7|0
    Halvarineproduct Becel pro-activ|Low fat spread Becel pro-activ||362|0.3|40|0.3|0.2
    Vla slagroom-|Custard of milk and whipped cream|Slagroomvla|120|2.7|5.4|15.1|0
    Pap karnemelkse gorte-|Porrdige buttermilk groats|Karnemelkse gortepap|53|3.6|0.5|8.1|0.3
    Halvarineproduct Blue Band Goede Start|Low fat margarine prod Blue Band Goede Start||347|0.3|38|1.1|0
    Hagelslag chocolade- melk|Chocolate sprinkles milk|Chocoladehagelslag melk|455|6.3|15.6|70.3|3.7
    Hagelslag chocolade- puur|Chocolate sprinkles dark|Chocoladehagelslag pure|446|5.8|15.3|67.4|6.6
    Pasta chocolade- melk|Spread chocolate milk|Chocoladepasta melk|570|2.4|35|61|0.5
    Biscuit melk- Liga Milkbreak|Biscuit Liga Milkbreak milkbiscuit|Melkbsicuit Liga Milkbreak|444|9.2|17|62|3
    Cake m roomboter|Cake made w butter||401|5.8|22.7|42.9|1
    Koekje roomboter- gem|Biscuits assorted w butter av|Roomboterkoekje|448|5.3|20.1|60.7|1.7
    Ontbijtproduct Olvarit pap 8 granen 12+ mnd|Breakfast cereal porridge Olvarit 8 granen 12+ months|Ontbijtgranen Olvarit pap 8 granen 12+ mnd|378|11.5|2.2|72.6|10.7
    Ontbijtproduct Frosties Kellogg's|Breakfast cereal Frosties Kellogg's|Ontbijtgranen Frosties Kellogg's|375|4.5|0.6|87|2
    Ontbijtproduct Coco pops Kellogg's|Breakfast cereal Coco pops Kellogg's|Ontbijtgranen Coco Pops Kellogg's|386|6.3|1.9|84|3.8
    Ontbijtproduct All-Bran Fruit 'n Fibre Kellogg's|Breakfast cereal All-Bran Fruit n Fibre Kellogg's|Ontbijtgranen All-bran fruit 'n fibre Kellogg's|380|8|6|69|9
    Ontbijtproduct Special K Original Kellogg's|Breakfast cereal Special K Original Kellogg's|Ontbijtgranen Special K original Kellogg's|392|8|1.3|84|6
    Ontbijtproduct Smacks Kellogg's|Breakfast cereal Smacks Kellogg's|Ontbijtgranen Smacks Kellogg's|377|7.1|1.6|81|5
    Ontbijtproduct Honey pops Loops Kellogg's|Breakfast cereal Honey pops Loops Kellogg's|Ontbijtgranen honey loops Kellogg's|396|9.3|4.4|76|7.5
    Taart vruchten- v zandgebak|Tart fruit w shortbread base|Vruchtengebak van zandtaartdeeg|248|3.1|11.8|31.3|1.7
    Taart vruchten- v cakedeeg|Sponge cake w fruit|Vruchtengebak van cakedeeg|197|2.6|9.2|25.1|1.6
    Gehakt fijn- vegetarisch obv mycoproteine onbereid|Minced meat vegetarian based on mycoprotein unprepared|Quorn fijngehakt|95|14.1|2.5|0.7|6.5
    Stukjes vegetarisch obv mycoproteine onbereid|Pieces/chunks vegetarian based on mycoprotein unprepred|Quorn vegetarische stukjes|86|12.6|2.1|1.5|5.5
    Sportdrank AA-Drink Isotone|Sports drink AA Isotone||23|0|0|5.7|0
    Sportdrank hypertone m koolhydraten|Sports drink hypertone w carbohydrates||59|0|0|14.8|0
    Gehakt fijn- vegetarisch obv soja onbereid|Minced meat vegetarian based on soya unprepared||148|20|3|5.8|8.9
    Pinda's dry roasted|Peanuts dry roasted|Aardnoten dry roasted|577|24|47|11|7
    Rijst meergranen- rauw|Rice multi-grain raw|Meergranenrijst onbereid|351|9|1.5|74|2.7
    Ontbijtproduct Brinta Wake Up drinkontbijt|Breakfast cereal Brinta Wake Up breakfastdrink|Ontbijtgranen Brinta Wake Up drinkontbijt|350|5.7|1.2|72.5|13.4
    Babyvoeding fruit 6 mnd|Infant food fruit 6 months|Olvarit e.d. fruithapje/moes/puree 6 mnd|65|0.6|0.2|14.5|1.4
    Lamsvlees <10 g vet rauw gem|Lamb <10 g fat raw av||158|20.7|8.3|0|0
    Schapenvlees <10 g vet gem rauw|Mutton <10g fat raw av||160|20.5|8.7|0|0
    Halvarine 40% vet <17 g verz vetz gezouten|Low fat margarine 40% fat <17 g sat fa salted||356|0.1|39.2|0.5|0.1
    Halvarineproduct 35% vet <10g verz vetz ongezouten|Low fat margarine prod 35% fat <10 g sat fa unsalted||320|0|35|1.2|0
    Margarine 80% vet >24 g verz vetz gezouten|Margarine 80% fat >24 g sat fa salted||719|0.1|79.7|0.3|0
    Bak- en braadvet vloeib 97% vet <17g verz vetz gezouten|Cooking fat liquid 97% fat <17 g sat fa salted||878|0.5|96.9|0.9|0
    Bak- en braadvet vast 97% vet >17 g verz vetz gezouten|Cooking fat solid 97% fat >17 g sat fa salted||873|0.3|96.7|0.5|0
    Vet frituur- vloeibaar|Frying fat liquid|Frituurvet vloeibaar|900|0|100|0|0
    Vet frituur- vast|Frying fat solid|Frituurvet vast|900|0|100|0|0
    Margarineproduct 60% vet <17 g verz vetz ongez|Margarine product 60% fat <17 g sat fa unsalted||541|0.1|60|0.1|0
    Margarine vloeibaar 80% vet <17 g verz vetz gezouten|Margarine liq 80% fat <17 g sat fa salted||735|0|81.6|0|0
    Drinkontbijt Coolbest FruitOntbijt|Breakfast drink Coolbest FruitOntbijt||53|0.8|0.2|11.6|1
    Ontbijtproduct Cornflakes|Breakfast cereal Cornflakes|Ontbijtgranen cornflakes|373|7.1|0.6|82.7|4
    Mayonaiseproduct m olijfolie|Mayonnaise product w olive oil||642|1.1|70|1.9|0.1
    IJsthee m suiker 5-<7 g KH|Ice tea w sugar 5-<7 g CHO|Frisdrank icetea 5-<7 g KH|25|0|0|6.2|0
    IJsthee light|Ice tea light|Frisdrank icetea light|2|0.1|0.1|0.2|0
    IJsthee m suiker en zoetstof|Ice tea w sugar and sweetener|Frisdrank icetea m suiker en zoetstof|18|0.1|0.1|4.1|0
    Struisvogelvlees rauw|Ostrich, raw||121|22.9|3.1|0.4|0
    Kip drumstick m vel rauw|Chicken drumstick w skin raw||147|19.1|7.9|0|0
    Frites bereid m hard vet|Chips fried in solid frying fat|Patat/friet bereid m hard vet|256|3.1|13.9|28|3.2
    Frites bereid m vloeibaar vet|Chips fried in liquid frying fat|Patat/friet gefrituurd in vlb vet/Frites snackbar|264|3.1|14.8|28|3.2
    Frites bereid gem|Chips prepared av|Patat/friet bereid gem|263|3.1|14.7|28|3.2
    Cassave gekookt|Cassava boiled|Maniokwortel gekookt|128|0.5|0.2|30.4|1.5
    Taro gekookt|Taro boiled|Chinese tajer gekookt/Chinese tayer gekookt|102|1.2|0.2|22.4|3
    Yam gekookt|Yam boiled||144|1.7|0.3|33|1.4
    Aardappel zoete gekookt|Potato sweet boiled|Bataat zoete gekookt|63|1.7|0.2|12.3|2.7
    Pompoen gekookt|Pumpkin boiled||14|0.6|0.3|1.8|1.1
    Limonade vruchten- Dubbelfrisss|Juice drink Dubbelfrisss|Frisdrank Dubbelfrisss|22|0|0|5.5|0
    Limonade vruchten- Tintelfruit m suiker|Juice drink Tintelfruit w sugar|Frisdrank Tintelfruit m suiker|22|0|0|5.4|0
    Limonade vruchten- Tintelfruit light|Juice drink Tintelfruit light|Frisdrank light Tintelfruit|12|0|0|2.9|0
    Mineraalwater m zoetstof|Mineral water w sweetener|Frisdrank Crystal Clear e.d.|0|0|0|0|0
    Wijn witte zoete|Wine white sweet||96|0.2|0|5.9|0
    Sap appel- verrijkt m vit C|Juice apple fortified w vitamin C|Appelsap m vit c|45|0.2|0|11.1|0.1
    Zoutjes Japanse mix z pinda's|Japanese rice cracker mix wo peanuts||387|8.5|0.9|86|0.8
    Pasta volkoren gekookt|Pasta wholemeal boiled|Macaroni/spaghetti volkoren gekookt|134|5.6|0.9|23.7|4.2
    Couscous gekookt|Couscous boiled||121|4|0.7|24|1.2
    Gierst gekookt|Millet boiled||123|3.9|1.4|23.1|0.9
    Cafe noir|Biscuit Cafe noir|Biscuit cafe noir|420|3.4|5.4|89|0.8
    Zoutje mais- Bugles|Crisps maize Bugles||537|6.3|32|55|1.8
    Chips op basis v aardappelvlokken|Crisps based on potato dough|Pringles e.d.|522|4.2|32.5|51.8|2.6
    Pijnboompitten|Pine nuts|Noten pijnboompitten|675|16.5|61.9|9.8|6.3
    Basilicum vers|Basil fresh||48|3.1|0.8|5.1|3.9
    Pesto groene|Pesto green||444|9|42.8|4.4|2.6
    Brownie m noten|Brownie w nuts|Chocoladecake brownie met noten|447|5.1|24.3|50.9|2.2
    Sportdrank Extran Energy|Sports drink Extran Energy||43|0|0|10.8|0
    Sportdrank Extran Hydro|Sports drink Extran Hydro||22|0|0|5.5|0
    Biscuit baby- en dreumes- Bolletje|Biscuit baby/toddler Bolletje||428|8.5|12|70.5|2
    Biscuit fourre|Biscuit filled|Sandwichbiscuit|473|5.5|17.1|73.2|2
    Koekje Scholiertje|Biscuit w chocolate layer Scholiertje|Scholiertje melk/puur|493|6.3|23.5|62.5|3.6
    Cracker VitaLU|Cracker VitaLU||445|12.3|12.3|67|8.4
    Wafel rijst- m chocolade|Rice cakes puffed w chocolate|Chocoladerijstwafel|502|6.8|24.9|60.3|4.6
    Biscuit fruit-|Biscuit fruit|Fruitbiscuit sultana e.d.|396|5.5|7.1|76.3|2.6
    Koek ontbijt- m rozijnen|Cake Dutch spiced Ontbijtkoek w raisin|Ontbijtkoek met rozijnen|315|2.7|1.2|71.5|3.7
    Graanreep Hero B'tween|Cereal bar Hero B'tween||444|6.9|17.7|62|4.6
    Graanreep z suiker|Cereal bar wo sugar||339|7.3|10.3|67.3|4.9
    Graanreep Special K Kellogg's|Cereal bar Special K Kellogg's||400|4.6|6.5|79.5|2.6
    Graanreep m melk Kellogg's|Cereal bar w milk Kellogg's|Kellogg's reep rice krispies/frosties/coco pops|417|6|11.3|72.3|1.1
    Mueslireep|Muesli bar|Granenreep/havermoutreep|455|8.2|16.8|64.8|6
    Melk geiten- volle|Milk goats- full fat|Geitenmelk volle|64|3.3|3.7|4.3|0
    Yoghurtsnack Breaker|Yoghurt snack Breaker||102|3.4|3.5|13.3|0.6
    Yoghurt room- m vruchten|Yoghurt cream- w fruit|Vruchtenyoghurt room-/roomyoghurt m vruchten|141|2.9|7.8|13.7|0.9
    Kwark vruchten-/vanille- magere m zoetstof|Quark low fat w fruit/vanilla w sweetener||47|7.2|0.1|4.1|0.3
    Kwark vruchten- Danoontje|Quark w fruit Danoontje|Vruchtenkwark danoontje|96|6.4|3|9.9|0.8
    IJs Festini|Ice lolly Festini||100|0.2|0.2|24|0.8
    IJs room/vanille- m chocoladecoating|Ice cream dairy w chocolate coating|Ijs met chocoladelaagje magnum ed|324|4.3|18.7|34|1
    IJs room/vanille- m fruitcoating|Ice cream dairy w fruitcoating|Ijs met fruitlaagje Solero e.d.|134|1.5|3.5|24|0.2
    Yoghurtdrank m zoetstof|Yoghurt drink w sweetener|Drinkyoghurt m zoetstof/optimel drink/arla zin|24|2.7|0|3.4|0
    Yoghurtdrank m zoetstof Fristi|Yoghurt drink Fristi w sweetener|Drinkyoghurt fristi met zoetstof|24|1.8|0|3.2|2
    Drinkontbijt Goede Morgen Vifit|Breakfast drink Goede Morgen Vifit||55|3.4|0.8|7.9|1.1
    Yoghurtdrank Actimel naturel|Yoghurt drink Actimel plain|Drinkyoghurt Actimel naturel|70|3|1.6|10.8|0
    Drink soja- Groeidrink 1-3+ Alpro|Drink soya Groeidrink 1-3+ Alpro|Dreumessojadrink Alpro groeidrink 1-3+|60|2.4|2|8|0.4
    Plantaardig alternatief voor room obv soja|Plant-based alternative to cream based on soya|Sojaroomalternatief soja keuken|161|2.2|15.7|2.6|0.5
    Kaas 10+|Cheese 10+||187|32.2|6.4|0.2|0
    Melkdrank Yakult Balance|Milk based drink Yakult Balance||58|1.2|0|14|0
    Chocolade witte|Chocolate white|Witte chocolade|552|6.4|32.6|58.1|0
    Vla magere m zoetstof|Custard no fat w sweetener||47|3.4|0|8.2|0.4
    Creme fraiche halfvolle|Creme fraiche half fat||165|3.1|15|4|0
    Pasta glutenvrij rauw|Pasta gluten free raw|Macaroni/spaghetti glutenvrij onbereid Schar e.d.|358|9|2.5|73.7|2.2
    Taartbodem v biscuitdeeg|Fatless sponge||263|7.5|4.2|48.4|0.8
    Room kook-|Cream cooking|Kookroom|212|2.4|20.2|5|0.1
    Room kook- light|Cream cooking light|Kookroom light|101|3.2|7.2|5.8|0
    Yoghurt volle Activia m granen/muesli|Yoghurt full fat w cereal/muesli Activia||104|3.6|3.6|12.6|2.3
    Room kook- Blue Band Finesse voor koken|Cream type product Blue Band Finesse voor koken|Kookroomproduct met plt vet finesse voor koken|160|2|15|4|0.3
    Siroop vruchtenlimonade- m suiker en zoetstof 40-45 g KH|Fruit drink conc w sugar and sweetener 40-45 g CHO|Limonadesiroop/ranja m suiker en zoetst 40-45 g KH|170|0|0|42.5|0
    Siroop vruchtenlimonade- light|Fruit drink concentrate light|Limonadesiroop/ranja light|8|0|0|1.8|0.1
    Kokosmelk|Coconut milk|Klappermelk|173|1.4|17.4|2.5|0.5
    Snoepje suikervrij|Candy sugar-free|Hoestbonbon/keelpastille/zuurtje suikervrij|240|1.1|2.1|89.3|0
    Tomaat in blik|Tomatoes tinned|Tomaatblokjes in blik/tomaten hele in blik|24|1.1|0.4|3.7|0.7
    Koolvis (Atlantisch) rauw|Pollack (Atlantic) raw||82|18|1.1|0|0
    Tonijn rauw|Tuna raw||101|23.7|0.7|0|0
    Tong rauw (vis)|Sole raw||76|14.7|1.9|0|0
    Tilapia rauw|Tilapia raw||86|17.9|1.6|0|0
    Worst rook- magere gekookt|Sausage smoked lean cooked|Magere rookworst gekookt|254|14|20.5|3.3|0
    Worst rook- runder gekookt|Sausage smoked beef cooked|Runderrookworst gekookt|240|13|20|2|0
    Worst knak- magere blik/glas|Sausage frankfurter lean tinned|Knakworst/Frankfurter/cocktailworstje mager|136|12|7|6|0.3
    Worst gekookte magere|Sausage cooked lean|Gelderse gekookte worst magere/kookworst magere|221|14|17|3|0.1
    Worst cervelaat- magere|Salami sausage saveloy lean||241|23|16.5|0.1|0
    Worst boterham- magere|Sausage luncheon meat lean|Boterhamworst magere|163|11.6|10.1|6.4|0
    Yoghurtdrank Becel pro-activ|Yoghurt drink Becel pro-activ|Drinkyoghurt becel pro-activ|45|3|1.5|4.5|1
    Breezer|Breezer||74|0|0|9.9|0
    Roti v bloem (sada roti)|Roti Surinam pancake|Surinaams gerecht roti|307|6.9|8.6|48.8|2.9
    Rundvlees gezouten gekookt Surinaams|Beef salted cooked Surinam|Surinaams zoutvlees gekookt|271|27.4|17.9|0|0
    Erwten split- gele gekookt|Peas split yellow boiled|Spliterwten gele gekookt|126|8.4|0.6|18.6|6.4
    Pomtajer bereid z vet|Tannia prepared wo fat|Tajerknol bereid z vet/Pomtayer bereid z vet|99|3.4|0.3|17.2|7.2
    Tajerblad bereid z vet|Tannia leaves prepared wo fat|Tayerblad/boterblad|38|4.6|1.1|0.9|3.4
    Aardappelpuree instant- bereid m halfvolle melk|Potatoes mashed instant prep w s-sk milk||96|4.1|1.3|16.5|1.1
    Aardappelpuree instant- bereid m water|Potatoes mashed instant prepared w water||71|1.7|1.6|11.8|1
    Aardappelpuree vers bereid m halfvolle melk z vet|Potatoes mashed fresh prep w s-sk milk wo fat||74|2.3|0.6|14.1|1.2
    Aardappelen m schil gekookt gem|Potatoes boiled w skin av||74|1.4|0.3|15.4|1.8
    Aardappelkroketten diepvries onbereid|Potato croquettes frozen unprepared||169|2.7|6|24.8|2.1
    Koek ontbijt- minder suiker|Cake Dutch spiced Ontbijtkoek less sugar|Ontbijtkoek minder suiker|287|3.2|1.5|59.2|12
    Bamigroenten gekookt|Bami vegetables boiled|Bamigroente bereid zonder vet/Bamipakket gekookt|19|1.2|0.2|2|2.1
    Gehakt rauw gem|Minced meat raw av||222|19.3|15.9|0.2|0.2
    Gehaktbal half-om-half m ei en paneermeel rauw|Minced meat ball beef/pork raw w egg/brcrumbs|Gehaktbal half om half m ei en paneermeel rauw|237|18.3|15.7|5.2|0.8
    Vlees gem excl lever rauw|Meat av raw excl liver||181|19.9|10.8|0.9|0.2
    Rundvlees gem rauw|Beef av raw||201|19.1|13.2|1.3|0.3
    Gehaktbal runder- m ei en paneermeel rauw|Minced beef ball raw w egg and breadcrumbs|Rundergehaktbal  met ei en paneermeel rauw|230|18|15|5.1|0.8
    Vink runder- rauw|Beef olives raw|Rundervink rauw|209|16.6|14.2|3.2|0.8
    Varkensschnitzel gepaneerd rauw|Pork schnitzel breaded raw||142|20.6|2.8|8.1|1
    Kipfilet gepaneerd rauw|Chicken fillet breaded raw||131|21.5|2.3|5.6|0.6
    Kipfilet omhuld m beslag rauw|Chicken fillet in batter raw||115|21|2|3.2|0.2
    Pudding gelatine-|Jelly|Gelatinepudding|59|1.8|0|13|0
    Varkens cordon bleu rauw|Pork filled w ham and cheese raw||153|20.4|5.2|5.8|0.7
    Pinda's suiker-|Peanuts sugar coated|Suikerpinda's/gesuikerde pinda's/aardnoten|536|15.1|31|47.1|4.1
    Sla gem rauw|Lettuce av raw||16|1.6|0.3|1|1.4
    Tortellini gekookt|Tortellini boiled||155|7.7|3.1|23.3|1.3
    Tarwebrood volkoren gem v fijn en grof m pompoenpitten|Wheat bread wholemeal av fine and coarse w pumpkin seeds|Volkorenbrood m pompoenpitten|275|13.4|7.6|34.7|6.9
    Meergranenbrood gem v wit en bruin m zaden m extra lijnzaad|Multigrain bread av white and brown w seeds w extra linseed|Lijnzaadbrood|287|13.1|7.9|36|9.6
    Meergranenbrood gem v wit en bruin m zaden|Multigrain bread av white and brown w seeds|Meergranenbrood m zaden gem|261|12.3|4.8|39.1|6.2
    Tarwebrood wit gem v melk- en waterwit|Wheat bread white av milk/water based|Witbrood gem van melk- en waterwit|250|9.1|1.7|48.1|2.6
    Tarwekrentenbrood wit m spijs|Wheat currant bread white w almond paste|Krentenbrood wit met spijs|303|8.2|6.1|51.7|4.3
    Tarwemueslibrood bruin/volkoren|Wheat muesli bread brown/wholemeal|Tarwebrood bruin/volkoren m noten en fruit/Mueslibrood bruin/volkoren|295|10.6|7.6|42.5|6.9
    Tarwenotenbrood volkoren|Wheat nut bread wholemeal|Volkoren notenbrood|298|12.2|10.9|34.5|6.7
    Tarwesuikerbrood wit|Wheat sugar bread white|Suikerbrood wit|306|7.9|3|60.5|2.5
    Tarwestokbrood wit m kaas en uien|Wheat baguette white w cheese and onion|Stokbrood wit kaas-uien|243|10|6|35.9|2.3
    Tarwebrood volkoren gem v fijn en grof m zonnebloempitten|Wheat bread wholemeal av fine and coarse w sunflower seeds|Volkorenbrood m zonnebloempitten|284|11.9|8.7|35.9|6.8
    Tarwebrood wit gem v melk- en waterwit m zonnebloempitten|Wheat bread white av milk/water based w sunflower seeds|Witbrood gem van melk- en waterwit m zonnebloempitten|297|10.2|8.3|43.9|3.2
    Wrap/tortilla obv tarwe naturel|Wrap/tortilla wheat white||298|8.5|5.5|50.8|4.1
    Wafel rijst- m karamel|Rice cakes puffed w caramel|Karamelrijstwafel|394|5.5|2.4|87|1.4
    Frikandel diepvries onbereid|Sausage Dutch Frikandel frozen unprep||235|13.1|17.2|6.1|1.7
    Gehakt cordon bleu rauw|Minced meat w ham and cheese raw||270|14.8|18.4|10.8|1.1
    Kipschnitzel gepaneerd rauw|Chicken schnitzel breaded raw||156|19.1|6.1|5.6|0.6
    Kip cordon bleu rauw|Chicken cordon bleu raw||150|22|4.8|4.4|0.5
    Pindakaas light|Peanut butter light||535|18|39.6|13.7|25.8
    Soepstengel|Breadsticks||401|12.5|6.6|71.3|3.3
    Zoutje luchtig maisbasis|Cocktail snacks based on corn|Chipito's e.d./hamka's e.d./ringlings e.d.|518|7.5|27|60.7|1.1
    Tiramisu|Tiramisu||248|4.5|10.6|30.7|0.7
    Rozijnen omhuld m chocolade melk-|Raisins coated w milkchocolate|Melkchocoladerozijnen|429|5|17.3|61.8|3.2
    After eight|After eight chocolate mints|Chocolade m mint after eight|419|2.1|12.2|74.6|1
    Chocolade melk- m rozijnen|Chocolate milk w raisins|Melkchocolade m rozijnen|501|6.2|27.4|55.9|3
    Chocolade puur m hazelnoten|Chocolate dark w hazelnuts|Pure chocolade m hazelnoten|565|9|41|36.2|7.6
    Chocolade melk- m gepofte rijst|Chocolate milk w puffed rice|Melkchocolade m crisp|531|7.1|30.7|55.2|2.9
    Tomaat gedroogd in olie blik/glas, uitgelekt|Tomatoes dried in oil tin/glass, drained|Tomaten gedroogd blik/glas in olie|197|4.4|14|9.4|8
    Tomaat zongedroogd|Tomato sun-dried|Tomaten zongedroogde|331|14.1|3|55.8|12.3
    Rozijnen gedroogd geweekt|Raisins soaked in water||258|2.5|0.4|59.5|3.1
    Toffee m chocolade|Toffee w chocolate|Chocoladetoffee chocotoff e.d.|427|1.8|11.7|77.8|1.5
    Pate smeer- magere|Pate spreadable lean|Smeerpate magere|187|9.7|12|10|0.3
    Tarwebrood bruin m zonnebloempitten|Wheat bread brown w sunflower seeds|Bruinbrood m zonnebloempitten|287|10.9|8.3|39.7|5.2
    Noga m chocolade|Nougat w chocolate||489|7.2|21.8|64.2|3.3
    Drop m pepermunt|Liquorice w peppermint|Schoolkrijtjes|375|2.8|0.1|90.4|0.3
    Salmiakkogel/-lolly|Salty liquorice lolly||375|1.2|0|92.3|0.3
    Noga|Nougat||469|6.5|16.7|72.1|2.1
    Popcorn zoete gepoft z olie|Popcorn sweet popped wo oil||389|9.9|3|78.7|3.8
    Siroop vruchtenlimonade- Albert Heijn|Fruit drink conc Albert Heijn|Limonadesiroop/ranja blik albert heijn|164|0.1|0|41|0.1
    Cake marmer-|Cake marble-|Marmercake|396|5.6|21.2|44.9|1.7
    Cake appel- z roomboter|Cake apple- wo butter|Appelcake|260|3.5|13.5|30.5|1.3
    Cake rozijnen-|Cake raisins-|Rozijnencake|384|5.3|19.1|47.1|1.4
    Soes bananen-|Eclair filled w banana and whipped cream|Bananensoes|245|3.5|18.4|16.1|0.7
    Soes slagroom- m chocolade|Chocolate eclair w whipped cream filling|Moorkop/Slagroomsoes met chocola|303|4.2|23.8|17.6|1
    Taart chocolade- m slagroom|Chocolate cake w whipped cream|Chocoladegebak m slagroom|337|4.8|20.4|32.9|1.5
    Koek ontbijt- m noten|Cake Dutch spiced Ontbijtkoek w nuts|Ontbijtkoek m noten|337|4|5.4|66.2|3.9
    Koek ontbijt- m kandij|Cake Dutch spiced Ontbijtkoek w rockcandy|Ontbijtkoek m kandij/kandijkoek|312|2.8|1|71.5|2.6
    Spekkoek m roomboter|Spiced cake Indonesian- Spekkoek made w butter||422|5.3|33.3|25.1|0.3
    Croissant chocolade-|Croissant chocolate-|Chocoladecroissant/Pain au chocolat|434|8.9|24|44.3|2.7
    Koek m gelei/appelvulling|Tarts filled w jam|Appelkoek|398|3.3|13.3|65.5|1.5
    Kappertjes|Capers||43|2.4|0.9|4.9|3.2
    Koek Glace-|Cup cake iced|Roze koek|427|3.6|19.2|59.5|0.8
    Koekje chocolate chip cookie|Chocolate chip cookie|Chocoladezandkoekje/zandkoekje m chocolade|501|6.3|25.3|60.6|2.9
    Koekje kinder- gem|Biscuit children's av|Kinderkoekje gemiddeld|450|7.6|14.8|70.6|2.2
    Sprits m chocolade|Biscuit Dutch shortbread sprits w choc||541|4.7|30.3|61.5|1.7
    Schuimzoenen|Teacakes chocolate coated marshmallow||439|2.2|15.3|71.4|3.4
    Kletskop|Biscuit Dutch Kletskop||492|5.7|25.4|59.2|2
    Mergpijpje gevuld m cake en creme|Cake wrapped in marzipan and chocolate||457|2.7|21.6|62.7|0.6
    IJs room- stracciatella|Ice cream dairy stracciatella||248|3.3|13.9|26.8|1.2
    Koek oranje-|Cake Dutch w icing & cream Oranjekoek|Oranjekoek|375|4.7|9.7|66.3|1.8
    Saus warm vloeibaar kant-en-klaar <12% vet|Sauce hot liquid ready-to-eat <12% fat||91|1.3|6.6|6.4|0.1
    Saus kaas- op basis roux bereid|Sauce cheese- based on roux prepared|Kaassaus|127|5.5|9.1|5.6|0.2
    Saus warm vloeibaar kant-en-klaar >12% vet|Sauce hot liquid ready-to-eat >12% fat||195|1.2|18.8|5.2|0.2
    Halvarineproduct Becel Omega-3 Plus|Low fat margarine prod Becel Omega3 Plus||353|0.3|38|2.6|0
    Hagelslag chocolade- wit|Chocolate sprinkles white|Chocoladehagelslag witte|455|5.5|13.2|78.4|0
    Wafel galette-|Wafer galette|Galette wafel|480|6.9|20.9|65.2|2
    Schuddebuikjes Bolletje|Spice biscuit sprinkles Bolletje||486|5|20|70|3
    Wafel melk-hazelnootchocolade Knoppers|Wafer w milk & hazelnuts Knoppers|Knoppers gevulde wafel|548|8.8|33.3|52|2.5
    Cake m noten|Cake w nuts|Notencake|449|8.1|29.8|36|2.2
    Beignet banaan-|Fritter banana|Bananenbeignet|282|2.9|20.5|20.6|1.4
    Taart slagroom- omhuld m marsepein|Gateau fatless sponge w marzipan|Gebak m marsepein/Chipolatataart|342|4.8|18|39.6|1.2
    Taart noten-|Nuts cake|Notengebak|467|7.6|27.2|46.7|2.5
    Drink rijst- z suiker verrijkt m calcium en vitamines|Rice drink wo sugar  fortified w calcium and vitamines||53|0.3|0.7|11.3|0.2
    Frisdrank m suiker en zoetstof 2-<5 g KH z cafeine|Soft drink w sugar and sweetener 2-<5 g CHO wo caffeine|Tonic/7-up e.d. m suiker en zoetstof 2-<5 g kh|12|0|0|2.9|0
    Limonade vruchten- m suiker en zoetstof 4-6 g KH|Juice drink w sugar and sweetener 4-6 g CHO|Frisdrank met suiker en zoetstof 4-6 g KH|18|0|0|4.6|0
    Limonade vruchten- Capri-Sun Multivitamin|Juice drink Capri-Sun Multivitamin|Frisdrank Capri-Sun Multivitamin|20|0|0|4.9|0
    Siroop vruchtenlimonade- bereid 1 op 7|Fruit drink conc diluted 1 to 7|Limonadesiroop/ranja verdund 1 op 7|28|0|0|7|0
    Thee kruiden- oplos gezoet bereid|Tea herbal instant sweetend prepared|Kruidenthee oplos bereid gezoet/Oplosthee bereid gezoet|19|0|0|4.7|0
    Saus boter-|Sauce butter-|Botersaus|180|0.6|18.3|3.1|0.2
    Saus v halfvolle melk en maizena|Sauce w semi-skimmed milk and corn starch||57|3.3|1.4|7.8|0
    Jus 25% vet ongebonden bereid m juspoeder|Gravy 25% fat clear prep w gravy instant powder||230|1|22.9|4.8|0.2
    Jus 50% vet ongebonden bereid m juspoeder|Gravy 50% fat clear prepared w gravy instant powder||431|1.1|45.1|4.9|0.2
    Jus 25% vet gebonden bereid m juspoeder|Gravy 25% fat thickend prep w gravy instant powder||233|1|22.3|7|0.2
    Jus 25% vet gebonden bereid z juspoeder|Gravy 25% fat thickend prep wo gravy instant powder||223|0.1|23.5|2.7|0
    Jus 50% vet gebonden bereid z juspoeder|Gravy 50% fat thickend prep wo gravy instant powder||436|0.3|47.1|2.9|0
    Jus 75% vet gebonden bereid z juspoeder|Gravy 75% fat thickend prep wo gravy instant powder||650|0.4|70.6|3.2|0
    Saus Aardappel Anders gem|Sauce Aardappel Anders av||171|1.5|16.6|3.9|0.2
    Jus 5% vet gebonden bereid z juspoeder|Gravy 5% fat thickend prep wo gravy instant powder||53|0|4.7|2.6|0
    Saus sate huishoudelijk bereid m hv melk z vet|Peanutsauce homemade w s-sk milk wo fat|Satesaus/pindasaus huish bereid m halfv melk z vet|297|10.2|22|12.8|3.3
    Saus sate huishoudelijk bereid m water z vet|Peanutsauce homemade w water wo fat||280|8.9|21.4|11.1|3.3
    Jus 50% vet ongebonden bereid z juspoeder|Gravy 50% fat clear prep wo gravy instant powder||439|0.3|48.5|0.4|0
    Jus 75% vet ongebonden bereid z juspoeder|Gravy 75% fat clear prep wo gravy instant powder||658|0.4|72.7|0.6|0
    Jus 50% vet gebonden bereid m juspoeder|Gravy 50% fat thickend prep w gravy instant powder||429|1.1|43.9|7.1|0.2
    Jus 5% vet ongebonden bereid z juspoeder|Gravy 5% fat clear prep wo gravy instant powder||44|0|4.8|0|0
    Dressing vinaigrette-|Salad dressing vinaigrette|Vinaigrettedressing|596|0.5|65.1|0.4|0.1
    Saus frites- ca 13% olie|Sauce for chips approx 13% oil|Fritessaus/slasaus/saus sla-/dressing ca 13% olie|158|0.3|13.1|9.4|0.8
    Dressing honing/mosterd-|Salad dressing honey/mustard|Honing-mosterd dressing|299|1.2|26|15|0
    Saus frites- 5% olie|Sauce for chips 5% oil|Fritessaus 5% olie|100|0.8|5.3|9.8|5
    Mayonaiseproduct ca 35% olie|Mayonnaise product approx 35% oil||338|0.5|32.7|10.5|0
    Olie wok-|Oil wok|Wokolie|900|0|100|0|0
    Pasta kruiden-/boemboe|Herb paste boemboe|Kruidenpasta/boemboe|306|4|20.4|25.6|1.7
    Koffie cappuccino vers bereid|Coffee cappuccino freshly made||31|1.8|1.7|2.3|0
    Koffie cappuccino oplos- bereid|Coffee cappuccino instant prepared|Oploscappuccino/instant cappuccino bereid|37|1.2|1.3|4.7|0.3
    Koffie cappuccino oplos- poeder|Coffee cappuccino instant powder|Oploscappuccino/instant cappuccino poeder|407|13.9|14.9|52.4|3.8
    Energydrink Golden Power/Bullit/Freeway|Energy drink Golden Power/Bullit/Freeway|Energiedrank golden power/bullit/Freeway|44|0.2|0|10.7|0
    Vruchtendrank ACE|Fruit juice drink ACE|ACE-drank gem|44|0.2|0|10.9|0.1
    Soep op groente- en vleesbasis kant-en-klaar blik/zak/pak|Soup veg & meat based ready-to-eat|Groentesoep blik/zak/pak m vlees kant-en-klaar|41|2|1.2|5.3|0.7
    Soep op groente- en vleesbasis bereid pakje|Soup vegetable & meat based prepared pack|Groentesoep pakje m vlees|18|0.6|0.5|2.7|0.3
    Pasta speculoos-|Spread speculaas flavoured|Speculoospasta/speculaaspasta|579|3.2|37.5|56.6|1
    Vruchtendrank multivit 12vr nectar light|Fruit juice drink multivit 12 fruits nectar light||23|0.2|0|5.4|0.2
    Vruchtendrank m zoetstof 5-<8 g KH|Fruit juice drink w sweetener 5-<8 g CHO||28|0.1|0|6.9|0.2
    Aardappelpureepoeder z melkpoeder z vet|Potato puree powder wo milkpowder wo fat||364|7.9|0.5|78.4|7
    Melk chocolade- m halfvolle melk en gezoete cacaopoeder|Milk chocolate-flavoured w s-sk milk and sweetened cocoa powder|Chocolademelk van hv melk en gezoete cacaopoeder|78|3.5|1.6|12.2|0.6
    Zuiveldrank Fruitmelk Campina|Dairy drink Campina Fruitmelk||54|3.3|0.5|9.2|0
    Tomaat gezeefd pak|Tomato sieved pack|Tomaten gezeefde pak|39|1.8|0.3|6.3|2
    Aardappelpureepoeder m melkpoeder m vet|Potato puree powder w milkpowder w fat||373|9.2|8.6|62|5.5
    Yoghurt vruchten- halfvolle|Yoghurt half fat w fruit|Vruchtenyoghurt halfvol|79|4.2|1.5|11.6|0.1
    Yoghurt Griekse volle|Yoghurt Greek full fat||122|3.8|10|3.8|0
    Kwark vruchten- volle|Quark full fat w fruit|Vruchtenkwark vol|125|5.7|5.1|13.3|0.5
    Fruit gedroogd op brandewijn|Fruit dried in brandy|Boerenjongens/Boerenmeisjes|201|0.6|0.1|27.2|1.3
    Sap multivruchten-|Juice multifruit|Multivruchtensap|47|0.4|0.1|10.7|0.3
    Cider|Cider||55|0.1|0|6.4|0
    Diksap bereid 1 op 13|Fruit juice concentrated diluted 1 to 13|Limonadesiroop diksap verdund|17|0|0|4.2|0
    Vruchtendrank multivit nectar light Surango|Fruit juice drink Surango multivit nectar light||21|0.2|0|5|0.1
    Kaas smeer- 15+ Balans ERU|Cheese spread 15+ Balans ERU|Smeerkaas ERU Balans|132|17.3|5.5|3.3|0
    Kaas smeer- Kids ERU|Cheese spread Kids ERU|Smeerkaas ERU Kids|169|15|11.1|2.3|0
    Kaas geiten- hard|Cheese goat hard|Geitenkaas hard|396|22.4|32.5|0.1|0
    Vla halfvolle alle smaken|Custard half fat all flavours||85|2.3|1.7|15.1|0.4
    Pudding luchtige|Pudding airy|Bavarois/Chipolatapudding|179|4.2|8.1|22|0.9
    Pap lammetjes- bereid m volle melk|Porridge milk w wheat flour white Lammetjespap|Lammetjespap bereid m volle melk|84|3.9|3.2|9.8|0.3
    Vlaflip dubbel- Campina|Custard 2 flavours w syrup vlaflip Campina||96|2.9|2.6|15|0.3
    Peper Spaanse rauw|Chili pepper raw|Chilipeper rauw|30|1.8|0.3|4.2|1.8
    Vet frituur- horeca|Frying fat horeca|Frituurvet horeca|900|0|100|0|0
    Biscuit hartig Sultana Crunchers|Biscuit savoury Sultana Crunchers||413|8.5|10.3|70.5|2.2
    Croutons|Croutons||491|11.8|22.3|58.6|4
    Chips oven-|Potato crisps oven baked|Ovenchips Lay's e.d.|411|6.4|9.3|72.8|5.1
    Maltesers|Maltesers||500|8.3|24.3|61.5|1.2
    Vlokken chocolade- gem|Chocolate flakes av|Chocoladevlokken gemiddeld|452|5.5|14.9|71.6|3.9
    Drop suikervrij|Liquorice sugar-free||167|1|0.2|61|1
    Winegum m drop|Wine gum w liquorice||334|3.5|0.2|79.6|0
    Cacaopoeder gezoet Nesquik|Cocoa powder sweetened Nesquik||376|5|3|79|6.5
    Vlaflip v vla en yoghurt|Dessert made of custard, yoghurt & syrup||77|3.4|1.5|12.3|0
    Pudding huishoudelijk bereid m hv melk|Blancmange home-made w semi-sk milk||92|2.9|1.4|17|0
    Vla zacht & luchtig|Custard soft & airy||142|2.9|7.4|16|0.2
    Soep noodle- bereid|Soup noodle prepared|Noedelsoep bereid|86|1.7|3.4|11.7|0.7
    Worst boterham- vegetarisch verrijkt m ijzer en vit B12|Sausage luncheon meat vegetarian fortified w iron and vit B12|Boterhamworst vegetarisch|181|6.6|14.7|4.6|1.8
    Bamibal/bamischijf diepvries onbereid|Chinese noodle ball frozen unprepared||165|5.8|2.8|29|0.5
    Kroket vlees- diepvries onbereid|Croquette meat ragout frozen unprep||187|7.6|8.7|18.9|1.5
    Loempia diepvries onbereid|Spring roll frozen unprepared|Maaltijdloempia diepvries onbereid|152|6.1|4.5|21.2|1.3
    Croissant ham-kaas-|Croissant ham and cheese|Ham-kaascroissant|378|11.2|20.6|35.7|2.1
    Kipkorn diepvries onbereid|Chicken sticks breaded frozen unprepared|Kipkorn diepvries onbereid|293|11.6|19.7|16.5|2
    Broodje kaas- v bladerdeeg|Cheese pastry w puff pastry|Kaasbroodje v bladerdeeg|481|10|30.9|39.8|1.5
    Viandel onbereid Mora|Viandel unprepared Mora||300|9.5|21.2|17|1.5
    Biscuit meergranen- LU Time Out|Biscuit LU Time Out||484|7.6|20.8|64.3|4.8
    Margarine 80% vet >24 g verz vetz ongezouten|Margarine 80% fat >24 g sat fa unsalted||724|0.2|80.2|0.3|0
    Margarine vlb 80% vet <17 g verz vetz ongezouten|Margarine liq 80% fat <17g sat fa unsalted||738|0|82|0.1|0
    Halvarineproduct Bewust light 30% vet <10g verz vetz ongezouten|Low fat margarine prod Bewust light 30% fat <10g sat fa unsalted||275|0.1|30|1.1|0.3
    Appelflap m bladerdeeg z roomboter|Apple turnover w puff pastry wo butter||305|4|14.8|38|1.7
    Soep gebonden z vulling|Soup thickened no filling|Kerriesoep/mosterdsoep ongevuld|41|0.6|3|2.7|0.1
    Bak- en braadvet vlb 97% vet <17g verz vetz ongezouten|Cooking fat liq 97% fat <17g sat fa unsalted||883|0.4|97.7|0.5|0
    Bak- en braadvet vast 97% vet >17 g verz vetz ongezouten|Cooking fat sol 97% fat >17g sat fa unsalted||880|0.4|97.3|0.7|0
    Margarine 80% vet <24 g verz vetz ongezouten|Margarine 80% fat <24 g sat fa unsalted||720|0|80|0|0
    Halvarine 40% vet <17g verz vetz ongezouten|Low fat margarine 40% fat <17 g sat fa unsalted||360|0|40|0|0.1
    Halvarineproduct Albert Heijn smeerbaar cholesterol verlagend|Low fat margarine prod AH chol reducing||317|0|35|0.2|0.4
    Vlaai kruimel- m pudding|Flan w custard and crumble topping|Puddingkruimelvlaai|286|5.2|10|43|1.3
    Koek ontbijt- m noten en vruchten|Cake Dutch spiced Ontbijtkoek w nuts & fruit|Ontbijtkoek m noten en vruchten|343|4.5|6.9|63.7|3.9
    Vlaai pudding- m vruchten|Flan w custard and fruit|Vruchtenvlaai met pudding|146|2.9|3.6|24.7|1.4
    Cake bitterkoekjes-|Cake w Dutch Amaretti Bitterkoekjes|Bitterkoekjescake|398|5.8|21.3|45.3|1.2
    Saus knoflook- 20-<30% olie|Sauce garlic 20-<30% oil|Knoflooksaus 20-<30% olie|246|0.8|21|13.4|0
    Aardappelpuree vers bereid m volle melk en margarine|Potatoes mashed fresh prep w whole milk and margarin||87|2.2|2.3|13.9|1.2
    Cake appel- m roomboter|Cake apple made w butter|Appelcake m roomboter|263|3.6|13.7|30.6|1.3
    Jus 5% vet gebonden bereid m juspoeder|Gravy 5% fat thickend prep w gravy instant powder||76|0.9|5|6.8|0.2
    Pannenkoek volkoren huishoudelijk bereid m vloeibare margarine|Pancake wholemeal homemade prepared w liquid margarin||181|6.6|6.6|22.4|3.1
    Pannenkoek volkoren huishoudelijk bereid m margarine|Pancake wholemeal homemade prepared w margarin||180|6.6|6.5|22.4|3.1
    Koek pinda-|Biscuit peanut|Pindakoek|513|10.6|28.4|51.9|3.7
    Jus 25% vet ongebonden bereid z juspoeder|Gravy 25% fat clear prep wo gravy instant powder||219|0.1|24.2|0.2|0
    Candybar KitKat|Candybar KitKat||520|7.1|27.7|59|3
    Dressing olijfolie-azijn|Salad dressing olive oil-vinegar|Vinaigrettedressing met olijfolie|607|0.4|66.4|0.5|0.1
    Mix voor marinade poeder onbereid|Mix for marinade powder unprepared|Marinademix poeder onbereid|285|8.4|4.3|50.5|5.1
    Koekje m noten en chocolade|Biscuit w nuts and chocolate||517|7.5|28.7|55.5|3.3
    Koekje m noten|Biscuits w nuts||509|6.6|24.1|64.9|3.1
    Wijn rose|Wine rose||71|0.1|0|2.5|0
    Saus Joppie-|Sauce Joppie|Joppiesaus|346|0.8|28|22.8|0
    Tapenade v olijven|Tapenade olive||326|1.8|32.4|5.2|3.3
    Mix seasoning Mexicaans onbereid|Mix seasoning Mexican unprepared|Seasoningmix mexicaans onbereid|318|12|5.7|48.8|11.5
    Salsa tomatendipsaus|Salsa tomato dip||45|0.9|0.2|9.3|1.6
    Azijn|Vinegar||22|0.4|0|0.6|0
    Broodje bapao vlees|Bread stuffed Bapao meat||252|8.9|6.7|38.1|1.9
    Berenklauw rauw|Meatball Berenklauw unprepared||154|11.3|9.4|5.4|1.5
    Taart appel- v zandtaartdeeg m roomboter|Appel pie Dutch w shortbread w butter|Appeltaart m roomboter/appelgebak m roomboter|225|2.4|9.1|31.9|1.6
    Koffie oplos- poeder|Coffee instant powder|Oploskoffie/instantkoffie poeder|114|7.8|0.2|3.1|34.1
    Vruchtendrank 2 of meer vruchten verrijkt m vit C|Fruit juice drink minimal 2 fruits fortified w vit C|Multivruchtendrank/duodrank m vit c|48|0.2|0.1|11.4|0.2
    Smoothie vruchten|Smoothie fruit||56|0.7|0.2|12.3|1.3
    Smoothie vruchten m zuivel|Smoothie fruit w dairy||51|1.3|0.1|10.3|1.2
    Frisdrank m suiker en zoetstof 2-<5 g KH m cafeine|Soft drink w sugar and sweetener 2-<5 CHO w caffeine|Cola m suiker en zoetst 2-<5 g kh m cafeine|11|0|0|2.6|0
    Sportdrank Aquarius|Sports drink Aquarius||29|0|0|7.1|0
    Koffie automaat- m suiker en melk|Coffee w sugar and milk vending machine||28|0.2|0.7|5.3|0
    Koffie automaat- m melk|Coffee w milk vending machine||12|0.2|0.7|1.3|0
    Thee kruiden- oplos gezoet poeder|Tea herbal instant sweetend powder|Kruidenthee oplospoeder gezoet/Oplosthee poeder gezoet|372|0|0|92.9|0.1
    Jus z vet bereid m juspoeder|Gravy prep wo fat w gravy instant powder||28|0.9|0.7|4.6|0.2
    Saus cocktail/party/tafel- >25% olie|Sauce cocktail/party/table >25% oil|Cocktailsaus >25% olie|374|1.2|33.9|15.9|0.3
    Wafel rijst- gekruid|Rice cakes w spices|Rijstwafel gekruid|402|7.9|7.7|74.4|1.7
    Kipfilet (vleeswaar)|Chicken (processed meat product)||125|17.5|4.4|3.4|0
    Yoghurt 0% vet Activia m vruchten|Yoghurt 0% fat w fruit Activia|Vruchtenyoghurt 0% vet activia|53|4.6|0.1|7.5|0.6
    Hagelslag chocolade- mix wit en puur|Chocolate sprinkles mix white and dark|Chocoladehagelslag mix wit en puur/hagelmix|449|3.2|14.7|73.9|4.3
    Pasta duo- m chocolade|Spread duo w chocolate|Duopasta chocolade-/Chocoladepasta Duo Penotti e.d.|576|1.8|36.5|59.5|1.3
    Pasta duo- z chocolade|Spread duo wo chocolate|Duopasta zonder chocolade|567|0.8|34.9|62.5|0.1
    Snoep schuim-/gum-|Sweets jelly/gums/foam||336|4.9|0.2|78.5|0.1
    Winegum m schuimlaag|Wine gums w foam layer||333|4.8|0|78.5|0
    Wafel Luikse-|Waffle Luikse|Luikse wafel|446|5.7|21.3|57.1|1.5
    Wafel zachte/suiker-/flash-|Waffle soft-/sugar-/flash-|Suikerwafel/flashwafel|493|7.6|27.3|53.8|0.9
    Frisdrank m suiker en zoetstof 5-<8 g KH m cafeine|Soft drink w sugar and sweetener 5-<8 g CHO w caffeine|Cola m suiker en zoetst 5-<8 g kh m cafeine|27|0.3|0|6.5|0
    Dressing sla- 20% olie m yoghurt|Salad dressing 20% oil w yoghurt|Sladressing 20% olie m yoghurt|258|1.2|22.7|12.3|0
    Mix voor nasi/bami onbereid|Mix spice and herbs rice/Chinese noodles unprepared|Mix kruiden- voor nasi/bami onbereid|300|11|5.8|45.8|10.6
    Energydrink Red Bull|Energy drink Red Bull|Energiedrank Red Bull|44|0|0|11|0
    Energydrink Red Bull sugarfree|Energy drink Red Bull sugarfree|Energiedrank Red Bull sugar free|0|0|0|0|0
    Muesli krokante m noten|Muesli crunchy w nuts|Cruesli e.d. m noten/Granola m noten|454|10.2|17.5|60.1|8
    Muesli krokante m chocolade|Muesli crunchy w chocolate|Cruesli e.d. m chocolade/Granola m chocolade|445|10.2|16.1|60.4|8.6
    Muesli krokante m noten en chocolade|Muesli crunchy w nuts and chocolate|Cruesli e.d./granola m noten en chocolade|436|10.7|13.9|63|8.4
    Zuivelspread naturel/kruiden|Dairy spread plain/herbs||248|5.1|23.9|3.1|0.1
    Zuivelspread naturel/kruiden light|Dairy spread plain/herbs light||175|8.1|13.8|4.2|0.3
    Mix kruiden- Wereldgerechten onbereid|Mixed spices Wereldgerechten unprep|Kruidenmix wereldgerecht onbereid|312|11.8|5.1|50.4|8.5
    Rijst meergranen- gekookt|Rice multi-grain boiled|Meergranenrijst gekookt|140|3.6|0.6|29.6|1.1
    Ontbijtproduct Coco pops Chocos Kellogg's|Breakfast cereal Coco pops Chocos Kellogg's|Ontbijtgranen Chocos Kellogg's|380|10|2.2|77|6
    Ontbijtproduct Special K chocolade Kellogg's|Breakfast cereal Spec K choc Kellogg's|Ontbijtgranen Special K chocolade Kellogg's|417|8|5.6|81|5.7
    Abrikozen gedroogd geweekt|Abricots dried and soaked||159|2.8|0|33|8.1
    Appelmoes z suiker m zoetstof blik/glas|Apple sauce wo sugar w sweetener tinned|Appelcompote light suikervrij m zoetstof|48|0.2|0|11|1
    Kruidnoten m chocolade puur|Biscuit spiced small Kruidnoten w dark choc|Chocoladekruidnoten/chocoladepepernoten pure|482|6.1|21.7|63.4|4.3
    Kruidnoten m chocolade melk-|Biscuit spiced small Kruidnoten w milk choc|Chocoladekruidnoten/chocoladepepernoten melk-|490|6.4|21.8|65.8|2.3
    Kauwbonbon fruitsmaak|Sweet fruity chew|Fruittella e.d. snoepje|395|1|6.6|82.9|0.1
    Koekje bitter-|Biscuit Dutch Amaretti Bitterkoekjes|Bitterkoekje|411|7|11.5|68.7|2.3
    Cake chocolade- z roomboter|Cake chocolate made wo butter|Chocoladecake z roomboter|396|5.6|20.3|46.5|2.3
    Frou frou|Biscuit Dutch Frou frou|Wafel frou frou|534|4.3|30.5|60.4|0.7
    Biscuit Sultana Yofruit|Biscuit w dried fruit & yoghurt Sultana Yofruit|Biscuit fruit- met yoghurtlaagje Sultana|412|5.1|10.1|74.1|2.2
    Kruidnoten m chocolade witte|Biscuit spiced small Kruidnoten w white choc|Chocoladekruidnoten/chocoladepepernoten witte|491|6.1|21.2|68.5|1.1
    Tarwebrood volkoren gem v fijn en grof m zaden|Wheat bread wholemeal av fine and coarse w seeds|Volkorenbrood m zaden|274|12.5|7.4|35.5|7.9
    Tarwebrood bruin m zaden|Wheat bread brown w seeds|Bruinbrood m zaden|278|11.4|7|39.2|6.4
    Ontbijtproduct All-Bran flakes Kellogg's|Breakfast cereal All-Bran flakes Kellogg's|Ontbijtgranen All-bran flakes Kellogg's|358|11|2.2|65|17
    Chips/kroepoek cassave|Cassave crackers||474|1.4|21.4|67.5|2.7
    Tarwemaisbrood wit m zonnebloempitten|Wheat corn bread white w sunflower seeds|Maisbrood wit m zonnebloempitten|307|11.6|9.6|41.2|4.8
    Sla rode rauw|Lettuce red raw||18|1.3|0.2|2.3|0.9
    Kool rode m appeltjes blik/glas|Cabbage red w apple pieces glass||58|0.8|0.3|11.9|2.2
    Margarineproduct Albert Heijn Balans|Margarine product Albert Heijn Balans||405|0|45|0|0
    Margarineproduct vloeibaar <60% vet <17 g verz vetz ongezouten|Margarine product liquid <60% fat <17 g sat fa unsalted||507|0.3|56|0.3|0.5
    Margarineproduct vloeibaar <60% vet <17 g verz vetz gezouten|Margarine product liquid <60% fat <17 g sat fa salted||507|0.3|56|0.3|0.5
    Biscuit meergranen- Liga Evergreen crunchy|Biscuit Liga Evergreen crunchy||395|6.6|12.3|59.7|9.5
    Meringue|Meringue|Schuimpje eiwitschuim|382|0.5|0|95|0
    Donut m glazuur|Doughnut iced||358|5.4|19|40.8|1
    Wafel Luikse m chocolade|Waffle Luikse w chocolate|Luikse wafel m chocolade|457|5.8|22.9|55.8|2.3
    IJsthee m suiker 4-<5 g KH|Ice tea w sugar 4-<5 g CHO|Frisdrank icetea 4-<5 g KH|18|0|0|4.5|0
    Wortel bospeen rauw|Carrot bunched raw|Waspeen/worteltjes rauw|31|0.9|0.3|5|2.5
    Wortel bospeen gekookt|Carrot bunched boiled|Waspeen/worteltjes gekookt|30|0.8|0.2|4.8|2.7
    Wortel winterpeen rauw|Carrot winter raw|Winterwortel rauw|34|0.6|0.3|5.7|3.3
    Wortel winterpeen gekookt|Carrot winter boiled|Winterwortel gekookt|34|0.6|0.3|5.6|3.1
    Tomaat tros- rauw|Tomato vine raw|Trostomaat/trostomaten rauw|22|0.7|0.5|3|1.2
    Tomaat kers- rauw|Tomato cherry raw|Kerstomaatjes/cherrytomaten rauw|30|0.9|0.8|3.9|1.9
    Tomaat vlees- rauw|Tomato beef raw|Vleestomaat/vleestomaten rauw|19|0.6|0.5|2.3|1.3
    Tomaat vlees- gekookt|Tomato beef boiled|Vleestomaat/vleestomaten gekookt|22|0.7|0.5|2.9|1.3
    Tomaat rauw gem|Tomato av raw|Tomaten rauw|25|0.8|0.6|3.4|1.6
    Tomaat gekookt gem|Tomato av boiled|Tomaten gekookt gem|23|0.7|0.7|2.9|1.3
    Sla rucola rauw|Rocket raw|Rucolasla rauw/Raketsla rauw|22|3.6|0.4|0|1.9
    Ui sla- rauw|Onion Welsh raw|Slauien/bosuien rauw|31|1.5|0.4|4.2|2.4
    Ui sla- gekookt|Onion Welsh boiled|Slauien/bosuien gekookt|26|1.2|0.3|3.5|2.3
    Komkommer m schil rauw|Cucumber w skin raw||13|0.7|0.4|1.3|0.6
    Paprika gele rauw|Sweet pepper yellow raw|Paprika geel rauw|25|0.7|0.2|3.9|2.5
    Paprika gele gekookt|Sweet pepper yellow boiled|Paprika geel gekookt|27|0.8|0.1|4.6|2.2
    Paprika rauw gem|Sweet pepper av raw||25|0.8|0.1|4.2|1.9
    Paprika gekookt gem|Sweet pepper av boiled||27|0.9|0.1|4.8|1.8
    Aardappelen Nicola z schil gekookt|Potatoes Nicola wo skin boiled||80|1.7|0.4|16.6|1.7
    Aardappelen Eigenheimer z schil gekookt|Potatoes Eigenheimer wo skin boiled||75|1.8|0.2|15.7|1.8
    Aardappelen Red Baron z schil gekookt|Potatoes Red Baron wo skin boiled||91|1.8|0.5|19.1|1.3
    Aardappelen kruimig z schil gekookt gem|Potatoes floury av wo skin boiled||81|2|0.2|17|1.8
    Peer m schil|Pear w skin|Peren m schil|55|0.2|0.3|11.7|2.2
    Druiven blauwe m schil|Grapes black w skin|Druif blauw m schil|75|0.6|0.1|16.8|2.1
    Druiven witte m schil|Grapes white w skin|Druif witte m schil|76|0.5|0.4|16.9|1.4
    Appel Elstar m schil|Apple Elstar w skin||55|0.3|0.2|12|1.9
    Appel Elstar z schil|Apple Elstar wo skin||55|0.2|0.2|12.4|1.5
    Appel Jonagold m schil|Apple Jonagold w skin||55|0.2|0.2|12.1|2
    Appel Jonagold z schil|Apple Jonagold wo skin||52|0.2|0.1|11.6|1.7
    Sap sinaasappel- vers geperst|Juice orange freshly squeezed|Sinaasappelsap/jus d'orange vers geperst|44|0.6|0.1|9.1|0.3
    Kaas Goudse 48+ jong|Cheese Gouda 48+ age 4-8 weeks||364|22.8|29.6|0|0
    Kaas Goudse 48+ jong belegen|Cheese Gouda 48+ age 8 wk-4 mths||370|22.7|29.9|0|0
    Kaas Goudse 48+ belegen|Cheese Gouda 48+ age 4-7 mths||377|22.5|30.8|0|0
    Kaas Goudse 48+ oud|Cheese Gouda 48+ age 10-12 mths||414|24.6|33.7|0.1|0
    Melk chocolade- automaat|Hot chocolate from vending machine|Chocolademelk uit automaat|66|3|1|10.8|1.2
    Koek gevulde m roomboter|Almond paste filled tarts w butter|Pencee/kano/rondo/gevuld heertje m roomboter|415|7.1|16.5|58.7|1.9
    Koek gevulde z roomboter|Almond paste filled tarts wo butter|Pencee/kano/rondo/gevuld heertje z roomboter|406|5.2|14.9|61.7|2.1
    Speculaas m roomboter|Biscuit spiced Speculaas w butter||484|5.5|21.7|65.2|3
    Speculaas z roomboter|Biscuit spiced Speculaas wo butter||467|5|20.1|65.1|3
    Pangasius bereid in magnetron z toev|Pangasius bereid in magnetron z toev||89|18.6|1.6|0|0
    Worst rook- varkens gekookt|Sausage smoked pork cooked|Varkensrookworst gekookt|340|14.3|30.1|2.8|0.7
    Worst rook- varkens ambachtelijke slagerij gekookt|Sausage smoked pork traditional cooked|Varkensrookworst ambachtelijke slagerij gekookt|311|15.2|27.1|1|1.2
    Worst ossen-|Sausage raw beef|Ossenworst|166|18.6|9.4|1.1|1.2
    Ei kippen- scharrel rauw|Egg whole chicken free-range raw|Scharrelei/scharrelkippeneieren rauw|132|12.3|9.1|0.2|0
    Ei kippen- scharrel gekookt|Egg whole chicken free-range boiled|Scharrelei/scharrelkippeneieren gekookt|125|12.2|8.5|0|0
    Ei kippen- biologisch rauw|Egg whole chicken organic raw|Biologische kippeneieren rauw|135|12.3|9.5|0.2|0
    Ei kippen- biologisch gekookt|Egg whole chicken organic boiled|Biologische kippeneieren gekookt|136|12.7|9.5|0|0
    Ei kippen- mais rauw|Egg whole chicken corn-fed raw|Maisei/maiskippeneieren rauw|129|12.2|8.8|0.2|0
    Ei kippen- mais gekookt|Egg whole chicken corn-fed boiled|Maisei/maiskippeneieren gekookt|148|13|10.7|0|0
    Biscuit tarwe-/digestive- m chocolade|Biscuit brown/digestive w chocolate|Tarwebiscuit m chocolade|488|6.5|22.2|63.8|3.3
    Vlaai appelkruimel-|Flan apple and crumble topping|Appelkruimelvlaai|304|3.9|11.4|45.6|1.9
    Vlaai wener bodem m bakkersroom|Flan hard shell w custard cream||295|4.1|16|33|1.6
    Vlaai zachte bodem m bakkersroom|Flan sponge w custard cream||253|3.5|12.5|30.8|1.4
    Pasta witte z ei gekookt|Pasta white wo egg boiled|Macaroni/spaghetti/noedels/mie/vermicelli witte z ei gekookt|146|5.2|0.8|28.7|1.4
    Pasta witte m ei gekookt|Pasta white w egg boiled|Macaroni/spaghetti/noedels/mie witte m ei gekookt|124|4.7|0.8|23.4|2.2
    Pasta witte vers gekookt|Pasta white fresh boiled|Macaroni/spaghetti/noedels/mie witte vers gekookt|129|4.9|1.3|23.9|1.3
    Tarwebrood volkoren grof|Wheat bread wholemeal coarse|Volkorenbrood grofvolkoren|236|11.3|2.4|38.9|6.8
    Meergranenbrood wit m zaden|Multigrain bread white w seeds||267|12.5|5|40.4|5.4
    Meergranenbrood bruin m zaden|Multigrain bread brown w seeds||255|12.2|4.5|37.8|7.1
    Tarwemaisbrood wit|Wheat corn bread white|Maisbrood wit|261|10.8|3.2|44.9|4.5
    Tarwebrood gem v bruin en volkoren m pompoenpitten|Wheat bread av brown and wholemeal w pumpkin seeds|Bruinbrood en volkorenbrood gem m pompoenbloempitten|254|13.9|5.5|33.3|7.8
    Tarwebrood gem v bruin en volkoren m zonnebloempitten|Wheat bread av brown and wholemeal w sunflower seeds|Bruinbrood en volkorenbrood gem m zonnebloempitten|272|12.5|6.7|36|8.7
    Tarwedesembrood volkoren|Wheat sourdough bread wholemeal|Zuurdesembrood volkoren|235|9.3|2.6|40.5|6
    Tarwe ciabatta wit ongevuld|Wheat ciabatta white no filling|Witbrood ciabatta ongevuld|255|9.1|1.8|48.9|3.3
    Tarwebrood wit pita|Wheat bread white pita|Pitabroodje wit/shoarmabroodje wit|245|8.6|0.7|50.1|2.1
    Stol m spijs z noten|Stollen w almond/imitat paste wo nuts|Kerststol/paasstol/pinksterstol z noten|276|7.7|2.4|53.8|3.9
    Stol m spijs m noten|Stollen w almond/imitat paste w nuts|Kerststol/paasstol/pinksterstol m noten|288|7.8|4.3|51.9|4.8
    Tarwestokbrood wit|Wheat baguette white|Stokbrood wit|270|9.7|1.2|53.6|2.8
    Tarwestokbrood bruin|Wheat baguette brown|Stokbrood bruin|258|9.8|1.4|49.8|3.8
    Tarwebroodje wit hard|Wheat bread roll white hard|Pistolet wit/Triangelbroodje wit|279|9.9|1.5|54.9|2.9
    Tarwebroodje bruin hard|Wheat bread roll brown hard|Pistolet bruin/Triangelbroodje bruin|278|11|1.5|52.8|4.9
    Tarwebroodje bruin zacht|Wheat bread roll brown soft|Tarwebolletje bruin/bruin bolletje|258|11|3.8|42.3|5.3
    Tarwebroodje volkoren zacht|Wheat bread roll wholemeal soft|Volkorenbolletje/volkorenbroodje zacht|247|11.3|3.2|39.5|7.3
    Meergranenbroodje bruin hard|Multigrain roll brown hard|Pistolet bruin meergranen/Triangelbroodje bruin meergranen|294|12.9|5.9|43.8|6.8
    Meergranenbroodje bruin zacht|Multigrain roll brown soft|Meergranenbolletje bruin zacht|283|13.4|6.8|38.7|6.4
    Croissant roomboter-|Croissant prepared w butter||414|9.5|22.5|42.2|2.7
    Croissant z roomboter|Croissant prepared wo butter||392|9.8|19.9|42.3|2.2
    Tarwekrentenbol wit|Wheat currant bun white|Krentenbol wit/rozijnenbol wit|268|8.4|2.5|51.1|4.1
    Tarwemueslibol bruin/volkoren|Wheat muesli bun brown/wholemeal|Tarwebol bruin/volkoren m noten en fruit/Mueslibol bruin/volkoren|290|10.7|6.6|43.9|5.8
    Maanzaad|Poppy seeds||455|19.2|35.6|2.4|24
    Pompoenpitten|Pumpkin seeds||574|30.3|47.2|2.7|8.5
    Spijs gem|Almond/imitation paste av|Amandelspijs/banketspijs/imitatiespijs|434|9.9|22|44.8|8.6
    Muesli m fruit/naturel|Muesli w fruit/plain|Fruitmuesli/vruchtenmuesli/muesli naturel|341|10.7|5.3|56.6|12
    Wafel stroop- z roomboter|Waffle syrup wo butter|Stroopwafel z roomboter|483|3.6|19.9|71.5|1.9
    Tarwebrood volkoren fijn|Wheat bread wholemeal fine|Volkorenbrood fijnvolkoren|233|10.9|2.2|39.2|6.6
    Tarwekrenten/rozijnenbrood wit gem m spijs|Wheat bread currant/raisin white av w almond paste|Krentenbrood en rozijnenbrood wit gem m spijs|303|8.2|6.2|51.3|4.6
    Tarwekrenten/rozijnenbrood wit gem|Wheat bread currant/raisin white av|Krentenbrood en rozijnenbrood wit gem|272|7.8|2.6|52.8|3.6
    Tarwerozijnenbrood wit m spijs|Wheat raisin bread white w almond paste|Rozijnenbrood wit m spijs|303|8.1|6.4|50.8|4.8
    Tarwebrood bruin tijger-|Wheat bread brown Tijger|Tijgerbrood bruin/Tarwebrood bruin m gerstemoutmeel|243|9.9|1.9|44.2|4.9
    Tarwebrood wit tijger-|Wheat bread white Tijger|Tijgerbrood wit/Tarwebrood wit m gerstemoutmeel|252|9|1.7|48.7|2.7
    Stol m spijs gem m en z noten|Stollen w almond/imitat paste av w and wo nuts|Kerststol/paasstol/pinksterstol gem m en z noten|282|7.7|3.4|52.8|4.4
    Croissant gem|Croissant av||403|9.6|21.2|42.2|2.5
    Zout z toegevoegd jodium|Salt not fortified w iodine|Nezo zout|0|0|0|0|0
    Wafel stroop- m roomboter|Waffle syrup w butter|Stroopwafel m roomboter|462|3.9|18.6|69|1.3
    Tarwebrood bruin m pompoenpitten|Wheat bread brown w pumpkin seeds|Bruinbrood m pompoenpitten|278|12.3|7.2|38.4|5.4
    Yoghurt vruchten-/vanille- magere m zoetstof|Yoghurt low fat w fruit/vanilla w sweetener|Vruchtenyoghurt/vanilleyoghurt mager m zoetstof|35|3.4|0|4.8|0.1
    Yoghurt stracciatella- volle|Yoghurt stracciatella full fat|Stracciatellayoghurt vol|128|3.3|5.6|15.4|0.3
    Kipschnitzel sate gepaneerd rauw|Chicken schnitzel satay breaded raw||206|14.8|8.5|16.5|2.4
    Varkensschnitzel sate gepaneerd rauw|Pork schnitzel satay breaded raw||231|13.3|11.8|16.7|2.5
    Likeur m room 15-25 vol% alc|Liqueur w cream 15-25 vol% alcohol|Baileys e.d.|294|2.7|11.8|22.7|0
    Chocoladereep gevuld Kinder|Chocolate bar filled Kinder|Kinder bueno chocolade melk-|567|8.9|35.7|52.1|1.3
    Croissant kaas-|Croissant cheese|Kaascroissant|401|10.6|21.9|39|2.3
    Siroop vruchtenlimonade- m suiker en zoetstof 10-15 g KH|Fruit drink conc w sugar and sweetener 10-15 g CHO|Limonadesiroop/ranja m suiker en zoetst 10-15g KH|47|0|0|11.7|0
    Cake chocolade- m roomboter|Cake chocolate made w butter|Chocoladecake m roomboter|400|5.8|20.6|46.7|2.3
    Aardappelbolletjes/-wafeltjes ed diepvries onbereid|Potato waffles/balls frozen unprepared|Aardappelwafeltjes/lachebekjes e.d. diepvries onb|175|2.6|6.9|24.3|2.8
    IJskoffie|Coffee iced||72|2.7|2.3|10.2|0
    Worst grill- m kaas|Sausage grill w cheese|Grillworst met kaas|331|14.3|29.3|2.7|0
    Bier m vruchtensmaak|Beer w fruit flavour|Kriek/kersenbier/citroenbier/rosebier|52|0.3|0|6|0.5
    Kool rode m appeltjes huishoudelijk bereid|Cabbage red w apple pieces home-made||52|0.9|1.1|8.3|2.4
    Ananas op eigen sap blik/glas|Pineapple in own juice tinned|Ananas op sap blik/glas|59|0.4|0.1|13.9|0.8
    Noten macadamia- ongezouten|Nuts macadamia unsalted|Macademianoten ongezouten|753|7.8|76.1|5.4|8
    Vruchtendrank m zuivel Taksi m zoetstof|Fruit drink w dairy Taksi w sweetener|Limonade vruchten-/frisdrank Taksi m zoetstof|10|0.1|0|2.3|0.1
    Sap vruchten- mild multifruit m vit C|Juice multifruit mild w vit C|Vruchtensap mild multifruit m vit c|49|0.4|0.1|11.7|0.2
    Drink soja- light verrijkt m calcium en vitamines Alpro|Drink soya light fortified w calcium and vitamins Alpro|Sojadrink light verrijktm calcium en vitamines Alpro|29|2.1|1.2|1.8|1.1
    Taart appel-noten|Pie apple-nuts|Appeltaart/appelgebak m noten|346|5.5|18.1|39.3|2.1
    Koek stroop- m chocolade|Biscuit syrup w chocolate|Stroopkoek met chocolade|497|4|24.9|63.7|1.4
    Pannenkoek huishoudelijk bereid m vloeibare margarine|Pancake homemade preprared w liquid margarin||176|5.7|5.9|24.2|1.6
    Beignet appel-|Fritter apple|Appelbeignet|265|2.5|20.4|17|1.3
    Candybar Lion|Candybar Lion||493|5.5|22.9|65.5|1.3
    Dessertsaus karamel-|Sauce caramel for pudding|Karamelsaus|302|2.7|3.9|63.9|0
    Fruitsnack Knijpfruit/Slurpfruit|Fruit snack Knijpfruit/Slurpfruit||63|0.4|0.2|14.2|1.6
    Brioche|Brioche|Briochebrood|338|8.5|11|50|2.5
    Ontbijtproduct Weetabix original|Breakfast cereal Weetabix original|Ontbijtgranen weetabix original|362|12|2|69|10
    Koffie wiener melange oplos poeder|Coffee wiener melange instant powder|Oploskoffie/instantkoffie wiener melange poeder|427|9.4|13.6|65.9|1.8
    Koffie wiener melange oplos bereid|Coffee wiener melange instant prepared|Oploskoffie/instantkoffie wiener melange bereid|46|1|1.5|7.1|0.2
    Runderrookvlees licht gezouten|Beef smoke-dried lightly salted||116|22.8|2.5|0.7|0
    Suiker riet-|Cane sugar|Rietsuiker|400|0.5|0|99.5|0
    Cranberrycompote gezoet|Cranberry compote sweetened|Veenbessencompote gezoet|172|0.4|0.1|41.9|1.2
    Noten cashew- gezouten|Cashew nuts salted|Cashewnoten gezouten|615|21.2|48.9|20.8|3.8
    Noten amandelen z vliesje gezouten|Almonds blanched salted||631|21.7|55.8|7.1|7
    Plantaardig alternatief voor yoghurt obv soja m suiker verrijkt m calcium en vitamines|Plant-based alternative to yoghurt based on soya sweetened fortified w calcium and vitamins|Yoghurtvariatie obv soja naturel m suiker|47|3.7|1.9|3.6|0.6
    Cranberry gedroogd gezoet|Cranberries dried sweetened|Veenbessen/cranberries gedroogd gezoet|335|0.5|1.4|77.6|5
    Koek jode-|Biscuit Dutch Jodekoek|Jodekoek|505|4.5|24.9|65.2|1.2
    Wafel penny-|Waffle penny-|Pennywafel|562|5.8|38.5|47|2
    Cake Indische|Cake Indonesian||313|4.3|5.7|60.8|0.7
    Biscuit digestive-|Biscuit digestive||492|6.7|21.8|65.4|3.6
    Halvarineproduct AH omega-3|Low fat spread AH omega-3||345|0|38|0.8|0
    Limonade vruchten- Ocean Spray Cranberry classic|Juice drink Ocean Spray Cranberry classic|Frisdrank Ocean Spray Cranberry classic|37|0|0|9.3|0
    Paardenrookvlees|Horse meat smoked||103|21.7|1.4|0.9|0
    Balkenbrij|Scrapple, pork||165|6.4|8.5|14.9|1.1
    Mais blik/glas|Sweetcorn tinned|Suikermais blik/glas|91|2.9|1.5|14.8|3.2
    Runderbraadworst gebakken|Sausage beef Braadworst prepared|Rundersaucijs bereid|228|23.8|14.6|0.3|0.1
    Runderborstlappen bereid|Beef breast boneless prepared||217|36.8|7.7|0|0
    Vink runder- gebakken|Beef olives prepared|Rundervink bereid|223|22.4|14.5|0.5|0
    Runder T-bone steak bereid|Beef T-bone steak prepared||254|33.6|13.3|0|0
    Runder ribeye steak bereid|Beef ribeye steak prepared||214|29.6|10.6|0|0
    Shoarmavlees varkens- bereid|Pork shoarma seasoning prepared||239|28.2|13.8|0.6|0.1
    Spek rook- mager bereid|Bacon lean smoked prepared|Spekblokjes/spekreepjes mager gerookt bereid|379|23.1|31.9|0|0
    Spareribs varkens- bereid|Pork sparerib prepared||249|29.5|14.5|0.1|0.1
    Varkenspoulet bereid|Pork stewing meat prepared||280|37.4|14.5|0|0.1
    Kalfsvleesreepjes gebakken|Veal stewing meat prepared||185|27.1|8.5|0|0.2
    Kalfssukadelappen bereid|Veal stewing steak prepared||158|27|5.5|0|0.1
    Kalfsbraadworst gebakken|Sausage veal Braadworst prepared|Kalfssaucijs bereid|237|22.9|16|0.4|0
    Kalfsriblappen bereid|Veal rib steak prepared||197|27|9.9|0|0
    Kalfslappen mager bereid|Veal frying steak prepared||142|28.4|3.1|0|0.1
    Kalfsoester bereid|Veal tenderloin medaillon prepared||143|28.8|3.1|0|0.1
    Cracker VitaLU verrijkt m calcium|Cracker VitaLU fortified w calcium|Vitalu cracker volkoren/meerzaden|419|12|9.2|67.5|9
    Yoghurtdrank 7-9g KH|Yoghurt drink 7-9g CHO|Drinkyoghurt fristi|39|1.8|0|7.8|0
    Aardappelen vastkokend z schil gekookt gem|Potatoes waxy av wo skin boiled||86|1.8|0.5|17.9|1.5
    Chips naturel|Crisps potato unflavoured||541|6.4|33.5|51.3|4.1
    Chips paprika ea smaken|Crisps potato flavoured||536|6.3|32.3|53.1|4
    Kaas Mascarpone|Mascarpone cheese||455|7.6|47|0.3|0
    Chips light paprika ea smaken|Crisps potato light flavoured||481|7.2|21|63.5|4.6
    Fritessticks naturel|Crisps potato straws natural||515|6.5|26.6|61|3
    Fritessticks paprika|Crisps potato straws flavoured||529|6.5|28.5|60|3.5
    Chips Lays Sensations diverse smaken|Crisps potato Lays Sensations flavoured||511|6.8|27.1|58|3.9
    Pasta chocolade- wit|Chocolate spread white|Chocoladepasta wit|592|4.6|40|53|0.6
    Soep 1-kops bereid|Soup portion prepared|Soep Cup-a-Soup e.d. bereid|40|1|1.6|5.4|0.2
    Koek eier- volkoren/meergranen|Sponge cake wholemeal/multigrain|Eierkoek volkoren/meergranen|305|8|3.2|59.3|3.8
    Halvarineproduct Becel pro-activ calorie light|Low fat spead Becel pro-activ calorie light||216|0.3|23|2|0.2
    Yoghurt volle Activia naturel|Yoghurt full fat plain Activia||68|3.9|3.5|4.7|0
    Yoghurtdrank Activia|Yoghurt drink Activia|Drinkyoghurt Activia Start|64|3|0.9|10.8|0.5
    Toast Melba naturel|Toast Melba natural|Cracker Melba toast naturel|398|12.7|2.4|79.3|4.1
    Toast Melba overige soorten|Toast Melba other varieties|Cracker melba toast sesam/volkoren/meergranen|403|15.4|7.2|64.9|8.2
    Plantaardig alternatief voor roomijs/yoghurtijs obv kokos|Plant-based alternative to icecream based on coconut|Kokosijs plantaardig|195|1.4|11.2|21.8|0.7
    Rolmops|Herring pickled w gherkin||182|16|12.8|0.5|0.5
    Kruidnoten m chocolade gem|Biscuit spiced small Kruidnoten w chocolate av|Chocoladekruidnoten/chocoladepepernoten gem|488|6.2|21.6|65.9|2.6
    Zout zee-|Salt sea|Zeezout|0|0|0|0|0
    Appeltjes gedroogd geweekt|Apple dried soaked in water||85|0.6|0.1|18.9|2.8
    Peren gedroogd geweekt|Pear dried soaked in water|Peer gedroogd geweekt|83|0.6|0|18.9|2.8
    Pruimen gedroogd geweekt|Prunes soaked in water|Pruim gedroogd gekweekt|57|0.5|0.1|13.9|1.5
    Tuttifrutti gedroogd geweekt|Fruit mixed dried soaked in water||96|1|0.1|21.2|3.4
    Kaas smeer- 45+|Cheese spread 45+|Smeerkaas 45+|231|14.3|18.9|1|0
    Worst Chorizo|Sausage Chorizo||358|20.7|29.1|3.4|0
    Worst grill-|Sausage grill|Grillworst|310|13.2|27.2|3.1|0
    Kalkoenfilet (vleeswaar)|Turkey (processed meat product)||113|19.8|2.4|3.2|0
    Spek katen-|Bacon smoked Katenspek|Katenspek|309|14|27.6|1.2|0
    Worst knak- runder blik/glas|Sausage beef frankfurter type tinned|Knakworst/Frankfurter/cocktailworstje runder|180|13|11|7|0.3
    Tarwebrood bruin koolhydraatverlaagd|Wheat bread brown carbohydrate reduced|Koolhydraatarm brood bruin|241|17.2|8.9|21|3.8
    Shandy|Shandy||42|0|0|9.7|0
    Kalfsschnitzel ongepaneerd rauw|Veal schnitzel not breaded raw||104|22.4|1.6|0|0
    Gehakt kalfs- rauw|Minced veal raw|Kalfsgehakt rauw|214|19|15.1|0.3|0.3
    Kalfsoester rauw|Veal tenderloin medaillon raw||108|22.9|1.9|0|0
    Kalfslappen mager rauw|Veal frying steak raw||104|21.8|1.9|0|0
    Kalfsriblappen rauw|Veal rib steak raw||167|20.6|9.4|0|0
    Kalfsbraadworst rauw|Sausage veal Braadworst raw|Kalfssaucijs rauw|217|17.2|16.1|0.5|0.5
    Kalfssukadelappen rauw|Veal stewing steak raw||117|17.7|5.1|0|0
    Kalfsvleesreepjes rauw|Veal stewing meat raw||98|22|1.1|0|0
    Varkenspoulet rauw|Pork stewing meat raw||123|21.5|4.1|0|0
    Spek rook- mager rauw|Bacon lean smoked raw|Spekblokjes/spekreepjes mager gerookt rauw|325|15.3|29.4|0|0
    Speklap bereid in eigen vet|Bacon rasher prepared in own fat||435|29.1|35.4|0|0
    Shoarmavlees varkens- rauw|Pork shoarma seasoning raw||146|19.9|7|0.6|0.6
    Runderborstlappen rauw|Beef breast boneless raw||152|22.3|7|0|0
    Gehakt kalfs- rul gebakken|Minced veal shallow fried|Kalfsgehakt rul gebakken|286|27.1|19.6|0.2|0.1
    Runderbraadworst rauw|Sausage beef Braadworst raw|Rundersaucijs rauw|207|18.1|14.6|1|0
    Spareribs varkens- rauw|Pork sparerib raw||200|20.4|13|0.1|0.4
    Runder ribeye steak rauw|Beef ribeye steak raw||170|21.2|9.4|0|0
    Runder T-bone steak rauw|Beef T-bone steak raw||189|22|11.2|0|0
    Gehakt mager runder- rauw|Minced beef lean raw|Rundergehakt mager rauw|182|20|11.1|0.3|0.5
    Gehakt mager runder- rul gebakken|Minced beef lean shallow fried|Rungergehakt mager rul gebakken|293|29.6|19.1|0.4|0.5
    Jus 75% vet gebonden bereid m juspoeder|Gravy 75% fat thickend prep w gravy instant powder||625|1.2|65.6|7.3|0.2
    Jus 75% vet ongebonden bereid m juspoeder|Gravy 75% fat clear prep w gravy instant powder||632|1.2|67.4|5.1|0.2
    Jus 5% vet ongebonden bereid m juspoeder|Gravy 5% fat clear prep w gravy instant powder||69|0.9|5.1|4.6|0.2
    Kalfsschnitzel ongepaneerd bereid|Veal schnitzel not breaded prepared||144|29.4|2.9|0|0.1
    Schnitzel vegetarisch obv melk gevuld m kaas onbereid verrijkt m ijzer|Schnitzel vegetarian based on milk filled w cheese unprepared fortified w iron|Schnitzel Valess m kaas|218|14.8|9.6|16.6|3
    Schnitzel vegetarisch obv melk gevuld diverse smaken onbereid verrijkt m ijzer|Schnitzel vegetarian based on milk filled several flavours unprepared fortified w iron|Schnitzel Valess gevuld|206|11.4|8.3|19.8|3.8
    Yoghurt Turkse 4% vet|Yoghurt Turkish 4% fat||69|3.9|4.2|3.3|0
    Kaas Turkse 60+ obv koemelk blik|Cheese Turkish 60+ cow's milk canned||287|12.7|26|0.4|0
    Kaas schapen-/geiten- Turkse 50+ blik|Cheese sheep/goat Turkish 50+ canned|Turkse schapenkaas/geitenkaas 50+ blik|297|15.5|26.1|0.1|0
    Tarwebrood bruin Turks|Wheat bread brown Turkish|Turks bruinbrood|248|10.6|1.7|44.2|7
    Yoghurt Turkse 10% vet|Yoghurt Turkish 10% fat||119|3.5|10.1|3.1|0
    Paprika oranje rauw|Sweet pepper orange raw||28|0.8|0.3|4.7|1.7
    Bonen witte blik/glas|Beans white canned|Witte bonen blik/glas|105|6.9|0.8|14|7.1
    Pap havermout- bereid m halfvolle melk ongezoet|Porridge oatmeal prepared w semi-skimmed milk unsweetened|Havermoutpap bereid m hv melk ongezoet|79|4.4|2|10.5|1.2
    Olie lijnzaad-|Oil linseed|Lijnzaadolie|900|0|100|0|0
    Boterproduct melange ongezouten|Butter product melange unsalted||676|0.7|74.3|0.9|0
    Tarwebrood bruin natriumarm|Wheat bread brown low sodium|Bruinbrood natriumarm|239|9.9|1.8|43.3|4.9
    Zemelen haver-|Oat bran|Haverzemelen|375|16.2|7.4|52.2|17.5
    Appelflap m bladerdeeg m roomboter|Apple turnover w puff pastry w butter||311|2.6|13.7|43|1.9
    Siroop ahorn-|Syrup maple|Maple syrup|269|0|0.1|67.2|0
    Stroop appel- verrijkt m ijzer|Syrup apple fortified w iron|Appelstroop verrijkt met ijzer|287|1.6|0|67.6|5.2
    Room spuitbus minder vet m suiker|Cream whipped low fat w sugar canned||222|2.6|18.5|11.3|0.1
    Snoepje room- hard|Sweets cream hard|Karamelsnoepje hard|414|0.5|8.6|83.9|0.1
    Groente soep- gekookt|Vegetables for soup cooked|Soepgroente gekookt|31|1.1|0.3|4.6|2.8
    Tonijn bereid z vet|Tuna prepared wo fat||122|29.2|0.6|0|0
    Tilapia bereid z vet|Tilapia prepared wo fat||128|26.2|2.7|0|0
    Gefrituurde peulvruchtensnack Bara Surinaams|Deep fried legumes Bara Surinam||284|7.3|9.6|39.8|4.5
    Bonen mung- gekookt|Beans mung boiled|Urdi gekookt/Katjang idjoe gekookt|102|7.6|0.4|13.3|7.6
    Yoghurt volle Activia m vruchten/vanille|Yoghurt full fat w fruit/vanilla Activia|Vruchtenyoghurt/vanilleyoghurt vol Activia|94|3.8|3|12.2|0.6
    Kaassouffle bereid m vlb frituurvet|Pastry puff cheese filled deep-fried in liquid fat|Kaassouffle snackbar/Kaassouffle gefrituurd|359|7.3|23.1|29.8|1
    Bladerdeeg m roomboter, bereid|Puff pastry w butter baked||511|5.1|28.7|57|2.3
    Knackebrod glutenvrij Fette Croccanti Schar|Crispbread gluten free Fette Croccanti Schar|Cracker knackebrod glutenvrij fettecroccanti Schar|368|7.4|1.9|79.1|2.3
    Vleeswaren 10-20 g vet excl leverprod gem|Processed meat prod 10-20 g fat excl liver av||200|15.3|14|3.3|0.1
    Amsoi gekookt|Mustard leaves boiled|Mosterdblad gekookt|21|2|0.2|1.8|2
    Paksoi gekookt|Cabbage pak-choi cooked||17|1.6|0.2|1.7|1
    Pastinaak rauw|Parsnip raw||71|1.8|1.1|11|4.7
    Pastinaak gekookt|Parsnip boiled||68|1.6|1.2|11.4|2.6
    Sopropo gekookt|Bitter gourd pods boiled|Bitterkomkommer gekookt|18|0.8|0.2|2.3|2
    Okra gekookt|Okra boiled|Oker gekookt|22|1.9|0.2|2|2.5
    Bakkeljauw (gedroogde gezouten kabeljauw) geweekt gekookt|Cod dried, salted, soaked, boiled|Gedroogd gezouten kabeljauw/klipvis geweekt gekookt|138|32.5|0.9|0|0
    Saus ketjap-|Soy sauce based on Ketjap|Ketjapsaus|253|1.6|0.1|61|1
    Gehakt kippen- rauw|Mince chicken raw|Kippengehakt rauw|147|21.5|6.8|0|0
    Margarineproduct 60% vet >17g verz vetz gezouten|Margarine product 60% fat >17 g sat fa salted||532|0.2|59|0.2|0
    Quinoa rauw|Quinoa raw|Quinoa onbereid|354|14.1|6.1|57.2|7
    Quinoa gekookt|Quinoa cooked||114|4.4|1.9|18.5|2.8
    Kaas 30+ jong|Cheese 30+ age 4-8 weeks||280|30.1|17.7|0|0
    Kaas 30+ jong belegen|Cheese 30+ age 8 wk-4 mths||278|29.3|17.9|0|0
    Kaas 30+ belegen|Cheese 30+ age 4-7 mths||306|31.9|19.8|0|0
    Kaas 30+ oud|Cheese 30+ age 10-12 mths||307|31.7|20|0|0
    Kaasproduct m plantaardige vetten Kees jong belegen|Cheeseproduct w veg fat Kees jong belegen||387|29|30.1|0|0
    Kaasproduct m plantaardige vetten Kees oud|Cheeseprod w veg fat Kees oud||403|31|31|0|0
    Spread sandwich- overige smaken|Sandwich spread other flavours|Sandwichspread overige smaken|186|1.6|13.2|14.9|0.9
    Salade coleslaw|Salad coleslaw||191|1.4|16.9|7.1|1.9
    Plantaardig alternatief voor room obv soja Alpro Cuisine Light|Plant-based alternative to cream based on soya Alpro Cuisine Light|Sojaroomalternatief soja keuken light|61|2|4.7|2.5|0.4
    Drink soja- z suiker verrijkt m calcium en vitamines|Drink soya wo sugar fortified w calcium and vitamins|Sojadrink ongezoet verrijkt m calcium en vitamines|34|3.4|1.8|0.6|0.6
    Bonen kidney- rode blik/glas|Beans kidney red canned|Rode kidneybonen blik/glas|116|8.2|0.7|15.1|8.5
    Erwten kikker- blik/glas|Peas chick canned|Kikkererwten blik/glas|140|7.9|2.5|17.9|7.2
    Tarwebrood volkoren verrijkt m vit D en vezel Vollerkoren|Wheat bread wholemeal fortified w vit D and fibre Vollerkoren|Volkorenbrood verrijkt m vit D en vezel Vollerkoren|231|10.6|3|35.6|9.4
    Pasta verrijkt m vezel rauw|Pasta fortified w fibre raw|Macaroni/spaghetti vezelrijk onbereid|336|11|1.5|64|11
    Bouillon 1-kops bereid|Stock portion prepared|Bouillon Cup-a-Soup e.d. bereid|6|0.3|0.1|0.9|0.1
    Meergranenbrood bruin m zaden verrijkt m ijzer en vitamines Vikorn Vitaminebrood|Multigrain bread brown w seeds fortified w iron and vitamins Vikorn Vitaminebrood||265|11.4|5.5|39.9|5
    Meergranenbrood bruin m zaden verrijkt m ijzer en vitamines Vikorn Volvezel|Multigrain bread brown w seeds fortified w iron and vitamins Vikorn Volvezel||268|11.1|5.8|39.4|6.8
    Mispel|Medlar||50|0.5|0.2|10.6|1.7
    Ansjovis rauw|Anchovy raw||125|20.4|4.8|0|0
    Tarwe gebroken bulgur gekookt|Bulgur wheat cooked||80|3.1|0.2|14.1|4.5
    Yoghurtdrank Ayran Turks|Yogurt drink Ayran Turkish|Drinkyoghurt Ayran Turks|33|2.3|1.6|2|0
    Rundvlees gezouten gedroogd gekruid Pastirma Turks|Beef salted dried seasoned Pastirma Turkish||155|30|3|2|0
    Gehakt runder- ambachtelijke slagerij rauw|Minced beef from butcher raw|Rundergehakt van de ambachtelijke slager rauw|180|20|10.9|0.3|0.5
    Mihoen gekookt|Noodles boiled|Rijstnoedels gekookt|103|1.8|0.2|23|1
    Hummus naturel|Hummus natural|Hoemoes naturel/kikkererwtenspread|320|7.7|25.8|11.3|5.4
    Zeekraal rauw|Glasswort raw||14|0.7|0.2|1.1|2.5
    Tarwebrood volkoren fijn m zaden|Wheat bread wholemeal fine w seeds|Volkorenbrood fijnvolkoren m zaden|273|12.3|7.3|35.7|7.8
    Tarwebrood volkoren fijn m zonnebloempitten|Wheat bread wholemeal fine w sunflower seeds|Volkorenbrood fijnvolkoren m zonnebloempitten|283|11.8|8.6|36.1|6.7
    Tarwebrood volkoren grof m zaden|Wheat bread wholemeal coarse w seeds|Volkorenbrood grofvolkoren m zaden|276|12.6|7.5|35.4|8
    Tarwebrood volkoren grof m zonnebloempitten|Wheat bread wholemeal coarse w sunflower seeds|Volkorenbrood grofvolkoren m zonnebloempitten|285|12.1|8.8|35.8|6.8
    Tarwebrood volkoren grof m pompoenpitten|Wheat bread wholemeal coarse w pumpkin seeds|Volkorenbrood grofvolkoren m pompoenpitten|276|13.6|7.7|34.6|7
    Bier wit|Beer white|Witbier|47|0.5|0|3.7|0.3
    Wodka|Vodka||234|0|0|0|0
    Erwten split- groene gekookt|Peas split green boiled|Spliterwten groene gekookt|122|7.9|1.2|16.6|6.6
    Vruchtendrank appelnectar|Fruit juice drink apple nectar||37|0|0|9.1|0
    Kiwi gele|Kiwi fruit yellow||66|1|0.3|12.4|1.4
    Asperge groene rauw|Asparagus green raw||28|3|0.1|2.8|2.1
    Olijven zwart in water blik/glas|Olives ripe in brine tinned/glass|Zwarte olijven|162|0.9|14|1.7|12.5
    Pesto rode|Pesto red||368|5|35|7|2.4
    Worst grill- kip|Sausage grill chicken|Grillworst kip-|209|13.8|15|4.4|0.3
    Groente roerbakmix Hollandse gekookt|Vegetables for stir-frying Dutch cooked|Hollandse roerbakgroente gekookt|26|1.6|0.3|3.2|2.3
    Groente roerbakmix Italiaanse gekookt|Vegetables for stir-frying Italian cooked|Italiaanse roerbakgroente gekookt|27|1.1|0.3|3.9|2.1
    Groente roerbakmix oosterse gekookt|Vegetables for stir-frying oriental cooked|Oosterse roerbakgroente gekookt|22|1|0.2|2.8|2.3
    Zeewier nori gedroogd|Seaweed nori dried||254|31.5|1.5|10.5|36.3
    Noodles instant bereid|Noodles instant prepared|Instantnoedels bereid|227|3.4|11.1|27.8|1.4
    Salade kip-sate- lunch/borrel|Salad chicken satay|Kipsate salade lunch/borrel|262|9.6|17.3|16.5|1
    Salade zalm- lunch/borrel|Salad salmon|Zalmsalade lunch/borrel|338|9.3|31|5.2|0.4
    Salade tonijn- lunch/borrel|Salad tuna|Tonijnsalade lunch/borrel|288|11.4|24.1|6.2|0.3
    Salade krab- lunch/borrel|Salad crab|Krabsalade lunch/borrel|282|5.2|24|11.5|0.1
    Salade garnalen- lunch/borrel|Salad shrimp|Garnalensalade lunch/borrel|299|6.7|27.6|5.9|0.3
    Popcorn zoute gepoft z olie|Popcorn salted popped wo oil||377|12.7|3.9|70.3|4.9
    Tarwestokbrood wit m kruidenboter kant-en-klaar|Wheat baguette white w herb butter ready-to-eat|Stokbrood wit met kruidenboter|303|7.8|12.2|39.4|2.3
    Oliebol ongevuld|Doughnut Dutch style plain||245|6.5|9.6|32.2|1.9
    Brownie ongevuld|Brownie wo filling|Brownie zonder noten|421|4.4|19.8|55.4|1.7
    Taai-taai|Biscuit Dutch Taai-taai||353|5.3|0.9|79.9|2.1
    Melk halfvolle lactosevrij|Milk semi-skimmed lactose free|Melk lactosevrij halfvol|44|3.4|1.5|4.4|0
    Boter kruiden-|Herb butter|Kruidenboter|623|1.2|67.7|2.1|0.5
    Stroop schenk-|Golden syrup pourable|Schenkstroop|288|0|0|72|0
    Olie kokos-|Oil coconut|Kokosolie/Kokosvet|892|0|99.1|0|0
    Fudge/karamel zachte|Fudge/caramel soft||435|1.9|16|70.8|0.3
    Muisjes gestampte/roze&witte/blauwe&witte|Aniseed comfits crushed/pink&white/blue&white||402|2|2.4|92|2.2
    Vlokken chocolade- mix wit en puur|Chocolate flakes mix white and dark|Chocoladevlokken mix wit en puur|450|3.2|14.4|75.2|3.5
    Siroop vruchtenlimonade- m suiker en zoetstof 20-25 g KH|Fruit drink conc w sugar and sweetener 20-25 g CHO|Limonadesiroop/ranja m suiker en zoetst 20-25 g KH|94|0.1|0|23.3|0
    Siroop vruchtenlimonade- m 45-50 mg vit C|Fruit drink conc w 45-50 mg vit C|Limonadesiroop/ranja m 45-50 mg vit C|238|0|0|59.6|0
    Mentos|Mentos cheewy dragee||387|0|1.9|92.5|0
    Pasta glutenvrij gekookt|Pasta gluten free cooked|Macaroni/spaghetti glutenvrij gekookt Schar|143|3.6|1|29.5|0.9
    Pasta verrijkt m vezel gekookt|Pasta fortified w fibre boiled|Macaroni/spaghetti vezelrijk gekookt|134|4.4|0.6|25.6|4.4
    Surimi|Surimi|Imitatiekrab|122|6.8|3.6|15.5|0.3
    Chips tortilla overige smaken|Crisps tortilla several flavours|Maischips/mais-chips/tortillachips|487|6.6|25|56.6|4.6
    Groente roerbakmix champignon gekookt|Vegetables for stir-frying mushroom cooked|Champignon roerbakgroente gekookt|25|1.9|0.3|2.6|1.9
    Sardines gegrild|Sardines grilled||171|25.3|7.8|0|0
    Vis vet >5 g vet gem bereid in magnetron z toev|Fish fatty >5 g fat prepared in microwave oven no ingredients added||202|24.7|11.5|0|0
    Filodeeg onbereid|Filo pastry unprepared||286|8|1.9|57.9|2.4
    Melkdrank Yakult Plus|Milkbased drink Yakult Plus||45|1.3|0|10.2|3.1
    Bier Radler|Beer w fruitjuice Radler||39|0.4|0|6.5|0.1
    Bier bok-|Beer bock|Bokbier|61|0.6|0|5.2|0.3
    Yoghurt halfvolle lactosevrij|Yoghurt semi-skimmed lactose free||42|4.5|1.5|2|0
    Yoghurtdrank Actimel vruchten|Yoghurt drink Actimel fruit|Drinkyoghurt Actimel vruchten|72|2.7|1.5|11.7|0.5
    Koolvis (Alaska) rauw|Pollock (Alaska) raw|Alaska pollak rauw|72|16.4|0.7|0|0
    Koolvis (Alaska) gestoomd|Pollock (Alaska) steamed|Alaska pollak gestoomd|120|27.4|1.2|0|0
    Garnalen roze gekookt|Prawns cooked|Noordse garnaal gekookt|70|15.4|0.9|0|0
    Tongschar rauw|Lemon sole raw||73|16.7|0.7|0|0
    Pangasius rauw|Pangasius raw||74|14.9|1.6|0|0
    Rostirondjes diepvries onbereid|Rosti rounds frozen unprepared||178|2|7.3|24.5|3.4
    Vleeswaren natriumarm|Processed meat products low sodium||179|16.1|11.1|3.5|0.2
    Wafel rijst- naturel z zout|Rice cake puffed plain wo salt|Rijstwafel naturel zonder zout|390|6.6|3|81.8|4.7
    Tarwebrood volkoren fijn m pompoenpitten|Wheat bread wholemeal fine w pumpkin seeds|Volkorenbrood fijnvolkoren m pompoenpitten|274|13.2|7.5|34.9|6.8
    Tarwebrood gem v bruin en volkoren|Wheat bread av brown and wholemeal|Bruinbrood en volkorenbrood gem|237|10.5|2|41.1|5.8
    Tarwebrood gem v bruin en volkoren m zaden|Wheat bread av brown and wholemeal w seeds|Bruinbrood en volkorenbrood gem m zaden|276|11.9|7.2|37.4|7.1
    Halvarineproduct Vita d'Or Goed begin|Low fat margarine product Vita d'Or Goed begin||347|0|38|1.1|0.1
    Artisjokharten blik/glas|Artichoke hearts canned||27|2.1|0.4|1.5|4.8
    Sla romaine rauw|Lettuce romaine raw|Bindsla/Sla bind-/Sla Romaanse/Sla Romeinse|17|1.2|0.3|1.2|2.1
    Aardappel(product) naturel voorgekookt koelvers|Potato product natural precooked chilled||80|1.7|0.4|16.6|1.7
    Olie rijst-|Oil rice bran|Rijstolie/Rijstvliesolie|900|0|100|0|0
    Olie frituur-|Frying oil|Frituurolie|900|0|100|0|0
    Olijven gem in water blik/glas|Olives av in brine tinned/glass||122|0.9|11.6|0.8|5.6
    Halvarine 40% vet <17 g verz vetz verrijkt m vit E gezouten|Low fat margarine 40% fat <17g sat fa fortified w vit E salted||360|0|40|0|0
    Meloen cantaloupe|Melon cantaloupe|Meloen kantaloep|38|0.8|0.2|7.9|0.9
    Bak- en braadvet Vita d'Or Vlees&jus vloeibaar|Cooking fat liq Vita d'Or vlees&jus||878|0.3|97|0.9|0
    Saus chili-|Sauce chilli|Chilisaus|149|0.3|0.3|35.8|0.7
    Saus knoflook- 30-<40% olie|Sauce garlic 30-<40% oil|Knoflooksaus 30-<40% olie|378|1|36.2|12|0.2
    Runderrosbief (vleeswaar)|Roastbeef||156|27.2|5.1|0.2|0
    Ontbijtproduct Special flakes m chocolade|Breakfast cereal Special flakes w chocolate|Ontbijtgranen tarweflakes met chocolade|404|8.8|6.7|73.4|7.4
    Hagelslag chocolade- extra puur|Chocolate sprinkles extra dark|Chocoladehagelslag extra puur|424|7.8|18.3|53.7|6.6
    Marmelade|Marmalade|Jam marmelade|260|0.3|0.2|63.9|0.8
    Soeppoeder|Soup instant powder||372|9.6|12.1|54.2|4
    Zoutje luchtig mais- Organix Goodies|Cocktail snacks based on corn Organix Goodies||452|8.2|13.7|73.2|1.6
    Vlokken chocolade- wit|Chocolate flakes white|Chocoladevlokken wit|458|5.9|14|77|0
    Kaas Heks'n-|Cheesespread Heks'n kaas|Heksenkaas|356|1.9|34.3|9.7|0.4
    Siroop gember-|Syrup ginger|Gembersiroop|215|0|0.4|52.2|1.2
    Schuimpje|Solid foamed candy Dutch Schuimpje|Banaanschuimpje|366|2.1|0.1|89.2|0
    Kokoswater naturel|Coconut water plain|Kokosnootwater|18|0|0|4.5|0
    Stroop appel- peren|Syrup apple-pear|Appel-perenstroop|253|1.1|0|60.3|3.8
    Kaas Feta|Cheese Feta||274|16.6|22.8|0.6|0
    Nasischijf diepvries onbereid|Rice ball spiced frozen unprepared|Nasibal diepvries onbereid|197|5.3|5.4|31.4|0.7
    Yoghurtdrank verrijkt m calcium|Yoghurt drink fortified w calcium|Drinkyoghurt verrijkt met calcium|55|1.8|0|11.7|0
    Vruchtendrank m zuivel m suiker en zoetstof|Fruit drink w dairy w sugar and sweetener|Vruchtendrank met zuivel Zappie/Xoozz|32|0.1|0|7.8|0
    Kroket oven- vlees diepvries onbereid|Croquette oven meat frozen unprepared|Ovenkroket vlees- diepvries onbereid|247|8.1|14|21.5|1.2
    Kaas room- m kruiden 25-30 g vet|Cheese cream w herbs 25-30 g fat|Roomkaas met kruiden 25-30 g vet/Kaas verse met kruiden 25-30 g vet|291|5.3|28.4|3.4|0
    IJs sorbet-|Sorbet|Sorbetijs|126|0.2|0.1|30.8|0.9
    Kaas witte 45+|Cheese white 45+ feta-like from cow's milk|Witte saladekaas 45+ feta-achtig obv koemelk|247|17.1|19.6|0.6|0
    Bitterbal oven- diepvries onbereid|Croquette Dutch Bitterbal oven frozen unprepared|Ovenbitterbal diepvries onbereid|246|7.9|14.1|21.3|1.2
    Halvarineproduct Vita d'Or Bewust light|Low fat margarine product Vita d'Or Bewust light||270|0|30|0|0.1
    Broodje frikandel- bladerdeegbasis|Snack roll puff pastry w Dutch sausage Frikandel|Frikandelbroodje bladerdeegbasis|327|8|21.2|25.4|0.9
    Focaccia|Focaccia|Brood focaccia|266|7.7|8.7|38.4|1.7
    Zoutje bladerdeeg-|Salty puff pastry cocktail snacks|Zoute bladerdeegstengel/Bladerdeegzoutje|501|10|27|53|2.9
    Olie sesam-|Oil sesame|Sesamolie|898|0.2|99.7|0|0
    Kaas Ricotta|Cheese Ricotta||141|8|10.3|3.9|0
    Pinda's omhuld m melkchocolade|Peanuts milkchocolate coated|Melkchocoladepinda's|568|16.1|39.1|35.5|4.8
    Ontbijtproduct Tresor Kellogg's|Breakfast cereal Tresor Kellogg's|Ontbijtgranen Tresor Kellogg's|452|7.3|15.5|69|3.7
    Ontbijtproduct Honey pops Kellogg's|Breakfast cereal Honey pops Kellogg's|Ontbijtgranen honey pops Kellogg's|384|5.2|1.5|85|4.6
    Bessen goji- gedroogd|Goji berries dried|Gojibessen|343|14.3|0.4|64.1|13
    Hennepzaad|Hemp seed||592|31.6|48.8|4.7|4
    Chiazaad gedroogd|Chia seeds dried||443|16.5|30.7|7.7|34.4
    Bessen moerbei- rauw|Mulberries raw|Moerbeibessen|45|1.4|0.4|8.1|1.7
    Olie koolzaad-/raapzaad-|Oil rapeseed|Koolzaadolie/Raapzaadolie|899|0|99.9|0|0
    Munt vers|Mint fresh||49|3.8|0.7|5.1|3.5
    Olie palm-|Oil palm|Palmolie/Palmvet|899|0|99.9|0|0
    Koffie latte macchiato vers bereid|Coffee latte macchiato freshly made||46|2.5|2.5|3.4|0
    Tarwebrood volkoren tijger-|Wheat bread wholemeal Tijger|Tijgerbrood volkoren/Volkorenbrood m gerstemoutmeel|238|10.8|2.3|40.4|6.4
    Olie plantaardig gem|Oil vegetable av||898|0.1|99.7|0|0
    Drop m schuim|Liquorice Dutch type sweet w foam||334|6.1|0.3|76.6|0.6
    Tarwemaisbrood wit m zaden|Wheat corn bread white w seeds|Maisbrood wit m zaden|298|12.2|8.2|40.7|6
    Tarwebrood wit gem v melk- en waterwit m zaden|Wheat bread white av milk/water based w seeds|Witbrood gem van melk- en waterwit m zaden|288|10.7|6.9|43.5|4.3
    Aardappel(product) gekruid voorgekookt koelvers|Potato product seasoned precooked chilled||80|1.7|0.4|16.6|1.7
    Noten amandelen m vliesje ongezouten|Almonds w skin unsalted||622|25.4|53.4|5|10.2
    Noten para- gezouten|Brazil nuts salted|Paranoten gezouten|687|14.3|67.1|2.6|7.5
    Biscuit melk- AH/Jumbo|Biscuit milkbiscuit AH/Jumbo||488|9.9|21|62|5.5
    Thee automaat- m suiker|Tea vending machine w sugar||15|0|0|3.7|0
    Koffie automaat- m suiker|Coffee from vending machine w sugar||16|0.2|0|3.8|0
    Soep tomaten- m vermicelli|Soup tomato w noodles|Tomatensoep met vermicelli|24|0.8|0.6|3.6|0.8
    Biscuit ontbijt- Liga Belvita|Biscuit Liga Belvita ontbijtbiscuits||446|7.7|14.8|67.7|5.5
    Kikkers/muizen fondant m chocolade|Frogs/mice fondant w chocolate||393|1|5.3|84.7|0.9
    Sap vruchten- Healthy People Cranberry|Juice fruit Healthy People Cranberry|Vruchtensap Healthy People Cranberry|49|0.1|0|12|0
    Bier Radler alcoholvrij|Beer w fruit juice Radler alcohol free||34|0.2|0|8.3|0
    Rijst noten- rauw m geconfijt fruit, noten en zaden|Rice white raw w candied fruit, nuts and seeds|Notenrijst onbereid|385|7.9|15.1|51.7|5.6
    Salade kaas- lunch/borrel|Salad cheese|Kaassalade lunch/borrel|422|9|39.4|6.8|0.4
    Perzik m schil|Peach w skin||40|1|0.1|7.2|2
    Vruchtendrank sap m water|Fruit juice drink juice and water||22|0.2|0|5|0.1
    Koek ontbijt- m chocolade|Cake Dutch spiced ontbijtkoek w chocolate|Ontbijtkoek met chocolade|316|2.8|3.3|67.1|3.5
    Pap Nestle Pyjamapapje kant-en-klaar|Porridge Nestle Pyjamapapje ready-to-eat||83|2.3|2.7|12.3|0.4
    Gehakt rul vegetarisch obv soja onbereid verrijkt m ijzer en vit B12 De Vegetarische Slager|Minced meat vegetarian based on soya unprepared fortified w iron and vitamin B12 De Vegetarische Slager||125|24|0.5|2.9|6.4
    Suiker poeder-|Sugar powdered|Poedersuiker|396|0|0|99|0
    Chocolade gevuld m karamel Rolo|Chocolate filled w caramel Rolo||477|4.4|20.4|68.4|1.2
    Varkensrollade (vleeswaar)|Pork rolled (processed meat product)||129|19.7|5.1|1.1|0.1
    Cracker mini- naturel|Cracker mini unflavoured|Minicracker naturel|442|10.9|12.9|69.3|2.7
    Cracker mini- m smaakje|Cracker mini flavoured|Minicracker m smaakje|435|10.4|12.6|68.3|3.5
    Aardappelschijfjes/-partjes ed gekruid diepvries onbereid|Potatoes slices/parts frozen w spices unprepared|Aardappelpartjes/-schijfjes ed gekruid diepvries onbereid|134|2.5|3.8|21.2|2.5
    Tapenade v tomaten|Tapenade tomato||291|3.1|24.7|12.2|4
    Drink rijst- z suiker|Rice drink wo sugar|Rijstdrink|65|0.3|1|13.7|0.3
    Aioli|Aioli|Saus knoflook- aoli/Knoflooksaus aioli|726|1.5|78.6|2.9|0.1
    Knackebrod Oerknack Bolletje|Crispbread Oerknack Bolletje|Cracker knackebrod Oerknack Bolletje|427|15|12.3|60.3|7.5
    Beschuit boeren-|Crispbakes Dutch farmers type||440|16|15|56|8.5
    Noten wal- gezouten|Walnuts salted|Walnoten gezouten|706|15.9|68.1|5.1|4.6
    Noten macadamia gezouten|Nuts macadamia salted|Macadamianoten gezouten|753|7.8|76.1|5.4|8
    Noten pistache ongezouten|Pistachio nuts unsalted|Pistachenoten ongezouten|592|23.8|48.3|10.8|9.5
    Noten amandelen m vliesje gezouten|Almonds w skin salted||622|25.4|53.4|5|10.2
    Drink amandel- m suiker verrijkt m calcium en vitamines|Drink almond w sugar fortified w calcium and vitamins|Amandeldrink Orignal/Amandeldrink naturel|23|0.4|1.1|2.9|0.2
    Drink amandel- z suiker verrijkt m calcium en vitamines|Drink almond unsweetened fortified w calcium and vitamins|Amandeldrink ongezoet|13|0.3|1.1|0.5|0.2
    Kiwi gem|Kiwi fruit av||64|1|0.6|11.4|2
    Guacamole|Guacamole||153|1.7|14.5|2.5|2.6
    Glazuur suiker-|Icing (sugar)||354|0|0|88.4|0
    Ontbijtproduct Cornflakes Plus/1 de Beste|Breakfast cereal cornflakes Plus/1 de Beste|Ontbijtgranen cornflakes Plus/1 de Beste|375|7.8|0.5|83|3.8
    Boterproduct melange gezouten|Butter product melange salted||675|0.7|74.3|0.9|0
    Ontbijtproduct Honey hoops Crownfield|Breakfast cereal Honey hoops Crownfield|Ontbijtgranen Honey hoops Crownfield|386|9.1|3|76.8|7.7
    Ontbijtproduct Chocoschelpjes G'woon|Breakfast cereal Chocoschelpjes G'woon|Ontbijtgranen Chocoschelpjes G'woon|381|10|2.9|75.6|6.4
    Siroop vruchtenlimonade- m zoetstof Karvan Cevitam|Fruit drink concentrate w sweetener Karvan Cevitam|Limonadesiroop/ranja met zoetstof Karvan Cevitam|25|0.2|0|5.9|0.1
    Wafel rijst- m vruchtensmaak Organix|Rice cakes puffed w fruit flavour Organix|Rijstwafel met vruchtensmaak Organix|390|6.8|1.1|88|0.3
    Tzatziki|Tzatziki||156|4|13.4|4.1|0.6
    Cake madeleine cakereepjes Lotus|Cake madeleine cake bars Lotus||424|6.2|21.4|49.4|4.5
    Kruidnoten|Biscuit spiced small Kruidnoten|Pepernoten|442|5.8|11.8|77.1|2
    Chocolade extra puur|Chocolate extra dark||578|9.2|45.4|27.2|11.8
    Bakmix voor pannenkoeken meergranen-|Bakery mix for pancakes multigrain|Pannenkoekenmix meergranen|339|11.4|2|63.8|10.2
    IJs room- m karamel en noten|Ice cream dairy w caramel and nuts|Roomijs met karamel en noten/Karamelijs met noten|243|3.2|12.3|29.8|0.3
    Saus oester-|Sauce oyster|Oestersaus|105|1.5|0.2|24.3|0.3
    Anijszaad|Anise seed||384|17.6|15.9|35.4|14.6
    Noten pecan- gebrand m olie gezouten|Pecannuts oil roasted salted|Pecannoten gezouten gebrand|750|9.2|75.2|4.3|9.5
    Rijst noten- gekookt m geconfijt fruit, noten en zaden|Rice white boiled w candied fruit, nuts and seeds|Notenrijst gekookt|206|5.6|6.3|30.8|2
    Gehaktbal varkens- m ei en paneermeel rauw|Minced meat ball pork raw w egg and breadcrumbs|Varkensgehaktbal m ei en paneermeel rauw|187|19.1|9.9|5.1|0.6
    Ontbijtproduct Honingringetjes 1 de Beste|Breakfast cereal honey loops 1 de Beste|Ontbijtgranen honingringetjes 1 de Beste|381|9|2.8|76.7|6.5
    Worst met-|Sausage dried metworst|Metworst|484|22.3|42.5|2.7|0.8
    Bonen black eyed blik/glas|Beans black eyed canned|Zwartoogbonen blik/glas|126|7.8|0.9|18.9|5.7
    Bonen bruine gekookt|Beans brown boiled|Bruine bonen gekookt|108|6.1|0.7|15.2|8.1
    Linzen bruine blik/glas|Lentils brown canned||112|7.6|0.8|15.6|5.8
    Bonen cannellini blik/glas|Beans cannellini canned|Cannellini bonen blik/glas|113|7.1|1.1|15|7.1
    Bonen chili- blik/glas|Beans chilli canned|Chilibonen blik/glas|106|6.3|0.8|15.8|5.1
    Kapucijners jonge blik/glas|Peas marrowfat young canned|Veldertjes blik/glas|93|5.7|0.7|13.2|5.5
    Bonen kidney- rode gekookt|Beans kidney red boiled|Rode kidneybonen gekookt|115|8.3|0.7|13.9|9.8
    Linzen rode gekookt|Lentils red boiled||110|7.7|0.6|16.1|4.8
    Bonen witte gekookt|Beans white boiled|Witte bonen gekookt|113|7.8|1|13.4|9.9
    Bonen zwarte blik/glas|Beans black canned|Zwarte bonen blik/glas|113|7.9|1|14.1|8
    Soep erwten- m vlees|Soup split pea w meat|Erwtensoep met vlees|77|4.9|3|6.3|2.8
    Berenklauw bereid m vloeibaar frituurvet|Meatball Berenklauw deep-fried in liquid fat|Berenklauw snackbar/Berenklauw gefrituurd|213|10.3|16.6|4.9|1.2
    Kipkorn bereid m vloeibaar vet|Chicken sticks breaded deep-fried in liquid fat|Kipkorn snackbar/Kipkorn gefrituurd|381|11.6|29.7|16.5|0.8
    Vet kippen-|Fat chicken|Kippenvet|900|0|100|0|0
    Olie palmpit-|Oil palmkernel|Palmpitolie|899|0|99.9|0|0
    Kaas Danish Blue|Cheese Danish Blue|Blauwschimmelkaas Catello blue/Danablu ed|350|20.5|29.5|0|0
    Melk halfvolle verrijkt m calcium en vit D|Milk semi-skimmed fortified w calcium and vit D||47|3.5|1.6|4.7|0
    Taart appel- zandtaardeeg gem|Apple pie Dutch w shortbread average|Appeltaart/appelgebak gemiddeld|225|2.9|9.1|31.9|1.6
    Cake naturel gem|Cake plain av||398|5.7|22.5|42.8|1
    Bladerdeeg gem bereid|Puff pastry av baked||500|7.8|30.9|46.6|1.8
    Cake appel- gem|Cake apple av|Appelcake gemiddeld|261|3.5|13.5|30.5|1.3
    Appelflap gem|Apple turnover av||307|3.6|14.5|39.3|1.7
    Irish coffee|Irish coffee||166|0.7|8.7|6.7|0
    Cake chocolade- gem|Cake chocolate av|Chocoladecake gem|396|5.7|20.3|46.5|2.3
    Melk chocolade- halfvolle m zoetstof|Milk chocolate-flavoured semi-skimmed w sweetner|Chocolademelk halfvolle met zoetstof|48|3.3|1.7|4.5|0.5
    Wijn alcoholvrij|Wine alcohol free||23|0.1|0.1|5.3|0
    Plantaardig alternatief voor yoghurt obv soja z suiker verrijkt m calcium en vitamines|Plant-based alternative to yoghurt based on soya unsweetened fortified with calcium and vitamins|Yoghurtvariatie obv soja naturel ongezoet verrijkt m calcium en vitamines|39|4|2.3|0|0.9
    Cheesecake|Cheesecake|Taart met kwark/roomkaas uit de oven|320|5.4|22.3|24|0.6
    Popcorn zoute kant-en-klaar (gepoft m olie)|Popcorn salted popped w oil||505|8.4|27.1|52.3|9
    Popcorn zoete kant-en-klaar (gepoft m olie)|Popcorn sweet popped w oil||419|4.7|5.8|84.7|4.6
    Azijn balsamico|Vinegar Balsamic||123|0.7|0|25.3|0
    Carrotcake|Carrot cake|Worteltaart|357|4.5|20.9|36.9|1.5
    Bananenbrood|Banana bread|Banana bread|298|4.7|13.2|38.9|2.1
    Paneermeel kruiden-|Bread crumbs w herbs|Kruidenpaneermeel|343|10.3|3.7|65.1|3.9
    Peper zoete gevuld m roomkaas|Sweet pepper stuffed w cream cheese||161|3.6|15.2|2.2|0.9
    Hagelslag chocolade- mix wit en melk|Chocolate sprinkles mix white and milk|Chocoladehagelslag mix wit en melk/Hagelmix melk|452|5.8|14.1|74.2|2.4
    Vlokken chocolade- mix wit en melk|Chocolate flakes mix white and milk|Chocoladevlokken mix wit en melk|456|5.9|14.5|74.5|1.8
    Skyr m vruchten magere|Skyr skimmed w fruit|Vruchtenyoghurt Skyr (IJslandse stijl) mager|71|9.3|0|7.9|0.1
    Bakmix voor cake naturel|Bakery mix for cake plain|Cakemix naturel|372|5|0.6|85.7|2.1
    Bamigroenten rauw|Bami vegetables raw|Bamipakket rauw|27|1.8|0.1|3.5|2.2
    Cracker luchtige naturel|Crispbread light plain||380|13|3.5|72|4.2
    Tonijn m groente en tomatensaus in blik|Tuna w vegetables and tomato sauce canned||98|11.7|3.5|4.8|0.6
    Zeevruchten bereid|Seafood cooked|Zeebanket bereid/Fruits de mer bereid|112|16.9|2.9|4.6|0.1
    Groente roerbakmix champignon rauw|Vegetables for stir-frying mushroom raw|Champignon roerbakgroente rauw|25|1.7|0.3|2.8|2.3
    Groente roerbakmix Hollandse rauw|Vegetables for stir-frying Dutch raw|Hollandse roerbakgroente rauw|27|1.5|0.3|3.5|2.5
    Groente roerbakmix Italiaanse rauw|Vegetables for stir-frying Italian raw|Italiaanse roerbakgroente rauw|28|1.2|0.2|4.2|2.4
    Groente roerbakmix oosterse rauw|Vegetables for stir-frying Oriental raw|Oosterse roerbakgroente rauw|29|1.7|0.2|3.9|2.5
    Yoghurt Griekse magere|Yogurt Greek skimmed||56|8.2|0.1|5|0
    Koek ontbijt- z suiker|Cake Dutch spiced Ontbijtkoek wo sugar|Ontbijtkoek zonder suiker/Ontbijtkoek suikervrij|238|2.9|1.2|53.2|17
    Fruitreep m noten|Fruitbar w nuts||424|7.8|20.9|47.6|6.5
    Pindakaas 100% pinda's ongezouten|Peanut butter 100% peanuts wo salt||611|26.5|49.1|11.6|8.6
    Vet dierlijk gem|Fat animal av||897|0|99.7|0|0
    Vruchten bos- gem|Fruit forest av|Bosvruchten gem/Rood fruit gem|39|0.9|0.1|6|2.6
    Kalfsvlees gem rauw|Veal av raw||127|21.3|4.7|0|0
    Zout bakkers- m toegevoegd jodium|Salt bakers w added iodin|Bakkerszout met toegevoegd jodium|0|0|0|0|0
    Cacaopoeder magere|Cocoa powder low fat||332|23.4|11|12.4|45
    Pasta noten- 100% noten ongezouten|Nut paste mixed nuts unsalted|Notenpasta|639|19.8|55.9|10.9|6.6
    IJs yoghurt- m vruchten|Ice cream yoghurt based w fruit|Yoghurtijs m vruchten|165|2.6|6.4|23.9|0.9
    Skyr naturel magere|Skyr skimmed plain|Yoghurt Skyr (IJslandse stijl) naturel mager|60|10.6|0|3.7|0
    Bakmix voor appeltaart|Bakery mix for apple pie|Appeltaartmix|371|6|0.7|82.3|5.8
    Bakmix voor kwarktaart|Bakery mix for cheesecake|Kwarktaartmix|438|7.7|10.6|77.5|1.1
    Frites groente- voorgebakken diepvries onbereid|Chips vegetable pre-fried frozen unprepared|Groentenfrites/Groentenpatat/Groentefriet voorgebakken diepvries onbereid|142|2.2|7|15|5.2
    Soeppoeder 1-kops soep|Soup instant powder 1 cup soup||372|9.6|12.1|54.2|4
    Melk volle lactosevrij|Milk whole lactose free|Melk lactosevrij vol|64|3.4|3.6|4.6|0
    Zoetstof intensief obv koolhydraten als vulmiddel|Sweetener intensive based on carbohydrates||358|2.8|0.2|85.7|1.1
    Stoofperen bereid m gezoet kookvocht|Stewing pears cooked w sweetened liquid|Peer stoof- met vocht|58|0.2|0.1|13.5|1.1
    Mosselen rauw|Mussels raw||67|11.1|1.7|1.9|0
    Saus carbonara- huishoudelijk bereid|Sauce carbonara homemade|Pastasaus carbonarasaus huishoudelijk bereid|284|13.5|25.1|1|0
    Knoflook bereid z vet|Garlic cooked wo fat|Knoflook geroosterd|127|5.6|0.3|23.8|2.7
    Yoghurt geiten- volle|Yoghurt goatmilk full fat|Geitenyoghurt volle|74|3.7|4.7|3.6|0
    IJs room- chocolade|Ice cream chocolate|Chocoladeroomijs|226|3.5|10.4|28.6|1.9
    Viscuisine koolvis m paneermeel-kruidenkorst bereid|Fish cuisine pollock w breadcrumbs and herbs prepared||217|16.3|11.9|10.4|1.3
    IJs room- vanille|Ice cream dairy vanilla flavoured|Vanilleroomijs|220|3|12|24.9|0.6
    IJs vanille-|Ice cream dairy w vegetal fat vanilla flavoured|Vanilleijs/Schepijs vanille-|212|2.9|10.7|25.8|0.4
    IJs room- m vruchten|Ice cream dairy w fruit|Vruchtenijs/Aardbeienijs|194|2.7|8.1|27.1|0.9
    IJs room/vanille- cornet m vruchten|Ice cream dairy/non-dairy cornet w fruit|IJs Cornetto e.d.|269|3.1|10.3|40.5|0.9
    Bakmix voor pannenkoeken volkoren-|Bakery mix for pancakes wholemeal|Pannenkoekenmix volkoren|347|12.2|3.3|62.3|9.9
    Mousse chocolade- kant-en-klaar|Mousse chocolate ready-to-eat|Chocolademousse kant-en-klaar|189|5.3|7.5|23.9|2.3
    Frikandel speciaal|Sausage Dutch Frikandel w sauce and onion||230|10.2|16.5|9.2|1.7
    Aardpeer rauw|Jerusalem artichoke raw|Topinamboer rauw/Jeruzalem artisjok rauw|75|2|0.5|13.4|4.3
    Meloen gem|Melon av||31|0.5|0|6.9|0.5
    Candybar gem|Candybar av||478|5.4|21.5|65.1|1.5
    Pindarotsjes|Chocolate filled w peanuts||582|15.8|42.6|31|5.9
    Snoepmix|Candy mix||328|5.8|0.3|75.3|0.5
    Siroop vruchtenlimonade- m suiker en zoetstof 30-35 g KH|Fruit drink conc w sugar and sweetener 30-35 g CHO|Limonadesiroop/ranja m suiker en zoetst 30-35 g KH|134|0|0|33.4|0
    Noodles instant onbereid|Noodles instant onbereid|Instantnoedels onbereid|461|10.2|17.2|64.6|3.6
    Zaden en pitten gem|Seeds and kernels av||562|19.1|44.8|10.5|20.5
    Spread fruit-|Fruit spread|Jam 33% minder suiker/fruitspread|162|0.5|0.1|38|1.8
    Vruchtendrank Dubbeldrank|Fruit juice drink Dubbeldrank||45|0.2|0|10.8|0.3
    Margarineproduct 60% vet <17g verz vetz gezouten|Margarine product 60% fat <17g sat fa salted||536|0|59.5|0.2|0
    Halvarine Blue Band|Low fat margarine Blue Band||357|0.3|39|1.1|0.1
    Glutenvrij brood donker|Gluten free bread dark|Glutenvrij bruinbrood|205|4.1|3.6|35|8.3
    Glutenvrij brood licht|Gluten free bread light|Glutenvrij witbrood|212|4.1|3.1|38.9|6.1
    Glutenvrij brood meerzaden|Gluten free bread multiseeds|Glutenvrij meerzadenbrood|236|5|7|33.5|9.7
    Glutenvrij brood zuurdesem|Gluten free bread sourdough|Glutenvrij zuurdesembrood|266|4.3|4.2|49|7.7
    Kruiden tuin- vers gem|Herbs green fresh av|Groene kruiden vers gemiddeld|43|3.3|0.7|4.1|3.2
    Margarineproduct 45% vet <17 g verz vetz ongezouten|Margarine product 45% fat <17g sat fa unsalted||406|0.2|45|0.2|0
    Gnocchi gekookt|Gnocchi cooked||155|3.5|0.2|34|1.8
    Gnocchi onbereid|Gnocchi unprepared||174|3.9|0.3|37.9|1.9
    Limonade vruchten- m suiker en zoetstof 7-9 g KH|Juice drink w sugar and sweetener 7-9 g CHO|Frisdrank met suiker en zoetstof 7-9 g KH|31|0|0|7.7|0
    Halvarineproduct Albert Heijn light|Low fat margarine Albert Heijn light||270|0|30|0|0
    Halvarineproduct Albert Heijn Goed Begin|Low fat margarine Albert Heijn Goed Begin||351|0|39|0|0
    Halvarineproduct Jumbo Goed Begin|Low fat margarine Jumbo Goed Begin||347|0.1|38|1.1|0
    Halvarine Jumbo|Low fat margarine Jumbo||356|0.1|39|1.2|0
    Smeltjus bereid|Gravy Smeltjus prepared||260|0.4|28|1.6|0
    Drink haver- z suiker verrijkt m calcium en vitamines|Drink oat wo sugar fortified w calcium and vitamins|Haverdrink m calcium en vitamines|44|0.5|1.5|6.7|1
    Bonen bruine blik/glas geen zout toegevoegd|Beans brown canned/glass no salt added|Bruine bonen blik/glas zonder toegevoegd zout|118|8|0.9|15.9|7.2
    Linzen blik/glas geen zout toegevoegd|Lentils canned/glass no salt added|Linzen blik/glas zonder toegevoegd zout|93|7.7|0.5|12.5|3.8
    Erwten kikker- blik/glas geen zout toegevoegd|Peas chick canned/glass no salt added|Kikkererwten blik/glas zonder toegevoegd zout|117|6.8|2.5|13.5|6.5
    Bonen kidney- rode blik/glas geen zout toegevoegd|Beans kidney red canned/glass no salt added|Kidneybonen rode blik/glas zonder toegevoegd zout|102|7.7|0.7|13|6.6
    Peulvruchten gem gekookt|Pulses average boiled||117|8.2|1.3|14.4|7.6
    Groente hutspot- rauw|Vegetables mixed carrot-onion raw|Hutspotgroente rauw|35|0.9|0.2|5.9|3.1
    Groente hutspot- gekookt|Vegetables mixed carrot-onion boiled|Hutspotgroente gekookt|34|0.8|0.2|5.9|2.7
    Groente roerbakmix Mexicaanse rauw|Vegetables for stir-frying Mexican raw|Mexicaanse roerbakgroente rauw|51|2.7|0.5|7.1|3.6
    Groente roerbakmix Mexicaanse gekookt|Vegetables for stir-frying Mexican boiled|Mexicaanse roerbakgroente gekookt|48|2.4|0.5|6.7|3.4
    Ui rode rauw|Onion red raw||37|1.3|0.4|5.6|2.5
    Ui rode gekookt|Onion red boiled||43|1.7|0.2|7.6|2.1
    Wafel mais- naturel m zout|Corn cakes puffed plain w salt|Maiswafel m zout|385|7.4|1.1|85|2.5
    Drink haver- z suiker|Drink oat wo sugar|Haverdrink z suiker|40|0.3|1.1|7.1|0.5
    Drink amandel- z suiker|Drink almond unsweetened|Amandeldrink z suiker|26|0.9|2.2|0.6|0.2
    Plantaardig alternatief voor Goudse kaas obv kokosolie|Plant-based alternative to Gouda cheese based on coconut oil|Veganistische kaas|268|0.3|21.5|17.4|1.7
    Plantaardig alternatief voor Goudse kaas obv kokosolie verrijkt m Ca en Vit B12|Plant-based alternative to Gouda cheese based on coconut oil fortified w Ca and Vit B12|Veganistische kaas verrijkt m Ca en vit B12|286|0.1|21.3|22.7|1.7
    Hummus m groente|Hummus w vegetables|Hoemoes m groente/Kikkererwtenspread m groente|251|5.3|19.1|11|7
    Soepstengel volkoren|Breadsticks wholemeal||385|14.1|6.5|61.9|11.3
    Saus sate- geconcentreerd|Peanut sauce concentrate|Pindasaus geconcentreerd/Satesaus geconcentreerd|437|13.5|25.5|36.5|3.3
    Saus soja-|Soy sauce|Sojasaus|40|5.5|0|4.4|0.1
    Saus wok- teriyaki|Wok sauce teriyaki|Woksaus teriyaki|164|1.9|0.3|38.2|0.5
    Zoutje luchtig aardappelbasis|Cocktail snacks based on potatoes|Zoutje luchtig Heartbreakers/Pom Bar e.d.|514|3.6|28.4|59.7|2.5
    Drink kokos- m suiker verrijkt m calcium en vitamines|Drink coconut w sugar fortified w calcium and vitamins|Kokosdrink m suiker verrijkt m calcium en vitamines|25|0.2|1.6|2.4|0.1
    Kipschnitzel krokant rauw|Chicken schnitzel breaded w corn flakes raw|Kipkrokantschnitzel|265|13.6|14.6|19.2|1.2
    Worst boterham- vegetarisch|Sausage luncheon meat vegetarian||173|8.7|12.9|3.5|4.2
    Pate/smeerworst vegetarisch obv soja/erwt|Pate vegetarian based on soya/pea||235|6.8|19.9|5.5|3.6
    Wrap/tortilla obv tarwe volkoren|Wrap/tortilla wheat wholemeal||277|8.8|5.3|44.1|7.9
    Reepjes/stukjes vegetarisch obv soja/tarwe onbereid|Pieces/chunks vegetarian based on soya/wheat unprepared||171|20.3|6.6|4.4|6.8
    Margarineproduct Becel Romig 60% vet|Margarine product Becel Romig 60% fat||544|0.5|60|0.5|0
    Halvarineproduct 20% vet <10g verz vetz gezouten|Low fat margarine product 20% fat <10g sat salted||180|0|20|0|0
    Muesli krokante m fruit verrijkt m vezel|Muesli crunchy w fruit fortified w fibre|Cruesli e.d./granola m fruit verrijkt m vezel|430|8.2|15.1|59.2|12.3
    Asperge groene gekookt|Asparagus green boiled||27|2.7|0.3|1.7|2.2
    Noten gemengd m cranberry ongezouten|Nuts mixed w cranberry unsalted||555|15|40.4|29.5|6.3
    Muesli krokante m noten verrijkt m vezel|Muesli crunchy w nuts fortified w fibre|Cruesli e.d./granola m noten verrijkt m vezel|456|9.8|19.8|53.6|12.2
    Muesli krokante m chocolade verrijkt m vezel|Muesli crunchy w chocolate fortified w fibre|Cruesli e.d./granola m chocolade verrijkt m vezel|448|9.4|18.1|55.8|12.3
    Kokos geraspt gedroogd|Coconut grated, dried||674|7.1|64.8|8.6|14.4
    Seroendeng|Seroendeng||609|12.9|50.9|19.6|10.3
    Bouillon geconcentreerd m groente of vlees pot|Stock concentrated w vegetables or meat pot||53|5.7|1.7|3.3|1
    Peulvruchten gem gedroogd|Pulses average dried||335|23.1|3.9|43.6|16.4
    Eiwitreep m pinda|Protein bar w peanut||506|22.2|30.7|30.3|9.8
    Eiwitreep m chocola m zoetstof|Protein bar w chocolate and sweetener||369|36.7|14.8|26.7|8.5
    Saus wok- zoetzure|Wok sauce sweet and sour|Woksaus zoetzure|169|1.1|1.2|38|0.8
    Koek ontbijt- verrijkt m vezel|Cake Dutch spiced Ontbijtkoek fortified w fibre|Ontbijtkoek verrijkt m vezel|285|2.8|0.9|62.4|8.1
    Graanreep Sultana Good Morning|Cereal bar Sultana Good Morning||451|7.7|16.3|66.4|4.2
    Mueslireep verrijkt m vezel|Muesli bar fortified w fibre|Granenreep/havermoutreep verrijkt m vezel|444|9.4|16|59.3|12.7
    Biscuit fruit- verrijkt m vezel|Biscuit fruit fortified w fibre|Fruitbiscuit verrijkt m vezel|388|6.9|7.1|72.5|6.1
    Biscuit meergranen- diverse smaken verrijkt m vezel, vit en min|Biscuit multigrain several flavours fortified w fibre, vit and min||389|8|8.5|65.6|9.2
    Groenteballetjes/-burgers vegetarisch obv soja onbereid verrijkt m ijzer en vit B12|Vegetable balls/burgers vegetarian based on soya unprepared fortified w iron and vit B12|Groenteschijf/-burger|146|14.9|5|7.4|5.8
    Kaas komijne- 48+ gem|Cheese w cumin 48+ average|Komijnekaas|370|22.9|30.5|0.4|0.1
    Meel Johannesbroodpit-|Locust bean gum|Carobmeel/E410|187|3.2|1.3|3.3|74.7
    Couscous volkoren rauw|Couscous wholemael unprepared|Couscous volkoren onbereid|342|12.1|1.9|65|8.4
    Tofu onbereid|Tofu unprepared|Tahoe onbereid/sojakaas vegetarisch onbereid|119|12.4|6.6|1.5|2
    Knolraap rauw|Turnip raw|Meiknolletje rauw/Meiraap rauw|31|0.9|0.3|4.8|2.7
    Knolraap gekookt|Turnip boiled|Meiknolletje gekookt/Meiraap gekookt|17|0.6|0.2|2|2.2
    Varkensvlees gem rauw|Pork av raw||201|19|13.3|1.2|0.2
    Vis mager <5 g vet gem bereid in magnetron z toevoegingen|Fish lean <5 g fat average prepared in microwave oven no ingredients added||112|23.4|2|0|0
    Pepers in zuur in blik/glas|Peppers pickled canned/glass|Jalapeno pepers in zuur|14|0.8|0.1|1.9|0.8
    Kwark magere lactosevrij|Quark low fat lactose-free||57|9.8|0.2|3.8|0
    Couscous volkoren gekookt|Couscous wholemeal boiled||114|4|0.6|21.7|2.8
    Strooigoed|Biscuit spiced with candy mix||411|5.2|8|78.9|1.4
    Drink soja- vruchten/vanille m suiker verrijkt m calcium en vitamines|Drink soya  fruit/vanilla w sugar fortified w calcium and vitamins|Sojadrink vanille/vrucnten gezoet verrijkt|55|2.8|1.4|7.6|0.6
    Drink kokos- z suiker|Drink coconut wo sugar||26|0.3|1.9|1.3|1
    Jackfruit in water blik|Jackfruit in water canned||18|1|0.2|0.8|4.9
    Plantaardig alternatief voor yoghurt obv kokos z suiker|Plant-based alternative to yoghurt based on coconut unsweetened||150|1.5|14.4|3.2|0.5
    Tofureepjes/-blokjes gekruid onbereid|Tofu pieces/chunks seasoned unprepared|Tahoereepjes/-blokjes gekruid vegetarisch onbereid|213|15.7|15.6|1.4|2.3
    Falafel onbereid|Falafel unprepared|Falafel vegetarisch onbereid|231|9.1|9|24|8.8
    Kaasschnitzel vegetarisch onbereid|Cheese schnitzel vegetarian unprepared||291|11.4|15.2|26|2.4
    Balletjes/burgers vegetarisch obv soja/tarwe onbereid|Meatballs/burgers vegetarian based on soya/wheat unprepared||177|19.6|7.5|4.7|6
    Vissticks vegetarisch obv rijst/tarwe onbereid|Fish fingers vegetarian based on rice/wheat unprepared||223|4.9|9.3|28.7|2.9
    Balletjes/burgers vegetarisch obv soja/tarwe onbereid verrijkt m ijzer en vit B12|Meatballs/burgers vegetarian based on soya/wheat unprepared fortified w iron and vit B12||190|16.9|8.7|8.5|5.1
    Balletjes/burgers vegetarisch obv erwt onbereid|Meatballs/burgers vegetarian based on pea unprepared||209|15.6|14.3|3.2|2.3
    Groenteballetjes/-burgers vegetarisch obv soja onbereid|Vegetable balls/burgers vegetarian based on soya unprepared||194|10.4|10.2|12.6|5.2
    Reepjes/stukjes vegetarisch obv soja/tarwe onbereid verrijkt m ijzer en vit B12|Pieces/chunks vegetarian based on soya/wheat unprepared fortified w iron and vit B12||178|20.4|8.4|3|4.6
    Nuggets vegetarisch obv tarwe/erwt diepvries onbereid|Nuggets vegetarian based on wheat/pea frozen unprepared||288|8.4|15.7|26.5|3.6
    Filet americain vegetarisch obv melk verrijkt m ijzer|Filet americain vegetarian based on milk fortified w iron||275|7.8|23.6|6.3|3.2
    Kroket oven- vegetarisch diepvries onbereid|Croquette oven vegetarian frozen unprepared|Ovenkroket vegetarisch diepvries onbereid|261|5.2|15.4|24|3.1
    Dextrose tabletten niet verrijkt|Dextrose tablets non-fortified||369|0|0.5|91|0
    Rempejek pindakoekje|Rempejek peanut biscuit|Koek pinda- rempejek|579|14.4|45.7|25.3|4.2
    Bitterbal bereid m vloeibaar frituurvet|Croquette Dutch Bitterbal deep-fried in liquid fat|Bitterbal snackbar/Bitterbal gefrituurd|362|9.9|26.2|20.7|1.7
    Gehakt rul vegetarisch obv soja onbereid verrijkt m ijzer en vit B12|Minced meat vegetarian based on soya unprepared fortified w iron and vit B12||110|21.8|0.2|1.2|8.4
    Margarine 80% vet >24 g verz vetz gezouten in NEVO recepten|Margarine 80% fat >24 g sat fatty acids salted for NEVO recipes||719|0.1|79.7|0.3|0
    Worst braad- vegetarisch obv erwt onbereid|Sausage roast- vegetarian based on pea unprepared||237|16|17.6|1.6|4.3
    Worst braad- vegetarisch obv soja/tarwe onbereid verrijkt m ijzer en vit B12|Sausage roast- vegetarian based on soya/wheat unprepared fortified w iron and vit B12||178|14.1|11|5.1|1
    Schnitzel/burger vegetarisch obv melk onbereid verrijkt m ijzer|Schnitzel/burger vegetarian based on milk unprepared|Schnitzel/burger Valess|172|11.4|7.9|12.1|3.9
    Burger vegetarisch gevuld m groente en kaas onbereid|Burger vegetarian filled w vegetables and cheese unprepared||216|9|10.8|19.1|3.1
    Cracker luchtige volkoren|Crispbread light wholemeal||355|10|3.6|64.3|12.7
    Plantaardig alternatief voor room obv haver|Plant-based alternative to cream based on oat|Haverroomalternatief|136|0.8|11|8.1|0.4
    Drink soja- chocolade m suiker verrijkt m calcium en vitamines|Drink soya chocolate w sugar fortified w calcium and vitamins|Sojadrink chocolade gezoet verrijkt|60|3|1.7|7.6|0.9
    Spekjes vegetarisch onbereid|Bacon vegetarian unprepared||185|15|10.5|6.1|2.7
    Tempeh onbereid|Tempeh unprepared|Tempeh vegetarisch product onbereid|128|17.6|4.7|0.4|6.2
    Bakmix voor oliebollen|Bakery mix for doughnuts Dutch style|Oliebollenmix|369|11|1|77|3.8
    Kaas 35+|Cheese 35+||302|27.3|20.4|0|0
    Bloem spelt-|Flour spelt|Speltbloem/Speltmeel wit|348|13.2|1.7|67.4|5.1
    Meel spelt- volkoren|Flour spelt wholemeal|Speltmeel volkoren|332|14.4|2.3|56|15.3
    Meel amandel-|Flour almond|Amandelmeel|638|25.3|55.8|3.6|10.1
    Meel tarwegries-|Semolina wheat|Meel gries- tarwe/Griesmeel tarwe-|338|10.8|0.9|66.4|10.4
    Meel haver- volkoren|Flour oat wholemeal|Volkoren havermeel|364|13.4|6.4|58|9.9
    Vlokken spelt-|Flakes spelt|Speltvlokken|340|12.9|2.2|61.4|11.6
    Vlokken gerst-|Flakes barley|Gerstvlokken/Gerstevlokken|332|7.9|2.1|63|14.9
    Meel rijst- volkoren|Flour rice wholemeal|Volkoren rijstmeel|355|8.1|2.6|71.7|6.2
    Bakmix voor pannenkoeken glutenvrij|Bakery mix for pancakes gluten free|Pannenkoekenmix glutenvrij|344|4.9|1|78.4|0.9
    Meel kokos-|Flour coconut|Kokosmeel|343|20.1|12.8|18|37.7
    Pannenkoek kant-en-klaar naturel|Pancake ready-to-eat plain||226|5.3|9.8|27.7|2.1
    Poffertjes kant-en-klaar naturel|Dutch Poffertjes ready-to-eat plain||291|5.5|15.2|31.2|2.3
    Wrap/tortilla obv tarwe en wortel|Wrap/tortilla wheat and carrot|Wortelwrap/Worteltortilla|288|9.8|5|47.8|5.1
    Muesli m fruit en noten|Muesli w fruit and nuts||365|9.1|9|57.2|9.6
    Muesli krokante naturel|Muesli crunchy plain|Cruesli/Granola naturel|422|10.8|10.8|66.1|8.5
    Muesli krokante m fruit|Muesli crunchy w fruit|Cruesli e.d. m fruit/Granola m fruit|419|8.9|11.3|65.8|9.3
    Muesli m fruit zaden en pitten|Muesli w fruit seeds and kernels||359|11.4|8.5|52.9|12.7
    Pannenkoek glutenvrij huishoudelijk bereid|Pancake gluten free homemade||171|5.1|6.5|22.9|0.2
    Poffertjes huishoudelijk bereid|Dutch Poffertjes homemade||154|5.7|4|22.9|1.5
    Bakmix voor brood wit glutenvrij|Bakery mix for bread white gluten free|Broodmix wit glutenvrij|354|5.4|1.6|77.5|3.9
    Bakmix voor brood bruin/meergranen glutenvrij|Bakery mix for bread brown/multigrain gluten free|Broodmix bruin/meergranen glutenvrij|369|6|3.4|76.4|4.1
    Garnalen gemarineerde|Prawns marinated|Garnalen knoflook-/Garnalen wok-/Knoflookgarnaal|184|12.7|11.2|0.9|0.3
    Ontbijtproduct Special flakes naturel|Breakfast cereal Special flakes plain|Ontbijtgranen Special flakes naturel|377|9.9|1.5|77.5|6.8
    Ontbijtproduct 7 granen ontbijt|Breakfast cereal 7 cereals breakfast|Ontbijtgranen 7 granen ontbijt|342|12.1|2.1|64.1|8.9
    Champignon gebakken z vet|Mushroom fried wo fat||26|4.4|0.6|0.2|0.9
    Bonen lupine- gedroogd|Beans lupin dried||324|33.1|9.5|2.8|47.4
    """
    return raw.split(separator: "\n").compactMap { line -> NevoEntry? in
        let p = line.split(separator: "|", omittingEmptySubsequences: false).map(String.init)
        guard p.count == 8 else { return nil }
        var aliases: [String] = []
        let eng = p[1].trimmingCharacters(in: .whitespaces)
        if !eng.isEmpty { aliases.append(eng) }
        let syns = p[2].split(separator: "/").map { String($0).trimmingCharacters(in: .whitespaces) }
        aliases += syns.filter { !$0.isEmpty }
        return NevoEntry(
            name: p[0].trimmingCharacters(in: .whitespaces),
            aliases: aliases,
            kcal:    Double(p[3]) ?? 0,
            protein: Double(p[4]) ?? 0,
            fat:     Double(p[5]) ?? 0,
            carbs:   Double(p[6]) ?? 0,
            fiber:   Double(p[7]) ?? 0
        )
    }
}()
