import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/element_model.dart';

// ---------------------------------------------------------------------------
// TEXT: languages, fonts
// ---------------------------------------------------------------------------

/// language -> (main font, sample text, quick phrases)
const langs = <String, (String, String, List<String>)>{
  'English': ('Anton', 'YOUR TEXT', ['WATCH NOW', 'NEW VIDEO', 'MUST WATCH', 'SHOCKING!', 'SUBSCRIBE']),
  'اردو': ('Noto Nastaliq Urdu', 'آپ کا متن', ['ابھی دیکھیں', 'نیا ویڈیو', 'ضرور دیکھیں', 'چونکا دینے والا', 'سبسکرائب کریں']),
  'हिन्दी': ('Yatra One', 'आपका टेक्स्ट', ['अभी देखें', 'नया वीडियो', 'ज़रूर देखें', 'चौंकाने वाला', 'सब्सक्राइब करें']),
  'العربية': ('Noto Sans Arabic', 'نصك هنا', ['شاهد الآن', 'فيديو جديد', 'لا تفوّت', 'صادم', 'اشترك الآن']),
  'বাংলা': ('Noto Sans Bengali', 'আপনার লেখা', ['এখনই দেখুন', 'নতুন ভিডিও', 'অবশ্যই দেখুন', 'চমকপ্রদ', 'সাবস্ক্রাইব করুন']),
};

const englishFonts = <String>[
  'Anton', 'Bebas Neue', 'Oswald', 'Poppins', 'Montserrat', 'Bangers', 'Luckiest Guy', 'Black Ops One',
  'Righteous', 'Russo One', 'Archivo Black', 'Permanent Marker', 'Lobster', 'Pacifico', 'Playfair Display', 'Fredoka',
];

const urduFonts = <String>[
  'Noto Nastaliq Urdu', 'Gulzar', 'Lateef', 'Amiri', 'Noto Naskh Arabic', 'Aref Ruqaa',
  'Cairo', 'Changa', 'Lalezar', 'Rakkas', 'Mirza', 'Reem Kufi',
];

/// Fonts offered for each language in the Text tab.
const fontsByLang = <String, List<String>>{
  'English': englishFonts,
  'اردو': urduFonts,
  'हिन्दी': ['Yatra One'],
  'العربية': ['Noto Sans Arabic', 'Cairo', 'Amiri'],
  'বাংলা': ['Noto Sans Bengali'],
};

/// Every font the app knows (kept so old saved designs and the font picker agree).
final allFonts = <String>{
  ...englishFonts,
  ...urduFonts,
  'Yatra One',
  'Noto Sans Arabic',
  'Noto Sans Bengali',
  'Noto Sans SC',
  'Noto Sans JP',
  'Noto Sans KR',
};

/// Font sizes offered when adding text and in the size sheet.
const fontSizePresets = <int>[24, 32, 40, 48, 64, 80, 100, 130, 160, 200, 260];

// ---------------------------------------------------------------------------
// ICONS (grouped). Stored by key so saved designs survive app updates.
// ---------------------------------------------------------------------------

