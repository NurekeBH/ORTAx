import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_kk.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('kk'),
    Locale('ru'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'AljabrA Labs'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Bridging the past and the future through knowledge'**
  String get splashTagline;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingStart;

  /// No description provided for @onboardingArTitle.
  ///
  /// In en, this message translates to:
  /// **'AR characters'**
  String get onboardingArTitle;

  /// No description provided for @onboardingArSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Historical figures come alive from the journal pages'**
  String get onboardingArSubtitle;

  /// No description provided for @onboardingJournalTitle.
  ///
  /// In en, this message translates to:
  /// **'Science journal'**
  String get onboardingJournalTitle;

  /// No description provided for @onboardingJournalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Engaging, clear — made for students'**
  String get onboardingJournalSubtitle;

  /// No description provided for @onboardingAvatarTitle.
  ///
  /// In en, this message translates to:
  /// **'AI conversations'**
  String get onboardingAvatarTitle;

  /// No description provided for @onboardingAvatarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask questions directly to historical figures'**
  String get onboardingAvatarSubtitle;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginWelcome;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get loginSubtitle;

  /// No description provided for @loginPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get loginPhone;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// No description provided for @loginForgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgot;

  /// No description provided for @loginNoAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get loginNoAccount;

  /// No description provided for @loginRegister.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginRegister;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerTitle;

  /// No description provided for @registerSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send SMS code'**
  String get registerSendOtp;

  /// No description provided for @registerVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get registerVerify;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get registerHaveAccount;

  /// No description provided for @registerSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get registerSignIn;

  /// No description provided for @registerOtpLabel.
  ///
  /// In en, this message translates to:
  /// **'SMS code'**
  String get registerOtpLabel;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get homeGreeting;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What shall we explore today?'**
  String get homeSubtitle;

  /// No description provided for @homeSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get homeSearch;

  /// No description provided for @homeJournalsSection.
  ///
  /// In en, this message translates to:
  /// **'Journals'**
  String get homeJournalsSection;

  /// No description provided for @homeContinueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue learning'**
  String get homeContinueLabel;

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat with Al-Khwarizmi'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about science and numbers — get an answer in the scholar\'s voice.'**
  String get homeHeroSubtitle;

  /// No description provided for @homeHeroCta.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get homeHeroCta;

  /// No description provided for @homeCategoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a topic'**
  String get homeCategoriesTitle;

  /// No description provided for @homePopularTitle.
  ///
  /// In en, this message translates to:
  /// **'Popular this week'**
  String get homePopularTitle;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @categoryAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get categoryAll;

  /// No description provided for @categoryScience.
  ///
  /// In en, this message translates to:
  /// **'Science'**
  String get categoryScience;

  /// No description provided for @categoryNature.
  ///
  /// In en, this message translates to:
  /// **'Nature'**
  String get categoryNature;

  /// No description provided for @categorySpace.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get categorySpace;

  /// No description provided for @categoryHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get categoryHistory;

  /// No description provided for @categoryLiterature.
  ///
  /// In en, this message translates to:
  /// **'Literature'**
  String get categoryLiterature;

  /// No description provided for @journalAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get journalAbout;

  /// No description provided for @journalExcerpt.
  ///
  /// In en, this message translates to:
  /// **'Excerpt'**
  String get journalExcerpt;

  /// No description provided for @journalGallery.
  ///
  /// In en, this message translates to:
  /// **'Pages'**
  String get journalGallery;

  /// No description provided for @journalBuy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get journalBuy;

  /// No description provided for @journalAr.
  ///
  /// In en, this message translates to:
  /// **'Open AR'**
  String get journalAr;

  /// No description provided for @journalArHint.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a journal page'**
  String get journalArHint;

  /// No description provided for @journalPrice.
  ///
  /// In en, this message translates to:
  /// **'{price} ₸'**
  String journalPrice(String price);

  /// No description provided for @journalPageNumber.
  ///
  /// In en, this message translates to:
  /// **'Page {number}'**
  String journalPageNumber(int number);

  /// No description provided for @journalBuyToast.
  ///
  /// In en, this message translates to:
  /// **'Purchase will be available soon'**
  String get journalBuyToast;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabJournals.
  ///
  /// In en, this message translates to:
  /// **'Journals'**
  String get tabJournals;

  /// No description provided for @tabAvatar.
  ///
  /// In en, this message translates to:
  /// **'Al-Khwarizmi'**
  String get tabAvatar;

  /// No description provided for @tabMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get tabMessages;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @journalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Journals'**
  String get journalsTitle;

  /// No description provided for @avatarTitle.
  ///
  /// In en, this message translates to:
  /// **'Al-Khwarizmi'**
  String get avatarTitle;

  /// No description provided for @avatarSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Father of algebra — ask me anything'**
  String get avatarSubtitle;

  /// No description provided for @avatarModeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get avatarModeVideo;

  /// No description provided for @avatarModeVideoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Talk to the live avatar'**
  String get avatarModeVideoSubtitle;

  /// No description provided for @avatarModeChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get avatarModeChat;

  /// No description provided for @avatarModeChatSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Text and voice'**
  String get avatarModeChatSubtitle;

  /// No description provided for @avatarHint.
  ///
  /// In en, this message translates to:
  /// **'Ask Al-Khwarizmi…'**
  String get avatarHint;

  /// No description provided for @avatarSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get avatarSend;

  /// No description provided for @avatarEmpty.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation — type your question below'**
  String get avatarEmpty;

  /// No description provided for @avatarError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the avatar. Try again.'**
  String get avatarError;

  /// No description provided for @messagesTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messagesTitle;

  /// No description provided for @messagesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get messagesEmpty;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileFont.
  ///
  /// In en, this message translates to:
  /// **'Font'**
  String get profileFont;

  /// No description provided for @profileFontPreview.
  ///
  /// In en, this message translates to:
  /// **'AljabrA — bridge of knowledge'**
  String get profileFontPreview;

  /// No description provided for @profileTextSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get profileTextSize;

  /// No description provided for @profileTextSizePreview.
  ///
  /// In en, this message translates to:
  /// **'Aa'**
  String get profileTextSizePreview;

  /// No description provided for @profileTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profileTheme;

  /// No description provided for @profileThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get profileThemeSystem;

  /// No description provided for @profileThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get profileThemeLight;

  /// No description provided for @profileThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get profileThemeDark;

  /// No description provided for @profileLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profileLanguage;

  /// No description provided for @profileLanguageKk.
  ///
  /// In en, this message translates to:
  /// **'Қазақша'**
  String get profileLanguageKk;

  /// No description provided for @profileLanguageRu.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get profileLanguageRu;

  /// No description provided for @profileLanguageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get profileLanguageEn;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileLogout;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get profileVersion;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'kk', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'kk':
      return AppLocalizationsKk();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
