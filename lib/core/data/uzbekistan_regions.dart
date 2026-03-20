const Map<String, List<String>> uzbekistanRegions = {
  'Toshkent shahri': [
    'Bektemir', 'Chilonzor', 'Mirobod', 'Mirzo Ulug\'bek',
    'Olmazor', 'Sergeli', 'Shayxontohur', 'Uchtepa',
    'Yakkasaroy', 'Yashnaobod', 'Yunusobod',
  ],
  'Toshkent viloyati': [
    'Angren', 'Bekobod', 'Bo\'ka', 'Bo\'stonliq',
    'Chinoz', 'Chirchiq', 'Ohangaron', 'Olmaliq',
    'Oqqo\'rg\'on', 'Parkent', 'Piskent', 'Quyi Chirchiq',
    'Toshkent', 'Yangiyo\'l', 'Yuqori Chirchiq', 'Zangiota',
  ],
  'Andijon viloyati': [
    'Andijon', 'Asaka', 'Baliqchi', 'Bo\'z',
    'Buloqboshi', 'Izboskan', 'Jalaquduq', 'Xo\'jaobod',
    'Marhamat', 'Oltinko\'l', 'Paxtaobod', 'Qo\'rg\'ontepa',
    'Shahrixon', 'Ulug\'nor', 'Xonobod',
  ],
  'Buxoro viloyati': [
    'Buxoro', 'G\'ijduvon', 'Jondor', 'Kogon',
    'Olot', 'Peshku', 'Qorako\'l', 'Qorovulbozor',
    'Romitan', 'Shofirkon', 'Vobkent',
  ],
  'Farg\'ona viloyati': [
    'Bag\'dod', 'Beshariq', 'Buvayda', 'Dang\'ara',
    'Farg\'ona', 'Furqat', 'Oltiariq', 'Qo\'qon',
    'Quva', 'Quvasoy', 'Rishton', 'So\'x',
    'Toshloq', 'Uchko\'prik', 'Yozyovon',
  ],
  'Jizzax viloyati': [
    'Arnasoy', 'Baxmal', 'Do\'stlik', 'Forish',
    'G\'allaorol', 'Jizzax', 'Mirzacho\'l', 'Paxtakor',
    'Sharof Rashidov', 'Yangiobod', 'Zafarobod', 'Zarbdor', 'Zomin',
  ],
  'Xorazm viloyati': [
    'Bog\'ot', 'Gurlan', 'Xiva', 'Xonqa',
    'Hazorasp', 'Qo\'shko\'pir', 'Shovot', 'Urganch',
    'Yangiariq', 'Yangibozor',
  ],
  'Namangan viloyati': [
    'Chortoq', 'Chust', 'Davlatobod', 'Kosonsoy',
    'Mingbuloq', 'Namangan', 'Norin', 'Pop',
    'To\'raqo\'rg\'on', 'Uchqo\'rg\'on', 'Uychi', 'Yangiqo\'rg\'on',
  ],
  'Navoiy viloyati': [
    'Karmana', 'Konimex', 'Navbahor', 'Navoiy',
    'Nurota', 'Qiziltepa', 'Tomdi', 'Uchquduq', 'Xatirchi',
  ],
  'Qashqadaryo viloyati': [
    'Chiroqchi', 'Dehqonobod', 'G\'uzor', 'Kasbi',
    'Kitob', 'Koson', 'Mirishkor', 'Muborak',
    'Nishon', 'Qarshi', 'Shahrisabz', 'Yakkabog\'',
  ],
  'Samarqand viloyati': [
    'Bulung\'ur', 'Ishtixon', 'Jomboy', 'Kattaqo\'rg\'on',
    'Narpay', 'Nurobod', 'Oqdaryo', 'Pastdarg\'om',
    'Payariq', 'Samarqand', 'Tayloq', 'Urgut',
  ],
  'Sirdaryo viloyati': [
    'Boyovut', 'Guliston', 'Xovos', 'Mirzaobod',
    'Oqoltin', 'Sardoba', 'Sayxunobod', 'Sirdaryo',
  ],
  'Surxondaryo viloyati': [
    'Angor', 'Bandixon', 'Boysun', 'Denov',
    'Jarqo\'rg\'on', 'Muzrabod', 'Oltinsoy', 'Qiziriq',
    'Qumqo\'rg\'on', 'Sariosiyo', 'Sherobod', 'Sho\'rchi',
    'Termiz', 'Uzun',
  ],
  'Qoraqalpog\'iston Respublikasi': [
    'Amudaryo', 'Beruniy', 'Chimboy', 'Ellikqal\'a',
    'Kegeyli', 'Mo\'ynoq', 'Nukus', 'Qanliko\'l',
    'Qo\'ng\'irot', 'Shumanay', 'Taxtako\'pir', 'To\'rtko\'l',
    'Xo\'jayli',
  ],
};