const iconGroups = <String, Map<String, IconData>>{
  'YouTube': {
    'thumb_up': Icons.thumb_up, 'thumb_down': Icons.thumb_down, 'favorite': Icons.favorite, 'share': Icons.share,
    'notifications': Icons.notifications, 'notifications_active': Icons.notifications_active,
    'play_circle': Icons.play_circle, 'play_arrow': Icons.play_arrow, 'visibility': Icons.visibility,
    'chat_bubble': Icons.chat_bubble, 'comment': Icons.comment, 'subscriptions': Icons.subscriptions,
    'ondemand_video': Icons.ondemand_video, 'video_library': Icons.video_library, 'smart_display': Icons.smart_display,
    'live_tv': Icons.live_tv, 'videocam': Icons.videocam, 'podcast': Icons.podcasts, 'mic': Icons.mic,
    'headphones': Icons.headphones, 'music_note': Icons.music_note, 'photo_camera': Icons.photo_camera,
    'movie': Icons.movie, 'new': Icons.new_releases, 'verified': Icons.verified, 'bookmark': Icons.bookmark,
    'send': Icons.send, 'search': Icons.search, 'campaign': Icons.campaign, 'news': Icons.newspaper,
  },
  'Arrows': {
    'arrow_forward': Icons.arrow_forward, 'arrow_back': Icons.arrow_back, 'arrow_upward': Icons.arrow_upward,
    'arrow_downward': Icons.arrow_downward, 'north_east': Icons.north_east, 'north_west': Icons.north_west,
    'south_east': Icons.south_east, 'south_west': Icons.south_west, 'double_arrow': Icons.double_arrow,
    'trending_up': Icons.trending_up, 'trending_down': Icons.trending_down, 'redo': Icons.redo, 'undo': Icons.undo,
    'refresh': Icons.refresh, 'swap_horiz': Icons.swap_horiz, 'swap_vert': Icons.swap_vert,
    'fast_forward': Icons.fast_forward, 'fast_rewind': Icons.fast_rewind, 'skip_next': Icons.skip_next,
    'skip_previous': Icons.skip_previous, 'expand_more': Icons.expand_more, 'expand_less': Icons.expand_less,
    'chevron_right': Icons.chevron_right, 'chevron_left': Icons.chevron_left, 'call_made': Icons.call_made,
    'call_received': Icons.call_received, 'turn_right': Icons.turn_right, 'turn_left': Icons.turn_left,
    'subdirectory_arrow_right': Icons.subdirectory_arrow_right, 'keyboard_double_arrow_right': Icons.keyboard_double_arrow_right,
    'keyboard_double_arrow_down': Icons.keyboard_double_arrow_down,
  },
  'Alerts': {
    'help': Icons.help, 'priority_high': Icons.priority_high, 'error': Icons.error, 'warning': Icons.warning,
    'info': Icons.info, 'check_circle': Icons.check_circle, 'cancel': Icons.cancel, 'block': Icons.block,
    'report': Icons.report, 'check': Icons.check, 'close': Icons.close, 'add': Icons.add, 'remove': Icons.remove,
    'add_circle': Icons.add_circle, 'remove_circle': Icons.remove_circle, 'lightbulb': Icons.lightbulb,
    'bolt': Icons.bolt, 'flash_on': Icons.flash_on, 'fire': Icons.local_fire_department, 'whatshot': Icons.whatshot,
    'star': Icons.star, 'star_half': Icons.star_half, 'grade': Icons.grade, 'auto_awesome': Icons.auto_awesome,
    'diamond': Icons.diamond, 'workspace_premium': Icons.workspace_premium, 'military_tech': Icons.military_tech,
    'emoji_events': Icons.emoji_events, 'flag': Icons.flag, 'lock': Icons.lock, 'lock_open': Icons.lock_open,
    'key': Icons.key, 'shield': Icons.shield, 'visibility_off': Icons.visibility_off, 'do_not_disturb': Icons.do_not_disturb_on,
  },
  'Faces': {
    'emoji_emotions': Icons.emoji_emotions, 'sentiment_very_satisfied': Icons.sentiment_very_satisfied,
    'sentiment_satisfied': Icons.sentiment_satisfied, 'sentiment_neutral': Icons.sentiment_neutral,
    'sentiment_dissatisfied': Icons.sentiment_dissatisfied, 'sentiment_very_dissatisfied': Icons.sentiment_very_dissatisfied,
    'mood': Icons.mood, 'mood_bad': Icons.mood_bad, 'face': Icons.face, 'psychology': Icons.psychology,
    'favorite_border': Icons.favorite_border, 'heart_broken': Icons.heart_broken, 'celebration': Icons.celebration,
    'cake': Icons.cake, 'volunteer_activism': Icons.volunteer_activism, 'pan_tool': Icons.pan_tool,
    'thumbs_up_down': Icons.thumbs_up_down, 'waving_hand': Icons.waving_hand, 'back_hand': Icons.back_hand,
    'sports_kabaddi': Icons.sports_kabaddi, 'person': Icons.person, 'people': Icons.people, 'groups': Icons.groups,
    'record_voice_over': Icons.record_voice_over, 'self_improvement': Icons.self_improvement,
  },
  'Gaming & Tech': {
    'games': Icons.sports_esports, 'videogame_asset': Icons.videogame_asset, 'gamepad': Icons.gamepad,
    'rocket': Icons.rocket_launch, 'memory': Icons.memory, 'computer': Icons.computer, 'laptop': Icons.laptop,
    'phone': Icons.smartphone, 'tablet': Icons.tablet, 'watch': Icons.watch, 'keyboard': Icons.keyboard,
    'mouse': Icons.mouse, 'headset': Icons.headset_mic, 'router': Icons.router, 'wifi': Icons.wifi,
    'bluetooth': Icons.bluetooth, 'cloud': Icons.cloud, 'storage': Icons.storage, 'code': Icons.code,
    'terminal': Icons.terminal, 'bug_report': Icons.bug_report, 'settings': Icons.settings, 'build': Icons.build,
    'satellite': Icons.satellite_alt, 'smart_toy': Icons.smart_toy, 'android': Icons.android, 'usb': Icons.usb,
    'battery_full': Icons.battery_full, 'power': Icons.power_settings_new, 'extension': Icons.extension,
    'casino': Icons.casino, 'toys': Icons.toys,
  },
  'Money': {
    'attach_money': Icons.attach_money, 'monetization_on': Icons.monetization_on, 'paid': Icons.paid,
    'savings': Icons.savings, 'account_balance': Icons.account_balance, 'credit_card': Icons.credit_card,
    'shopping_cart': Icons.shopping_cart, 'shopping_bag': Icons.shopping_bag, 'sell': Icons.sell,
    'local_offer': Icons.local_offer, 'percent': Icons.percent, 'bitcoin': Icons.currency_bitcoin,
    'bar_chart': Icons.bar_chart, 'pie_chart': Icons.pie_chart, 'leaderboard': Icons.leaderboard,
    'show_chart': Icons.show_chart, 'price_check': Icons.price_check, 'receipt': Icons.receipt_long,
    'store': Icons.store, 'work': Icons.work, 'business': Icons.business_center,
  },
  'Food': {
    'restaurant': Icons.restaurant, 'fastfood': Icons.fastfood, 'pizza': Icons.local_pizza,
    'burger': Icons.lunch_dining, 'cafe': Icons.local_cafe, 'icecream': Icons.icecream, 'bakery': Icons.bakery_dining,
    'ramen': Icons.ramen_dining, 'bar': Icons.local_bar, 'set_meal': Icons.set_meal, 'dinner': Icons.dinner_dining,
    'brunch': Icons.brunch_dining, 'cookie': Icons.cookie, 'kebab': Icons.kebab_dining, 'rice_bowl': Icons.rice_bowl,
    'tapas': Icons.tapas, 'tea': Icons.emoji_food_beverage, 'wine_bar': Icons.wine_bar, 'coffee': Icons.coffee,
    'kitchen': Icons.kitchen,
  },
  'Sports': {
    'fitness': Icons.fitness_center, 'soccer': Icons.sports_soccer, 'basketball': Icons.sports_basketball,
    'cricket': Icons.sports_cricket, 'tennis': Icons.sports_tennis, 'baseball': Icons.sports_baseball,
    'football': Icons.sports_football, 'martial_arts': Icons.sports_martial_arts, 'mma': Icons.sports_mma,
    'run': Icons.directions_run, 'bike': Icons.directions_bike, 'pool': Icons.pool, 'timer': Icons.timer,
    'hiking': Icons.hiking, 'golf': Icons.sports_golf, 'hockey': Icons.sports_hockey, 'rugby': Icons.sports_rugby,
    'volleyball': Icons.sports_volleyball, 'motorsports': Icons.sports_motorsports, 'sports_score': Icons.sports_score,
  },
  'Travel & Nature': {
    'flight': Icons.flight, 'car': Icons.directions_car, 'train': Icons.train, 'boat': Icons.directions_boat,
    'bike2': Icons.two_wheeler, 'hotel': Icons.hotel, 'beach': Icons.beach_access, 'terrain': Icons.terrain,
    'landscape': Icons.landscape, 'park': Icons.park, 'forest': Icons.forest, 'eco': Icons.eco,
    'sun': Icons.wb_sunny, 'night': Icons.nightlight, 'water_drop': Icons.water_drop, 'snow': Icons.ac_unit,
    'storm': Icons.thunderstorm, 'umbrella': Icons.umbrella, 'pets': Icons.pets, 'flower': Icons.local_florist,
    'grass': Icons.grass, 'public': Icons.public, 'place': Icons.place, 'map': Icons.map, 'explore': Icons.explore,
    'luggage': Icons.luggage, 'camping': Icons.holiday_village, 'home': Icons.home,
  },
  'Education': {
    'school': Icons.school, 'book': Icons.menu_book, 'stories': Icons.auto_stories, 'edit': Icons.edit,
    'brush': Icons.brush, 'palette': Icons.palette, 'science': Icons.science, 'biotech': Icons.biotech,
    'calculate': Icons.calculate, 'translate': Icons.translate, 'quiz': Icons.quiz, 'article': Icons.article,
    'event': Icons.event, 'schedule': Icons.schedule, 'alarm': Icons.alarm, 'hourglass': Icons.hourglass_bottom,
    'history': Icons.history, 'language': Icons.language, 'download': Icons.download, 'mosque': Icons.mosque,
  },
};

