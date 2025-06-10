// -------------------------------------------------------
//  lib/data/tz_country_map.dart
//
//  بر پایه‌ی  IANA tzdb 2025a  (https://www.iana.org/time-zones)
//  getCountryForTZ('Asia/Tehran')  ➜  'ir'
// -------------------------------------------------------

import 'dart:collection';

/// محتوای رسمی ‎zone.tab‎ (ستون ۱ = کُد کشور ISO-3166-1-alpha-2،
/// ستون ۳ = نام منطقهٔ زمانی).
///
/// ⚠️  میانبر زده‌ایم و جداول چند-خطی را این‌جا پیست کرده‌ایم؛
///     اگر در آینده نسخهٔ جدید IANA آمد کافی است متن zone.tab
///     را جایگزین همین رشته کنی.
const String _zoneTab = r'''
# Country  Coordinates  Zone
AD  +4230+00131 Europe/Andorra
AE  +2518+05518 Asia/Dubai
AF  +3431+06912 Asia/Kabul
AG  +1703-06148 America/Antigua
AI  +1812-06304 America/Anguilla
AL  +4120+01950 Europe/Tirane
AM  +4011+04430 Asia/Yerevan
AO  -0848+01314 Africa/Luanda
AQ  -7750+16636 Antarctica/McMurdo
AQ  -9000+00000 Antarctica/South_Pole
AQ  -6734-06808 Antarctica/Rothera
AQ  -6448-06406 Antarctica/Palmer
AQ  -690022+0393524 Antarctica/Mawson
AQ  -6835+07758 Antarctica/Davis
AQ  -6624+11031 Antarctica/Casey
AQ  -6600+09940 Antarctica/Vostok
AQ  -5430+15857 Antarctica/DumontDUrville
AQ  -720041+0023206 Antarctica/Troll
AR  -3436-05827 America/Argentina/Buenos_Aires
AR  -3124-06411 America/Argentina/Cordoba
AR  -2447-06525 America/Argentina/Salta
AR  -2411-06518 America/Argentina/Jujuy
AR  -2649-06513 America/Argentina/Tucuman
AR  -2926-06651 America/Argentina/Catamarca
AR  -3132-06831 America/Argentina/La_Rioja
AR  -2913-06728 America/Argentina/San_Juan
AR  -3319-06621 America/Argentina/San_Luis
AR  -3253-06849 America/Argentina/Mendoza
AR  -5138-06913 America/Argentina/Rio_Gallegos
AR  -5448-06818 America/Argentina/Ushuaia
AS  -1416-17042 Pacific/Pago_Pago
AT  +4813+01620 Europe/Vienna
AU  -3133+15905 Australia/Lord_Howe
AU  -5430+15857 Antarctica/DumontDUrville
AU  -2960+13352 Australia/Darwin
AU  -3433+13835 Australia/Adelaide
AU  -3729+14458 Australia/Melbourne
AU  -3352+15113 Australia/Sydney
AU  -4253+14719 Australia/Hobart
AU  -2032+12058 Australia/Perth
AW  +1230-06958 America/Aruba
AX  +6006+01957 Europe/Mariehamn
AZ  +4023+04951 Asia/Baku
BA  +4352+01825 Europe/Sarajevo
BB  +1306-05937 America/Barbados
BD  +2343+09025 Asia/Dhaka
BE  +5050+00420 Europe/Brussels
BF  +1222-00131 Africa/Ouagadougou
BG  +4241+02319 Europe/Sofia
BH  +2623+05035 Asia/Bahrain
BI  -0323+02922 Africa/Bujumbura
BJ  +0629+00237 Africa/Porto-Novo
BL  +1753-06251 America/St_Barthelemy
BM  +3217-06446 Atlantic/Bermuda
BN  +0456+11455 Asia/Brunei
BO  -1630-06809 America/La_Paz
BQ  +1209-06817 America/Kralendijk
BR  -0351-03225 America/Noronha
BR  -0127-04829 America/Belem
BR  -0343-03830 America/Fortaleza
BR  -0803-03454 America/Recife
BR  -1259-03831 America/Salvador
BR  -2332-04637 America/Sao_Paulo
BR  -2027-05437 America/Campo_Grande
BR  -1535-05605 America/Cuiaba
BR  -0958-06748 America/Rio_Branco
BR  -0226-05452 America/Eirunepe
BR  -0338-07002 America/Porto_Velho
BR  -0876-06390 America/Boa_Vista
BR  -0314-06022 America/Manaus
BR  -0250-04012 America/Santarem
BS  +2505-07721 America/Nassau
BT  +2728+08939 Asia/Thimphu
BW  -2439+02555 Africa/Gaborone
BY  +5354+02734 Europe/Minsk
BZ  +1730-08812 America/Belize
CA  +4734-05243 America/St_Johns
CA  +4439-06336 America/Halifax
CA  +4906-06640 America/Glace_Bay
CA  +4612-05957 America/Moncton
CA  +5320-06025 America/Goose_Bay
CA  +4823-06131 America/Iqaluit
CA  +5104-11405 America/Edmonton
CA  +4906-12331 America/Vancouver
CA  +4901-08816 America/Toronto
CA  +6107-11402 America/Inuvik
CA  +682059-1134300 America/Resolute
CA  +6200-09205 America/Pangnirtung
CA  +744144-0944945 America/Rankin_Inlet
CA  +690650-1050323 America/Cambridge_Bay
CA  +5332-11328 America/Yellowknife
CA  +6424-11020 America/Coral_Harbour
CA  +4531-07334 America/Montreal
CA  +4909-12307 America/Whitehorse
CA  +4906-12331 America/Metlakatla
CA  +6008-11339 America/Sachs_Harbour
CC  -1210+09655 Indian/Cocos
CD  -0418+01518 Africa/Kinshasa
CD  -1140+02728 Africa/Lubumbashi
CF  +0422+01835 Africa/Bangui
CG  -0416+01517 Africa/Brazzaville
CH  +4723+00832 Europe/Zurich
CI  +0519-00402 Africa/Abidjan
CK  -2114-15946 Pacific/Rarotonga
CL  -3327-07040 America/Santiago
CL  -5309-07055 Pacific/Easter
CM  +0403+01140 Africa/Douala
CN  +3114+12128 Asia/Shanghai
CN  +4545+12641 Asia/Harbin
CN  +2934+10635 Asia/Chongqing
CN  +4348+08735 Asia/Urumqi
CN  +2937+11803 Asia/Nanjing
CO  +0436-07405 America/Bogota
CR  +0956-08405 America/Costa_Rica
CU  +2308-08222 America/Havana
CV  +1455-02331 Atlantic/Cape_Verde
CW  +1207-06900 America/Curacao
CX  -1025+10543 Indian/Christmas
CY  +3510+03322 Asia/Nicosia
CY  +3517+03338 Asia/Famagusta
CZ  +5005+01426 Europe/Prague
DE  +5230+01322 Europe/Berlin
DJ  +1136+04310 Africa/Djibouti
DK  +5540+01235 Europe/Copenhagen
DM  +1518-06123 America/Dominica
DO  +1828-06954 America/Santo_Domingo
DZ  +3647+00303 Africa/Algiers
EC  -0210-07950 America/Guayaquil
EC  -0054-08936 Pacific/Galapagos
EE  +5925+02445 Europe/Tallinn
EG  +3003+03115 Africa/Cairo
EH  +2709-01312 Africa/El_Aaiun
ER  +1520+03853 Africa/Asmara
ES  +4024-00341 Europe/Madrid
ES  +3553-00519 Africa/Ceuta
ES  +2806-01524 Atlantic/Canary
ET  +0902+03842 Africa/Addis_Ababa
FI  +6010+02458 Europe/Helsinki
FJ  -1808+17825 Pacific/Fiji
FK  -5142-05751 Atlantic/Stanley
FM  +0726+15147 Pacific/Chuuk
FM  +0658+15813 Pacific/Pohnpei
FM  +0519+16259 Pacific/Kosrae
FO  +6201-00646 Atlantic/Faroe
FR  +4852+00220 Europe/Paris
GA  +0023+00927 Africa/Libreville
GB  +513030-0000731 Europe/London
GD  +1203-06145 America/Grenada
GE  +4143+04449 Asia/Tbilisi
GF  +0456-05220 America/Cayenne
GG  +4927-00232 Europe/Guernsey
GH  +0533-00013 Africa/Accra
GI  +3608-00521 Europe/Gibraltar
GL  +6411-05144 America/Godthab
GL  +7646-01840 America/Scoresbysund
GL  +7029-02158 America/Danmarkshavn
GL  +7700-03737 America/Thule
GM  +1328-01639 Africa/Banjul
GN  +0931-01343 Africa/Conakry
GP  +1614-06132 America/Guadeloupe
GQ  +0345+00847 Africa/Malabo
GR  +3758+02343 Europe/Athens
GS  -5416-03632 Atlantic/South_Georgia
GT  +1438-09031 America/Guatemala
GU  +1328+14445 Pacific/Guam
GW  +1151-01535 Africa/Bissau
GY  +0648-05810 America/Guyana
HK  +2217+11409 Asia/Hong_Kong
HN  +1406-08713 America/Tegucigalpa
HR  +4548+01558 Europe/Zagreb
HT  +1832-07220 America/Port-au-Prince
HU  +4730+01905 Europe/Budapest
ID  -0610+10648 Asia/Jakarta
ID  -0002+10920 Asia/Pontianak
ID  -0507+11924 Asia/Makassar
ID  -0208+10607 Asia/Jayapura
IE  +5320-00615 Europe/Dublin
IL  +314650+0351326 Asia/Jerusalem
IM  +5409-00428 Europe/Isle_of_Man
IN  +2232+08822 Asia/Kolkata
IO  -0720+07225 Indian/Chagos
IQ  +3321+04425 Asia/Baghdad
IR  +3540+05126 Asia/Tehran
IS  +6409-02151 Atlantic/Reykjavik
IT  +4154+01229 Europe/Rome
JE  +4912-00207 Europe/Jersey
JM  +175805-0764736 America/Jamaica
JO  +3157+03556 Asia/Amman
JP  +353916+1394441 Asia/Tokyo
KE  -0117+03649 Africa/Nairobi
KG  +4254+07436 Asia/Bishkek
KH  +1133+10455 Asia/Phnom_Penh
KI  +0152+15720 Pacific/Tarawa
KI  -0152-15720 Pacific/Enderbury
KI  +0152+17445 Pacific/Kiritimati
KM  -1141+04316 Indian/Comoro
KN  +1718-06243 America/St_Kitts
KP  +3901+12545 Asia/Pyongyang
KR  +3733+12658 Asia/Seoul
KW  +2920+04759 Asia/Kuwait
KY  +1918-08123 America/Cayman
KZ  +4315+07657 Asia/Almaty
KZ  +4448+06528 Asia/Qyzylorda
KZ  +5017+05710 Asia/Aqtobe
KZ  +5113+05121 Asia/Aqtau
KZ  +5228+06921 Asia/Oral
KZ  +4307+06644 Asia/Barnaul
LA  +1758+10236 Asia/Vientiane
LB  +3353+03530 Asia/Beirut
LC  +1401-06100 America/St_Lucia
LI  +4709+00931 Europe/Vaduz
LK  +0656+07951 Asia/Colombo
LR  +0618-01047 Africa/Monrovia
LS  -2928+02730 Africa/Maseru
LT  +5441+02519 Europe/Vilnius
LU  +4936+00609 Europe/Luxembourg
LV  +5657+02406 Europe/Riga
LY  +3254+01311 Africa/Tripoli
MA  +3339-00735 Africa/Casablanca
MC  +4342+00723 Europe/Monaco
MD  +4700+02850 Europe/Chisinau
ME  +4226+01916 Europe/Podgorica
MF  +1804-06305 America/Marigot
MG  -1855+04731 Indian/Antananarivo
MH  +0709+17112 Pacific/Majuro
MH  +0905+16720 Pacific/Kwajalein
MK  +4159+02126 Europe/Skopje
ML  +1239-00800 Africa/Bamako
MM  +1647+09610 Asia/Yangon
MN  +4755+10653 Asia/Ulaanbaatar
MN  +4804+09139 Asia/Hovd
MN  +4804+09155 Asia/Choibalsan
MO  +2214+11335 Asia/Macau
MP  +1512+14545 Pacific/Saipan
MQ  +1436-06105 America/Martinique
MR  +1806-01557 Africa/Nouakchott
MS  +1643-06213 America/Montserrat
MT  +3554+01431 Europe/Malta
MU  -2010+05730 Indian/Mauritius
MV  +0410+07330 Indian/Maldives
MW  -1547+03500 Africa/Blantyre
MX  +1924-09909 America/Mexico_City
MX  +2105-08646 America/Cancun
MX  +2540-10019 America/Monterrey
MX  +2934-10425 America/Chihuahua
MX  +2329-10625 America/Mazatlan
MX  +2058-08937 America/Merida
MX  +1550-09750 America/Oaxaca
MX  +2048-10515 America/Bahia_Banderas
MX  +1840-10323 America/Guadalajara
MX  +2450-10723 America/Hermosillo
MX  +2903-11058 America/Tijuana
MX  +2822-08116 America/Campeche
MX  +1838-08813 America/Matamoros
MY  +0310+10142 Asia/Kuala_Lumpur
MY  +0133+11020 Asia/Kuching
MZ  -2558+03235 Africa/Maputo
NA  -2234+01706 Africa/Windhoek
NC  -2216+16627 Pacific/Noumea
NE  +1331+00207 Africa/Niamey
NF  -2903+16758 Pacific/Norfolk
NG  +0627+00324 Africa/Lagos
NI  +1209-08617 America/Managua
NL  +5222+00454 Europe/Amsterdam
NO  +5955+01045 Europe/Oslo
NP  +2743+08519 Asia/Kathmandu
NR  -0031+16655 Pacific/Nauru
NU  -1901-16955 Pacific/Niue
NZ  -3652+17446 Pacific/Auckland
NZ  -4357-17633 Pacific/Chatham
OM  +2336+05835 Asia/Muscat
PA  +0858-07932 America/Panama
PE  -1203-07703 America/Lima
PF  -1732-14934 Pacific/Tahiti
PF  -0900-13930 Pacific/Marquesas
PF  -2308-13457 Pacific/Gambier
PG  -0930+14710 Pacific/Port_Moresby
PG  -0613+15534 Pacific/Bougainville
PH  +1435+12100 Asia/Manila
PK  +2452+06703 Asia/Karachi
PL  +5215+02100 Europe/Warsaw
PM  +4703-05620 America/Miquelon
PN  -2504-13005 Pacific/Pitcairn
PR  +182806-0660622 America/Puerto_Rico
PS  +3130+03428 Asia/Gaza
PS  +3132+03505 Asia/Hebron
PT  +3843-00908 Europe/Lisbon
PT  +3238-01654 Atlantic/Madeira
PT  +3744-02540 Atlantic/Azores
PW  +0720+13429 Pacific/Palau
PY  -2516-05740 America/Asuncion
QA  +2517+05132 Asia/Qatar
RE  -2052+05528 Indian/Reunion
RO  +4426+02606 Europe/Bucharest
RS  +4450+02030 Europe/Belgrade
RU  +5443+02030 Europe/Kaliningrad
RU  +554521+0373704 Europe/Moscow
RU  +4844+04425 Europe/Volgograd
RU  +5312+05009 Europe/Samara
RU  +5651+06036 Asia/Yekaterinburg
RU  +5500+07324 Asia/Omsk
RU  +5502+08255 Asia/Novosibirsk
RU  +5259+08718 Asia/Barnaul
RU  +5601+09250 Asia/Krasnoyarsk
RU  +5237+10419 Asia/Irkutsk
RU  +4348+08735 Asia/Chita
RU  +6200+12940 Asia/Yakutsk
RU  +6200+13500 Asia/Khandyga
RU  +5203+11328 Asia/Blagoveshchensk
RU  +4803+11420 Asia/Chita
RU  +5305+15837 Asia/Magadan
RU  +5301+15839 Asia/Sakhalin
RU  +6445+17729 Asia/Anadyr
RU  +5934+15048 Asia/Kamchatka
RW  -0157+03004 Africa/Kigali
SA  +2438+04643 Asia/Riyadh
SB  -0931+16012 Pacific/Guadalcanal
SC  -0440+05528 Indian/Mahe
SD  +1536+03232 Africa/Khartoum
SE  +5920+01803 Europe/Stockholm
SG  +0117+10351 Asia/Singapore
SH  -1555-00542 Atlantic/St_Helena
SI  +4603+01431 Europe/Ljubljana
SJ  +7800+01600 Arctic/Longyearbyen
SK  +4809+01707 Europe/Bratislava
SL  +0830-01315 Africa/Freetown
SM  +4355+01228 Europe/San_Marino
SN  +1440-01726 Africa/Dakar
SO  +0214+04522 Africa/Mogadishu
SR  +0550-05510 America/Paramaribo
SS  +0451+03138 Africa/Juba
ST  +0020+00644 Africa/Sao_Tome
SV  +1342-08912 America/El_Salvador
SX  +1803-06303 America/Lower_Princes
SY  +3330+03618 Asia/Damascus
SZ  -2618+03106 Africa/Mbabane
TC  +2128-07108 America/Grand_Turk
TD  +1207+01503 Africa/Ndjamena
TF  -492110+0701303 Indian/Kerguelen
TG  +0608+00113 Africa/Lome
TH  +1345+10031 Asia/Bangkok
TJ  +3835+06848 Asia/Dushanbe
TK  -0922-17114 Pacific/Fakaofo
TL  -0833+12535 Asia/Dili
TM  +3757+05823 Asia/Ashgabat
TN  +3648+01011 Africa/Tunis
TO  -2110-17510 Pacific/Tongatapu
TR  +4101+02858 Europe/Istanbul
TT  +1039-06131 America/Port_of_Spain
TV  -0831+17913 Pacific/Funafuti
TW  +2503+12130 Asia/Taipei
TZ  -0648+03917 Africa/Dar_es_Salaam
UA  +5026+03031 Europe/Kyiv
UA  +4750+03739 Europe/Kharkiv
UA  +4750+03730 Europe/Zaporozhye
UA  +4457+03406 Europe/Simferopol
UG  +0019+03225 Africa/Kampala
UM  +1917+16637 Pacific/Wake
US  +404251-0740023 America/New_York
US  +381515-0854534 America/Chicago
US  +340308-1181434 America/Los_Angeles
US  +471603-1221925 America/Vancouver
US  +454251-1165531 America/Boise
US  +324718-1170914 America/Tijuana
US  +211825-1575130 Pacific/Honolulu
UY  -3453-05611 America/Montevideo
UZ  +3940+06648 Asia/Samarkand
UZ  +4120+06918 Asia/Tashkent
VA  +415408+0122711 Europe/Vatican
VC  +1309-06114 America/St_Vincent
VE  +1030-06656 America/Caracas
VG  +1827-06437 America/Tortola
VI  +1821-06456 America/St_Thomas
VN  +1045+10640 Asia/Ho_Chi_Minh
VU  -1740+16825 Pacific/Efate
WF  -1318-17610 Pacific/Wallis
WS  -1350-17144 Pacific/Apia
YE  +1245+04512 Asia/Aden
YT  -1247+04514 Indian/Mayotte
ZA  -2615+02800 Africa/Johannesburg
ZM  -1525+02817 Africa/Lusaka
ZW  -1750+03103 Africa/Harare
''';