/// Get sorted list of region names
List<String> get regionNames => uzbekistanRegions.keys.toList()..sort();

/// Get districts for a region
List<String> getDistricts(String region) =>
    uzbekistanRegions[region] ?? [];

/// Match a Nominatim state name to our region list
/// Nominatim may return "Jizzax viloyati", "Jizzakh Region", "Toshkent Shahri", etc.
String? matchRegion(String? nominatimState) {
  if (nominatimState == null || nominatimState.isEmpty) return null;
  final q = nominatimState.toLowerCase();

  for (final region in uzbekistanRegions.keys) {
    final r = region.toLowerCase();
    // Direct match
    if (r == q) return region;
    // Check if region name starts with same root
    final regionRoot = r.split(' ').first;
    if (q.contains(regionRoot) || regionRoot.contains(q.split(' ').first)) {
      return region;
    }
  }

  // Fallback: common transliteration mappings
  const aliases = {
    'jizzakh': 'Jizzax viloyati',
    'jizzax': 'Jizzax viloyati',
    'tashkent': 'Toshkent shahri',
    'toshkent': 'Toshkent shahri',
    'samarkand': 'Samarqand viloyati',
    'samarqand': 'Samarqand viloyati',
    'bukhara': 'Buxoro viloyati',
    'buxoro': 'Buxoro viloyati',
    'fergana': 'Farg\'ona viloyati',
    'namangan': 'Namangan viloyati',
    'andijan': 'Andijon viloyati',
    'andijon': 'Andijon viloyati',
    'navoi': 'Navoiy viloyati',
    'navoiy': 'Navoiy viloyati',
    'kashkadarya': 'Qashqadaryo viloyati',
    'qashqadaryo': 'Qashqadaryo viloyati',
    'surkhandarya': 'Surxondaryo viloyati',
    'surxondaryo': 'Surxondaryo viloyati',
    'syrdarya': 'Sirdaryo viloyati',
    'sirdaryo': 'Sirdaryo viloyati',
    'khorezm': 'Xorazm viloyati',
    'xorazm': 'Xorazm viloyati',
    'karakalpakstan': 'Qoraqalpog\'iston Respublikasi',
  };

  for (final entry in aliases.entries) {
    if (q.contains(entry.key)) return entry.value;
  }

  return null;
}

/// Match a Nominatim county/city to a district in the given region
String? matchDistrict(String? nominatimCounty, String region) {
  if (nominatimCounty == null || nominatimCounty.isEmpty) return null;
  final q = nominatimCounty.toLowerCase();
  final districts = getDistricts(region);

  for (final district in districts) {
    final d = district.toLowerCase();
    if (d == q) return district;
    // Partial match on first word
    final dRoot = d.split(' ').first;
    final qRoot = q.split(' ').first;
    if (dRoot == qRoot || d.contains(qRoot) || q.contains(dRoot)) {
      return district;
    }
  }
  return null;
}