/// Flat lookup used by the canvas (key -> icon). Includes every key that older designs may use.
final Map<String, IconData> iconMap = {for (final g in iconGroups.values) ...g};

// ---------------------------------------------------------------------------
// YouTube buttons (a few elements grouped together)
// ---------------------------------------------------------------------------

final stickers = <String, List<El> Function()>{
  'Subscribe': () => [
        El(K.shape, x: 340, y: 290, w: 580, h: 130, radius: 26, color: Colors.red),
        El(K.icon, icon: 'notifications', x: 380, y: 318, size: 74, outline: false),
        El(K.text, text: 'SUBSCRIBE', font: 'Poppins', x: 470, y: 318, w: 430, size: 60, outline: false),
      ],
  'Like': () => [
        El(K.shape, x: 400, y: 290, w: 440, h: 130, radius: 65),
        El(K.icon, icon: 'thumb_up', x: 430, y: 318, size: 74, color: Colors.red, outline: false),
        El(K.text, text: 'LIKE', font: 'Poppins', x: 520, y: 318, w: 300, size: 60, color: Colors.black87, outline: false),
      ],
  'Share': () => [
        El(K.shape, x: 380, y: 290, w: 500, h: 130, radius: 65, color: kBlue),
        El(K.icon, icon: 'share', x: 415, y: 318, size: 74, outline: false),
        El(K.text, text: 'SHARE', font: 'Poppins', x: 505, y: 318, w: 360, size: 60, outline: false),
      ],
  'Bell': () => [
        El(K.shape, x: 470, y: 210, w: 300, h: 300, radius: 150, color: const Color(0xFFFFD200)),
        El(K.icon, icon: 'notifications', x: 520, y: 260, size: 200, color: Colors.black, outline: false),
      ],
  'Play': () => [
        El(K.shape, x: 430, y: 260, w: 420, h: 260, radius: 70, color: Colors.red),
        El(K.icon, icon: 'play_arrow', x: 520, y: 300, size: 180, outline: false),
      ],
};

