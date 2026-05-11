import '../models/journal.dart';

const mockJournals = <Journal>[
  Journal(
    id: 'yassawi',
    title: 'Қожа Ахмет Яссауи',
    description: 'Сопылық тариқаттың негізін қалаушы — Түркістан ұлы тұлғасы туралы.',
    subject: 'Тарих',
    gradeLevel: '6–7 сынып',
    coverAssetPath: 'assets/journal/journal1.png',
    pages: [
      JournalPage(number: 1, imageAssetPath: 'assets/journal/png/1.png', arMarkerId: 'yassawi-marker-1'),
      JournalPage(number: 2, imageAssetPath: 'assets/journal/png/2.png'),
      JournalPage(number: 3, imageAssetPath: 'assets/journal/png/3.png', arMarkerId: 'yassawi-marker-2'),
      JournalPage(number: 4, imageAssetPath: 'assets/journal/png/4.png'),
    ],
  ),
  Journal(
    id: 'farabi',
    title: 'Әл-Фараби',
    description: 'Екінші ұстаз — философия, музыка және ғылым әлемінің ұлы тұлғасы.',
    subject: 'Философия',
    gradeLevel: '10–11 сынып',
    coverAssetPath: 'assets/journal/journal2.png',
    pages: [
      JournalPage(number: 1, imageAssetPath: 'assets/journal/png/5.png'),
      JournalPage(number: 2, imageAssetPath: 'assets/journal/png/6.png', arMarkerId: 'farabi-marker-1'),
    ],
  ),
  Journal(
    id: 'abai',
    title: 'Абай Құнанбайұлы',
    description: 'Қара сөздердің авторы — қазақ әдебиетінің классигі.',
    subject: 'Әдебиет',
    gradeLevel: '8–10 сынып',
    coverAssetPath: 'assets/journal/journal3.png',
    pages: [
      JournalPage(number: 1, imageAssetPath: 'assets/journal/png/7.png'),
      JournalPage(number: 2, imageAssetPath: 'assets/journal/png/8.png', arMarkerId: 'abai-marker-1'),
    ],
  ),
  Journal(
    id: 'shoqan',
    title: 'Шоқан Уәлиханов',
    description: 'Ұлы географ, этнограф және саяхатшы.',
    subject: 'География',
    gradeLevel: '7–9 сынып',
    coverAssetPath: 'assets/journal/journal4.png',
    pages: [
      JournalPage(number: 1, imageAssetPath: 'assets/journal/png/9.png'),
      JournalPage(number: 2, imageAssetPath: 'assets/journal/png/10.png', arMarkerId: 'shoqan-marker-1'),
    ],
  ),
];