/// جدول نهایی (خوانا در کل پروژه):  *Asia/Tehran → ir*
///
/// > حروفِ کُد کشور همیشه lowercase هستند تا مقایسه ساده باشد.
final Map<String, String> tzToCountry = _buildTzMap();

/// دسترسی ساده:
/// ```dart
/// final iso2 = getCountryForTZ('Asia/Tehran'); // → 'ir'
/// ```
String getCountryForTZ(String tz) => tzToCountry[tz] ?? '';

/* ------------------------------------------------------------------ */
Map<String, String> _buildTzMap() {
  final map = <String, String>{};

  for (final line in _zoneTab.split('\n')) {
    // خط خالی یا کامنت؟
    if (line.trim().isEmpty || line.startsWith('#')) continue;

    // شکستن به ستون‌ها (فاصله/تب پشت سر هم اهمیتی ندارد)
    final parts = line.split(RegExp(r'\s+'));
    if (parts.length < 3) continue;

    final countryCode = parts[0].toLowerCase(); // ISO-3166
    final tz          = parts[2];               // Asia/Tehran و …

    // اگر یک TZ چند بار در فایل آمده باشد ــ نگه‌داشتن اولین نگاشت کافی است.
    map.putIfAbsent(tz, () => countryCode);
  }
  // ‍Unmodifiable => بیرونِ این فایل کسی نتواند Map را دست‌کاری کند.
  return UnmodifiableMapView(map);
}