// ---------------------------------------------------------------------------
// COLOURS
// ---------------------------------------------------------------------------

const swatches = <Color>[Colors.white, Colors.black, Colors.red, Color(0xFFFFE600), Colors.orange, Colors.green, Colors.cyan, kBlue, Colors.purple, Colors.pink];

/// Two-colour gradients for the Background tab.
const gradients = <List<Color>>[
  [Color(0xFFFF5F6D), Color(0xFFFFC371)], [Color(0xFF0F2027), Color(0xFF4AC29A)], [Color(0xFF7F00FF), Color(0xFFE100FF)],
  [Color(0xFF0F0C29), Color(0xFF302B63)], [Color(0xFFD4FC79), Color(0xFF96E6A1)], [Color(0xFFE52D27), Color(0xFF1A0000)],
  [Color(0xFF56CCF2), Color(0xFF2F80ED)], [Color(0xFFF7971E), Color(0xFFFFD200)], [Color(0xFF00F5D4), Color(0xFF7B2FF7)],
  [Color(0xFFFF512F), Color(0xFFDD2476)], [Color(0xFF11998E), Color(0xFF38EF7D)], [Color(0xFFFC466B), Color(0xFF3F5EFB)],
  [Color(0xFF141E30), Color(0xFF243B55)], [Color(0xFFFFE259), Color(0xFFFFA751)], [Color(0xFF00C6FF), Color(0xFF0072FF)],
  [Color(0xFFEE0979), Color(0xFFFF6A00)], [Color(0xFF200122), Color(0xFF6F0000)], [Color(0xFFB993D6), Color(0xFF8CA6DB)],
  [Color(0xFF000000), Color(0xFF434343)], [Color(0xFF1D976C), Color(0xFF93F9B9)], [Color(0xFFFFFFFF), Color(0xFFB0BEC5)],
  [Color(0xFFFDC830), Color(0xFFF37335)], [Color(0xFF8E2DE2), Color(0xFF4A00E0)], [Color(0xFFFF0844), Color(0xFFFFB199)],
];

// ---------------------------------------------------------------------------
// THEMED BACKGROUNDS: colours + a pattern drawn over them (see BgPatternPainter)
// ---------------------------------------------------------------------------

class BgTheme {
  final String theme, name;
  final List<Color> colors;
  final String? pattern;
  const BgTheme(this.theme, this.name, this.colors, [this.pattern]);
}

