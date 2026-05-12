// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'AljabrA Labs';

  @override
  String get splashTagline => 'Знания — мост из прошлого в будущее';

  @override
  String get onboardingSkip => 'Пропустить';

  @override
  String get onboardingNext => 'Далее';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get onboardingArTitle => 'AR-персонажи';

  @override
  String get onboardingArSubtitle =>
      'Исторические фигуры оживают со страниц журнала';

  @override
  String get onboardingJournalTitle => 'Научный журнал';

  @override
  String get onboardingJournalSubtitle =>
      'Интересно и понятно — создано для школьников';

  @override
  String get onboardingAvatarTitle => 'AI-беседа';

  @override
  String get onboardingAvatarSubtitle =>
      'Задайте вопрос исторической личности и получите ответ';

  @override
  String get loginWelcome => 'Добро пожаловать';

  @override
  String get loginSubtitle => 'Войдите, чтобы продолжить';

  @override
  String get loginPhone => 'Номер телефона';

  @override
  String get loginPassword => 'Пароль';

  @override
  String get loginButton => 'Войти';

  @override
  String get loginForgot => 'Забыли пароль?';

  @override
  String get loginNoAccount => 'Нет аккаунта?';

  @override
  String get loginRegister => 'Регистрация';

  @override
  String get registerTitle => 'Регистрация';

  @override
  String get registerSendOtp => 'Отправить SMS-код';

  @override
  String get registerVerify => 'Подтвердить';

  @override
  String get registerHaveAccount => 'Уже есть аккаунт?';

  @override
  String get registerSignIn => 'Войти';

  @override
  String get registerOtpLabel => 'SMS-код';

  @override
  String get homeGreeting => 'Привет!';

  @override
  String get homeSubtitle => 'Что изучим сегодня?';

  @override
  String get homeSearch => 'Поиск';

  @override
  String get homeJournalsSection => 'Журналы';

  @override
  String get homeContinueLabel => 'Продолжить обучение';

  @override
  String get homeHeroTitle => 'Поговори с Аль-Хорезми';

  @override
  String get homeHeroSubtitle =>
      'Задай вопрос о науке и числах — получишь ответ голосом учёного.';

  @override
  String get homeHeroCta => 'Открыть чат';

  @override
  String get homeCategoriesTitle => 'Выбор темы';

  @override
  String get homePopularTitle => 'Популярное на этой неделе';

  @override
  String get homeSeeAll => 'Все';

  @override
  String get categoryAll => 'Все';

  @override
  String get categoryScience => 'Наука';

  @override
  String get categoryNature => 'Природа';

  @override
  String get categorySpace => 'Космос';

  @override
  String get categoryHistory => 'История';

  @override
  String get categoryLiterature => 'Литература';

  @override
  String get journalAbout => 'О журнале';

  @override
  String get journalExcerpt => 'Отрывок';

  @override
  String get journalGallery => 'Страницы журнала';

  @override
  String get journalBuy => 'Купить';

  @override
  String get journalAr => 'Открыть AR';

  @override
  String get journalArHint => 'Наведите камеру на страницу журнала';

  @override
  String journalPrice(String price) {
    return '$price ₸';
  }

  @override
  String journalPageNumber(int number) {
    return 'Стр. $number';
  }

  @override
  String get journalBuyToast => 'Покупка появится в ближайшее время';

  @override
  String get tabHome => 'Главная';

  @override
  String get tabJournals => 'Журналы';

  @override
  String get tabAvatar => 'Аль-Хорезми';

  @override
  String get tabMessages => 'Сообщения';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get journalsTitle => 'Журналы';

  @override
  String get avatarTitle => 'Аль-Хорезми';

  @override
  String get avatarSubtitle => 'Отец алгебры — задайте вопрос';

  @override
  String get avatarModeVideo => 'Видео';

  @override
  String get avatarModeVideoSubtitle => 'Живой видео-аватар';

  @override
  String get avatarModeChat => 'Чат';

  @override
  String get avatarModeChatSubtitle => 'Текст и голос';

  @override
  String get avatarHint => 'Спросите Аль-Хорезми…';

  @override
  String get avatarSend => 'Отправить';

  @override
  String get avatarEmpty => 'Начните беседу — напишите вопрос ниже';

  @override
  String get avatarError =>
      'Не удалось связаться с аватаром. Попробуйте снова.';

  @override
  String get messagesTitle => 'Сообщения';

  @override
  String get messagesEmpty => 'Пока нет уведомлений';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get profileFont => 'Шрифт';

  @override
  String get profileFontPreview => 'AljabrA — мост знаний';

  @override
  String get profileTextSize => 'Размер текста';

  @override
  String get profileTextSizePreview => 'Аа';

  @override
  String get profileTheme => 'Тема';

  @override
  String get profileThemeSystem => 'Системная';

  @override
  String get profileThemeLight => 'Светлая';

  @override
  String get profileThemeDark => 'Тёмная';

  @override
  String get profileLanguage => 'Язык';

  @override
  String get profileLanguageKk => 'Қазақша';

  @override
  String get profileLanguageRu => 'Русский';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get profileLogout => 'Выйти';

  @override
  String get profileVersion => 'Версия';
}
