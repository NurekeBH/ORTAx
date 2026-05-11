import '../models/journal.dart';

const mockJournals = <Journal>[
  Journal(
    id: 'khwarizmi',
    title: 'Әл-Хорезми',
    description:
        'Алгебраның атасы, IX ғасырдағы ұлы математик, астроном әрі географ. '
        '"Әл-джабр" еңбегі арқылы заманауи алгебраның негізін қалаған.',
    subject: 'Ғылым',
    gradeLevel: '7–11 сынып',
    coverAssetPath: 'assets/journal/journal1.png',
    priceTenge: 1990,
    excerpt:
        '«Сандарды бір-бірімен теңестіру — әділдіктің көрінісі. Бір жағындағы белгісіз шаманы '
        'екінші жаққа аударған кезде ғана біз дүниенің тепе-теңдігін көреміз. Міне, әл-джабрдың '
        'мәні осы — таразыны теңгеру өнері.»\n\n— "Әл-китаб әл-мухтасар фи хисаб әл-джабр уа әл-мукабала"',
    pages: [
      JournalPage(number: 1, imageAssetPath: 'assets/journal/png/1.png', arMarkerId: 'khwarizmi-marker-1'),
      JournalPage(number: 2, imageAssetPath: 'assets/journal/png/2.png'),
      JournalPage(number: 3, imageAssetPath: 'assets/journal/png/3.png', arMarkerId: 'khwarizmi-marker-2'),
      JournalPage(number: 4, imageAssetPath: 'assets/journal/png/4.png'),
    ],
  ),
  Journal(
    id: 'farabi',
    title: 'Әбу Насыр әл-Фараби',
    description:
        '"Екінші ұстаз" атанған ұлы ғалым. Философия, музыка, математика '
        'және ғылым әлеміндегі еңбектері әлемге танылды.',
    subject: 'Ғылым',
    gradeLevel: '10–11 сынып',
    coverAssetPath: 'assets/journal/journal2.png',
    priceTenge: 1990,
    excerpt:
        '«Адам — өзін танып, дүниені танығанда ғана бақытқа жетеді. Қаланың игілігі — оның '
        'тұрғындарының бір-біріне жасаған жақсылығынан тұрады. Ал білім — бұл жақсылықтың алғашқы '
        'қадамы.»\n\n— "Қайырымды қала тұрғындарының көзқарасы"',
    pages: [
      JournalPage(number: 1, imageAssetPath: 'assets/journal/png/5.png'),
      JournalPage(number: 2, imageAssetPath: 'assets/journal/png/6.png', arMarkerId: 'farabi-marker-1'),
    ],
  ),
  Journal(
    id: 'abai',
    title: 'Абай Құнанбайұлы',
    description:
        'Қазақ әдебиетінің классигі, ағартушы, ойшыл. "Қара сөздер" мен '
        'өлеңдері арқылы халыққа имандылық пен білім жолын насихаттады.',
    subject: 'Әдебиет',
    gradeLevel: '8–10 сынып',
    coverAssetPath: 'assets/journal/journal3.png',
    priceTenge: 1990,
    excerpt:
        '«Адамзаттың бәрін сүй, бауырым деп. Әділдік үшін, шындық үшін болсын. Малыңды сақтамасаң, '
        'сатылып кетесің. Білімді болмасаң, сорлы боласың. Ал білім — бұл өзіңмен өзің күресу.»\n\n— "Қара сөздер", 17-сөз',
    pages: [
      JournalPage(number: 1, imageAssetPath: 'assets/journal/png/7.png'),
      JournalPage(number: 2, imageAssetPath: 'assets/journal/png/8.png', arMarkerId: 'abai-marker-1'),
    ],
  ),
  Journal(
    id: 'shoqan',
    title: 'Шоқан Уәлиханов',
    description:
        'Ұлы географ, этнограф, саяхатшы. Жетісу, Қашғар, Қырғыз даласы '
        'бойынша еңбектері — табиғатпен, халықпен танысудың үлгісі.',
    subject: 'Табиғат',
    gradeLevel: '7–9 сынып',
    coverAssetPath: 'assets/journal/journal4.png',
    priceTenge: 1990,
    excerpt:
        '«Қашғар қаласы — Шығыс пен Батыстың тоғысқан жері. Жолда көрген әрбір таулар, шөл, '
        'өзен — өзінің тарихын айтады. Халықтың әні мен әпсаналары — олардың жанының айнасы.»\n\n— "Қашғар жорығының күнделігі"',
    pages: [
      JournalPage(number: 1, imageAssetPath: 'assets/journal/png/9.png'),
      JournalPage(number: 2, imageAssetPath: 'assets/journal/png/10.png', arMarkerId: 'shoqan-marker-1'),
    ],
  ),
];

const journalCategories = <String>[
  'Барлығы',
  'Ғылым',
  'Табиғат',
  'Ғарыш',
  'Әдебиет',
];