const bgThemes = <BgTheme>[
  // Gaming
  BgTheme('Gaming', 'Neon grid', [Color(0xFF0F0C29), Color(0xFF7B2FF7)], 'grid'),
  BgTheme('Gaming', 'Cyber', [Color(0xFF000000), Color(0xFF00695C)], 'grid'),
  BgTheme('Gaming', 'Battle rays', [Color(0xFFE52D27), Color(0xFF1A0000)], 'rays'),
  BgTheme('Gaming', 'Pixel dark', [Color(0xFF1B1B2F), Color(0xFF162447)], 'dots'),
  // Tech
  BgTheme('Tech', 'Circuit blue', [Color(0xFF0F2027), Color(0xFF2C5364)], 'grid'),
  BgTheme('Tech', 'Digital', [Color(0xFF141E30), Color(0xFF243B55)], 'dots'),
  BgTheme('Tech', 'Clean light', [Color(0xFFFFFFFF), Color(0xFFD7E3FC)], 'dots'),
  // Space
  BgTheme('Space', 'Night sky', [Color(0xFF020111), Color(0xFF191654)], 'stars'),
  BgTheme('Space', 'Galaxy', [Color(0xFF0F0C29), Color(0xFF302B63), Color(0xFF24243E)], 'stars'),
  BgTheme('Space', 'Nebula', [Color(0xFF2B0A3D), Color(0xFFC21E56)], 'stars'),
  // Nature
  BgTheme('Nature', 'Forest', [Color(0xFF0B3D20), Color(0xFF56AB2F)], 'leaves'),
  BgTheme('Nature', 'Ocean', [Color(0xFF00C6FF), Color(0xFF0072FF)], 'waves'),
  BgTheme('Nature', 'Meadow', [Color(0xFFD4FC79), Color(0xFF96E6A1)], 'clouds'),
  BgTheme('Nature', 'Sky', [Color(0xFF56CCF2), Color(0xFFE0F7FF)], 'clouds'),
  // Sunset & warm
  BgTheme('Sunset', 'Sunset', [Color(0xFFFF5F6D), Color(0xFFFFC371)], 'rays'),
  BgTheme('Sunset', 'Golden hour', [Color(0xFFFDC830), Color(0xFFF37335)], 'rays'),
  BgTheme('Sunset', 'Dusk', [Color(0xFF3A1C71), Color(0xFFD76D77), Color(0xFFFFAF7B)], 'clouds'),
  // Neon
  BgTheme('Neon', 'Pink neon', [Color(0xFFEE0979), Color(0xFF3F0D5E)], 'bokeh'),
  BgTheme('Neon', 'Electric', [Color(0xFF00F5D4), Color(0xFF7B2FF7)], 'bokeh'),
  BgTheme('Neon', 'Night club', [Color(0xFF12002F), Color(0xFFFC466B)], 'bokeh'),
  // Islamic
  BgTheme('Islamic', 'Emerald', [Color(0xFF004D40), Color(0xFF00897B)], 'islamic'),
  BgTheme('Islamic', 'Royal blue', [Color(0xFF0B1F4B), Color(0xFF1F4E9C)], 'islamic'),
  BgTheme('Islamic', 'Gold night', [Color(0xFF1A1200), Color(0xFF8A6D1F)], 'islamic'),
  // Comic / kids
  BgTheme('Comic', 'Pop art', [Color(0xFFFFE600), Color(0xFFFF9F1C)], 'dots'),
  BgTheme('Comic', 'Burst', [Color(0xFFFF2D4F), Color(0xFFFFE600)], 'rays'),
  BgTheme('Comic', 'Confetti', [Color(0xFF7B2FF7), Color(0xFFF107A3)], 'confetti'),
  // Food
  BgTheme('Food', 'Tomato', [Color(0xFFE52D27), Color(0xFFB31217)], 'dots'),
  BgTheme('Food', 'Cream', [Color(0xFFFFF3E0), Color(0xFFFFCC80)], 'confetti'),
  // Fitness & news
  BgTheme('Fitness', 'Power', [Color(0xFF000000), Color(0xFFE52D27)], 'stripes'),
  BgTheme('Fitness', 'Energy', [Color(0xFFF7971E), Color(0xFFFFD200)], 'stripes'),
  BgTheme('News', 'Breaking', [Color(0xFFB71C1C), Color(0xFF1A1A1A)], 'stripes'),
  BgTheme('News', 'Studio blue', [Color(0xFF0B3C8C), Color(0xFF021B4A)], 'rays'),
  // Plain dark / light
  BgTheme('Minimal', 'Charcoal', [Color(0xFF000000), Color(0xFF434343)]),
  BgTheme('Minimal', 'Soft white', [Color(0xFFFFFFFF), Color(0xFFB0BEC5)]),
];

final bgThemeNames = <String>['All', ...{for (final t in bgThemes) t.theme}];
