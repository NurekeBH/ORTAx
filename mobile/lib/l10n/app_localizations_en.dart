// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'AljabrA Labs';

  @override
  String get splashTagline =>
      'Bridging the past and the future through knowledge';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Get Started';

  @override
  String get onboardingArTitle => 'AR characters';

  @override
  String get onboardingArSubtitle =>
      'Historical figures come alive from the journal pages';

  @override
  String get onboardingJournalTitle => 'Science journal';

  @override
  String get onboardingJournalSubtitle => 'Engaging, clear — made for students';

  @override
  String get onboardingAvatarTitle => 'AI conversations';

  @override
  String get onboardingAvatarSubtitle =>
      'Ask questions directly to historical figures';

  @override
  String get loginWelcome => 'Welcome';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get loginPhone => 'Phone number';

  @override
  String get loginPassword => 'Password';

  @override
  String get loginButton => 'Sign in';

  @override
  String get loginForgot => 'Forgot password?';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginRegister => 'Sign up';

  @override
  String get registerTitle => 'Sign up';

  @override
  String get registerSendOtp => 'Send SMS code';

  @override
  String get registerVerify => 'Verify';

  @override
  String get registerHaveAccount => 'Already have an account?';

  @override
  String get registerSignIn => 'Sign in';

  @override
  String get registerOtpLabel => 'SMS code';

  @override
  String get homeGreeting => 'Hello!';

  @override
  String get homeSubtitle => 'What shall we explore today?';

  @override
  String get homeSearch => 'Search';

  @override
  String get homeJournalsSection => 'Journals';

  @override
  String get homeContinueLabel => 'Continue learning';

  @override
  String get homeHeroTitle => 'Chat with Al-Khwarizmi';

  @override
  String get homeHeroSubtitle =>
      'Ask anything about science and numbers — get an answer in the scholar\'s voice.';

  @override
  String get homeHeroCta => 'Open chat';

  @override
  String get homeCategoriesTitle => 'Pick a topic';

  @override
  String get homePopularTitle => 'Popular this week';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get categoryAll => 'All';

  @override
  String get categoryScience => 'Science';

  @override
  String get categoryNature => 'Nature';

  @override
  String get categorySpace => 'Space';

  @override
  String get categoryHistory => 'History';

  @override
  String get categoryLiterature => 'Literature';

  @override
  String get journalAbout => 'About';

  @override
  String get journalExcerpt => 'Excerpt';

  @override
  String get journalGallery => 'Pages';

  @override
  String get journalBuy => 'Buy';

  @override
  String get journalAr => 'Open AR';

  @override
  String get journalArHint => 'Point your camera at a journal page';

  @override
  String journalPrice(String price) {
    return '$price ₸';
  }

  @override
  String journalPageNumber(int number) {
    return 'Page $number';
  }

  @override
  String get journalBuyToast => 'Purchase will be available soon';

  @override
  String get tabHome => 'Home';

  @override
  String get tabJournals => 'Journals';

  @override
  String get tabAvatar => 'Al-Khwarizmi';

  @override
  String get tabMessages => 'Messages';

  @override
  String get tabProfile => 'Profile';

  @override
  String get journalsTitle => 'Journals';

  @override
  String get avatarTitle => 'Al-Khwarizmi';

  @override
  String get avatarSubtitle => 'Father of algebra — ask me anything';

  @override
  String get avatarHint => 'Ask Al-Khwarizmi…';

  @override
  String get avatarSend => 'Send';

  @override
  String get avatarEmpty => 'Start the conversation — type your question below';

  @override
  String get avatarError => 'Couldn\'t reach the avatar. Try again.';

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesEmpty => 'No notifications yet';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileFont => 'Font';

  @override
  String get profileFontPreview => 'AljabrA — bridge of knowledge';

  @override
  String get profileTextSize => 'Text size';

  @override
  String get profileTextSizePreview => 'Aa';

  @override
  String get profileTheme => 'Theme';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageKk => 'Қазақша';

  @override
  String get profileLanguageRu => 'Русский';

  @override
  String get profileLanguageEn => 'English';

  @override
  String get profileLogout => 'Sign out';

  @override
  String get profileVersion => 'Version';
}
