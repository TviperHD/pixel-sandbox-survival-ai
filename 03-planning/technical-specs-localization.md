# Technical Specifications: Localization/Translation System

**Date:** 2025-01-27  
**Status:** Planning  
**Version:** 1.0

## Overview

Technical specifications for the comprehensive localization/translation system, including Godot's built-in CSV-based translation system, support for 10 languages (English, Simplified Chinese, Japanese, Korean, German, French, Spanish, Portuguese (Brazilian), Russian, Italian), hybrid translation management (CSV + optional TMS integration), full runtime language switching, missing translation handling, text expansion management, font fallback, basic RTL support, number/date formatting, pluralization, gender forms, and context variables. All features are designed to be highly configurable, modular, and meet industry localization standards.

---

## Research Notes

### Godot Translation System Best Practices

**Research Findings:**
- Godot 4 uses CSV-based translation files (.csv)
- TranslationServer manages translations at runtime
- Translation files stored in `res://translations/` directory
- Supports pluralization and context variables
- Runtime language switching supported

**Sources:**
- [Godot 4 Internationalization Documentation](https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html) - Official i18n guide
- [Godot 4 TranslationServer Documentation](https://docs.godotengine.org/en/stable/classes/class_translationserver.html) - TranslationServer API

**Implementation Approach:**
- Use Godot's built-in TranslationServer
- CSV files for translation data
- Translation keys as message IDs
- Support for pluralization and context variables

**Why This Approach:**
- Native Godot solution (no dependencies)
- Well-documented and supported
- CSV format is easy to edit and version control
- Supports all required features

### Translation Management Best Practices

**Research Findings:**
- CSV files are standard for Godot and easy to edit
- Translation Management Systems (TMS) recommended for professional workflows
- TMS platforms provide translation memory, glossaries, collaboration
- Hybrid approach: CSV for simple workflows, TMS for professional workflows
- Export/import functionality syncs between CSV and TMS

**Sources:**
- [Circle Translations - Video Game Localization](https://circletranslations.com/blog/video-game-localization) - TMS usage
- [Game Developer - 9 Game Localization Best Practices](https://www.gamedeveloper.com/production/9-game-localization-best-practices) - Translation management

**Implementation Approach:**
- CSV files as base format (native Godot)
- Optional TMS integration (Crowdin, Lokalise, etc.)
- Export/import functions for TMS sync
- Translation memory support

**Why This Approach:**
- Flexible (CSV for simple, TMS for professional)
- Scalable (start with CSV, add TMS later)
- Industry standard (CSV common, TMS recommended)
- Best of both worlds

### Missing Translation Handling Best Practices

**Research Findings:**
- Fallback to source language (English) when translation missing
- Log warnings for missing translations (helps developers identify gaps)
- Optional debug markers ("[MISSING]") in debug builds
- Prevents blank fields or errors

**Sources:**
- [SimpleLocalize - Best Practices in Software Localization](https://simplelocalize.io/blog/posts/best-practices-in-software-localization/) - Missing translation handling
- [Locize - Missing Translations](https://locize.com/blog/missing-translations/) - Fallback strategies

**Implementation Approach:**
- Fallback to English (source language) as primary
- Log warnings for missing translation keys
- Optional "[MISSING]" prefix in debug builds
- Never show blank or error text

**Why This Approach:**
- Better UX (users see content, not errors)
- Developer-friendly (warnings help identify gaps)
- Industry standard (fallback + logging)
- Flexible (debug markers optional)

### Text Expansion Handling Best Practices

**Research Findings:**
- German text is typically 30-50% longer than English
- Russian text similar or slightly longer
- Chinese/Japanese often shorter
- Design UI for ~50% text expansion
- Dynamic sizing with maximum limits
- Ellipsis fallback for overflow

**Sources:**
- [MediumTalk - How to Manage Text Expansion](https://www.mediumtalk.net/how-to-manage-text-expansion-in-translation-localization-2025/) - Text expansion management
- [Game Developer - 9 Game Localization Best Practices](https://www.gamedeveloper.com/production/9-game-localization-best-practices) - Flexible UI design

**Implementation Approach:**
- Dynamic UI sizing based on text length
- Maximum size limits for UI elements
- Ellipsis truncation with tooltip for full text
- Design for 50% text expansion

**Why This Approach:**
- Flexible (accommodates different text lengths)
- Prevents overflow (maximum limits)
- Graceful degradation (ellipsis fallback)
- Industry standard (dynamic sizing with limits)

### Font Support Best Practices

**Research Findings:**
- Font fallback is standard approach
- Primary font for Latin, Cyrillic, common characters
- Fallback fonts for missing characters
- CJK fonts for Chinese, Japanese, Korean
- System fonts as final fallback

**Sources:**
- [Gridly - Game UI Design Localization Best Practices](https://www.gridly.com/blog/game-ui-design-localization-best-practices/) - Font handling
- [AllCorrect Games - Localization Guide](https://allcorrectgames.com/wp-content/uploads/2023/10/Localization_guide_2_allcorrect.pdf) - Font fallback mechanisms

**Implementation Approach:**
- Primary font for Latin/Cyrillic
- Font fallback chain for missing characters
- CJK fonts for Chinese/Japanese/Korean
- System fonts as final fallback

**Why This Approach:**
- Supports all languages without per-language fonts
- Uses system fonts when needed
- Consistent appearance where possible
- Industry standard

### RTL Language Support Best Practices

**Research Findings:**
- RTL languages (Arabic, Hebrew) require text direction changes
- UI mirroring needed for natural experience
- Not in top 10 languages but important for some markets
- Basic RTL support: text direction + UI mirroring
- Full layout mirroring can be deferred

**Sources:**
- [Gridly - Game UI Design Localization Best Practices](https://www.gridly.com/blog/game-ui-design-localization-best-practices/) - RTL support

**Implementation Approach:**
- Basic RTL support: text direction + basic UI mirroring
- Defer full layout mirroring until needed
- Design UI to be RTL-ready (flexible layouts)

**Why This Approach:**
- Supports RTL languages without full layout changes
- Can be expanded later if needed
- Industry practice (many games add RTL later)
- Pragmatic (focus on top 10 languages first)

### Number/Date Formatting Best Practices

**Research Findings:**
- Number formatting varies (decimal separator: . vs ,)
- Date formatting varies (MM/DD/YYYY vs DD/MM/YYYY)
- Time formatting varies (12-hour vs 24-hour)
- Currency formatting varies (symbol position, decimal places)
- System locale + per-language overrides recommended

**Sources:**
- General localization best practices for number/date formatting

**Implementation Approach:**
- Use system locale by default (respects user's OS settings)
- Per-language overrides for game-specific formatting
- Support for number, date, time, currency formatting

**Why This Approach:**
- Respects user preferences (system locale)
- Flexible (per-language overrides when needed)
- Industry standard (most games use this approach)

### Pluralization and Gender Forms Best Practices

**Research Findings:**
- Many languages have complex plural rules (English: 1 item/2 items, Russian: 1 предмет/2-4 предмета/5+ предметов)
- Some languages have gender-specific forms (Russian, Spanish, French)
- Context variables needed for dynamic text
- Translation context helps translators

**Sources:**
- General localization best practices for pluralization and gender forms

**Implementation Approach:**
- Plural forms per language
- Gender forms per language
- Context variables for dynamic text
- Translation context/comments for translators

**Why This Approach:**
- Supports complex language rules
- Enables accurate translations
- Industry standard for professional localization

---

## Data Structures

### SupportedLanguage (Enum)

```gdscript
enum SupportedLanguage {
	ENGLISH,              # en
	SIMPLIFIED_CHINESE,   # zh_CN
	JAPANESE,             # ja
	KOREAN,               # ko
	GERMAN,               # de
	FRENCH,               # fr
	SPANISH,              # es
	PORTUGUESE_BR,        # pt_BR
	RUSSIAN,              # ru
	ITALIAN               # it
}
```

### LanguageInfo (Resource)

```gdscript
class_name LanguageInfo
extends Resource

@export var language_code: String  # ISO 639-1 code (e.g., "en", "zh_CN")
@export var language_name: String  # Display name (e.g., "English", "简体中文")
@export var native_name: String  # Native name (e.g., "English", "简体中文")
@export var is_rtl: bool = false  # Right-to-left language
@export var font_fallback: Array[String] = []  # Fallback fonts for this language
@export var plural_rules: Dictionary = {}  # Plural rules for this language
@export var number_format: Dictionary = {}  # Number formatting overrides
@export var date_format: Dictionary = {}  # Date formatting overrides
@export var time_format: Dictionary = {}  # Time formatting overrides
@export var currency_format: Dictionary = {}  # Currency formatting overrides
```

### TranslationKey (Resource)

```gdscript
class_name TranslationKey
extends Resource

@export var key: String  # Translation key (message ID)
@export var context: String = ""  # Context for translators
@export var comments: String = ""  # Additional comments for translators
@export var has_plural: bool = false  # Has plural forms
@export var has_gender: bool = false  # Has gender forms
@export var variables: Array[String] = []  # Context variables used in translation
```

### TranslationSettings (Resource)

```gdscript
class_name TranslationSettings
extends Resource

# Current Language
@export var current_language: SupportedLanguage = SupportedLanguage.ENGLISH
@export var fallback_language: SupportedLanguage = SupportedLanguage.ENGLISH

# Missing Translation Handling
@export var fallback_to_english: bool = true
@export var log_missing_translations: bool = true
@export var show_missing_markers: bool = false  # Debug only
@export var missing_marker_prefix: String = "[MISSING]"

# Text Expansion
@export var max_text_expansion_factor: float = 1.5  # 50% expansion
@export var use_dynamic_sizing: bool = true
@export var use_ellipsis_fallback: bool = true

# Font Settings
@export var primary_font: Font
@export var fallback_fonts: Array[Font] = []
@export var cjk_fonts: Dictionary = {}  # language_code -> Font

# RTL Support
@export var rtl_support_enabled: bool = true
@export var rtl_ui_mirroring: bool = true

# Number/Date Formatting
@export var use_system_locale: bool = true
@export var per_language_formatting: Dictionary = {}  # language_code -> formatting overrides

# Translation Management
@export var tms_enabled: bool = false
@export var tms_provider: String = ""  # "crowdin", "lokalise", etc.
@export var tms_project_id: String = ""
@export var tms_api_key: String = ""
```

### PluralRule (Resource)

```gdscript
class_name PluralRule
extends Resource

@export var language_code: String
@export var rule_type: PluralRuleType
@export var forms: Array[String] = []  # Plural forms (e.g., ["item", "items"])

enum PluralRuleType {
	SIMPLE,      # English: 1 item, 2+ items
	COMPLEX,     # Russian: 1 предмет, 2-4 предмета, 5+ предметов
	CUSTOM       # Custom rule
}

# For complex rules
@export var ranges: Array[Dictionary] = []  # [{min: 1, max: 1, form: 0}, {min: 2, max: 4, form: 1}, ...]
```

### GenderForm (Resource)

```gdscript
class_name GenderForm
extends Resource

@export var language_code: String
@export var gender_forms: Dictionary = {}  # gender -> translation_key
# Example: {"male": "player_male", "female": "player_female", "neutral": "player"}
```

### FormattingOverride (Resource)

```gdscript
class_name FormattingOverride
extends Resource

@export var language_code: String
@export var number_decimal_separator: String = "."
@export var number_thousands_separator: String = ","
@export var date_format: String = "MM/DD/YYYY"  # Format string
@export var time_format: String = "24h"  # "12h" or "24h"
@export var currency_symbol: String = "$"
@export var currency_position: CurrencyPosition = CurrencyPosition.BEFORE
@export var currency_decimal_places: int = 2

enum CurrencyPosition {
	BEFORE,  # $100
	AFTER    # 100$
}
```

---

## Core Classes

### LocalizationManager (Autoload Singleton)

```gdscript
class_name LocalizationManager
extends Node

# Settings
var translation_settings: TranslationSettings
var language_info: Dictionary = {}  # language_code -> LanguageInfo
var plural_rules: Dictionary = {}  # language_code -> PluralRule
var gender_forms: Dictionary = {}  # language_code -> GenderForm
var formatting_overrides: Dictionary = {}  # language_code -> FormattingOverride

# Components
var translation_server: TranslationServer
var font_manager: FontManager
var rtl_handler: RTLHandler
var formatting_handler: FormattingHandler
var tms_integration: TMSIntegration

# Signals
signal language_changed(new_language: SupportedLanguage)
signal translation_missing(key: String, language: String)
signal translation_loaded(language: String)

# Initialization
func _ready() -> void
func load_translation_settings() -> void
func save_translation_settings() -> void
func initialize_languages() -> void

# Language Management
func set_language(language: SupportedLanguage) -> void
func get_current_language() -> SupportedLanguage
func get_language_code() -> String
func get_language_name() -> String
func get_native_language_name() -> String
func get_available_languages() -> Array[SupportedLanguage]
func is_language_available(language: SupportedLanguage) -> bool

# Translation
func translate(key: String, context: Dictionary = {}) -> String
func translate_plural(key: String, count: int, context: Dictionary = {}) -> String
func translate_gender(key: String, gender: String, context: Dictionary = {}) -> String
func translate_with_variables(key: String, variables: Dictionary, context: Dictionary = {}) -> String
func has_translation(key: String) -> bool

# Missing Translation Handling
func handle_missing_translation(key: String, language: String) -> String
func log_missing_translation(key: String, language: String) -> void

# Font Management
func get_font_for_language(language: SupportedLanguage) -> Font
func get_fallback_fonts() -> Array[Font]

# RTL Support
func is_rtl_language(language: SupportedLanguage) -> bool
func should_mirror_ui() -> bool

# Formatting
func format_number(number: float, language: SupportedLanguage = SupportedLanguage.ENGLISH) -> String
func format_date(date: Dictionary, language: SupportedLanguage = SupportedLanguage.ENGLISH) -> String
func format_time(hour: int, minute: int, language: SupportedLanguage = SupportedLanguage.ENGLISH) -> String
func format_currency(amount: float, currency_code: String, language: SupportedLanguage = SupportedLanguage.ENGLISH) -> String

# TMS Integration
func export_to_tms() -> void
func import_from_tms() -> void
func sync_with_tms() -> void
```

### FontManager

```gdscript
class_name FontManager
extends Node

var primary_font: Font
var fallback_fonts: Array[Font] = []
var cjk_fonts: Dictionary = {}  # language_code -> Font
var language_fonts: Dictionary = {}  # language_code -> Font

func _init(settings: TranslationSettings) -> void
func load_fonts() -> void
func get_font_for_language(language: SupportedLanguage) -> Font
func get_font_for_text(text: String, language: SupportedLanguage) -> Font
func has_character(font: Font, character: String) -> bool
func get_fallback_font_for_character(character: String, language: SupportedLanguage) -> Font
```

### RTLHandler

```gdscript
class_name RTLHandler
extends Node

var rtl_enabled: bool = true
var ui_mirroring_enabled: bool = true
var current_language: SupportedLanguage

func _init(settings: TranslationSettings) -> void
func is_rtl_language(language: SupportedLanguage) -> bool
func should_mirror_ui() -> bool
func apply_rtl_to_text(text: String) -> String
func mirror_ui_layout(ui_node: Control) -> void
func apply_text_direction(text_node: Label) -> void
```

### FormattingHandler

```gdscript
class_name FormattingHandler
extends Node

var use_system_locale: bool = true
var formatting_overrides: Dictionary = {}

func _init(settings: TranslationSettings) -> void
func format_number(number: float, language: SupportedLanguage) -> String
func format_date(date: Dictionary, language: SupportedLanguage) -> String
func format_time(hour: int, minute: int, language: SupportedLanguage) -> String
func format_currency(amount: float, currency_code: String, language: SupportedLanguage) -> String
func get_number_format(language: SupportedLanguage) -> Dictionary
func get_date_format(language: SupportedLanguage) -> Dictionary
func get_time_format(language: SupportedLanguage) -> Dictionary
func get_currency_format(language: SupportedLanguage) -> Dictionary
```

### TMSIntegration

```gdscript
class_name TMSIntegration
extends Node

var provider: String = ""  # "crowdin", "lokalise", etc.
var project_id: String = ""
var api_key: String = ""
var enabled: bool = false

func _init(settings: TranslationSettings) -> void
func export_to_tms() -> void
func import_from_tms() -> void
func sync_with_tms() -> void
func upload_translation_file(language: String, file_path: String) -> void
func download_translation_file(language: String, file_path: String) -> void
```

### TextExpansionHandler

```gdscript
class_name TextExpansionHandler
extends Node

var max_expansion_factor: float = 1.5
var use_dynamic_sizing: bool = true
var use_ellipsis_fallback: bool = true

func _init(settings: TranslationSettings) -> void
func calculate_text_size(text: String, base_size: Vector2, language: SupportedLanguage) -> Vector2
func apply_dynamic_sizing(ui_element: Control, text: String, language: SupportedLanguage) -> void
func apply_ellipsis(text_node: Label, max_width: float) -> void
func get_text_expansion_factor(language: SupportedLanguage) -> float
```

---

## System Architecture

### Component Hierarchy

```
LocalizationManager (Autoload Singleton)
├── TranslationServer (Godot built-in)
├── FontManager
│   ├── Primary Font
│   ├── Fallback Fonts
│   └── CJK Fonts
├── RTLHandler
│   └── UI Mirroring Logic
├── FormattingHandler
│   ├── Number Formatting
│   ├── Date Formatting
│   ├── Time Formatting
│   └── Currency Formatting
├── TextExpansionHandler
│   ├── Dynamic Sizing
│   └── Ellipsis Fallback
└── TMSIntegration (Optional)
    ├── Crowdin Integration
    ├── Lokalise Integration
    └── Export/Import Functions
```

### Data Flow

1. **Translation Load:**
   - `LocalizationManager.load_translation_settings()` → Loads settings
   - `TranslationServer.load_translations()` → Loads CSV translation files
   - `FontManager.load_fonts()` → Loads fonts for languages
   - `initialize_languages()` → Sets up language info

2. **Language Switch:**
   - User changes language in UI
   - `LocalizationManager.set_language()` → Updates TranslationServer
   - Signal emitted: `language_changed`
   - All UI elements update via signals
   - Fonts updated via `FontManager`
   - RTL applied via `RTLHandler`

3. **Translation Lookup:**
   - Code calls `LocalizationManager.translate()`
   - TranslationServer looks up translation
   - If missing, fallback to English + log warning
   - Variables substituted
   - Plural/gender forms applied if needed
   - Text returned

### Integration Points

- **UI System:** All UI text uses `LocalizationManager.translate()`, responds to `language_changed` signal
- **Dialogue System:** Dialogue text translated, speaker names translated
- **Quest System:** Quest names, descriptions, objectives translated
- **Item Database:** Item names, descriptions translated
- **Settings Menu:** Language selection UI, formatting options
- **Save System:** Current language saved/loaded
- **Audio System:** Subtitles translated (handled by SubtitleManager)

---

## Algorithms

### Translate with Variables

```gdscript
func translate_with_variables(key: String, variables: Dictionary, context: Dictionary = {}) -> String:
	var translation = translate(key, context)
	
	# Substitute variables
	for var_name in variables:
		var placeholder = "{" + var_name + "}"
		var value = str(variables[var_name])
		translation = translation.replace(placeholder, value)
	
	return translation
```

### Translate Plural

```gdscript
func translate_plural(key: String, count: int, context: Dictionary = {}) -> String:
	var language = get_current_language()
	var language_code = get_language_code()
	
	# Get plural rule for language
	if not plural_rules.has(language_code):
		# Fallback to simple plural (English)
		if count == 1:
			return translate(key + "_singular", context)
		else:
			return translate(key + "_plural", context)
	
	var rule = plural_rules[language_code]
	
	# Determine plural form based on count
	var form_index = 0
	match rule.rule_type:
		PluralRule.PluralRuleType.SIMPLE:
			form_index = 0 if count == 1 else 1
		PluralRule.PluralRuleType.COMPLEX:
			# Check ranges
			for range_data in rule.ranges:
				if count >= range_data.min and count <= range_data.max:
					form_index = range_data.form
					break
		PluralRule.PluralRuleType.CUSTOM:
			# Custom logic
			form_index = calculate_custom_plural_form(count, rule)
	
	# Get translation key for this form
	var plural_key = key + "_" + str(form_index)
	return translate(plural_key, context)
```

### Format Number

```gdscript
func format_number(number: float, language: SupportedLanguage = SupportedLanguage.ENGLISH) -> String:
	var language_code = get_language_code_for_enum(language)
	var format = formatting_handler.get_number_format(language)
	
	# Format number with separators
	var formatted = str(number)
	
	# Apply decimal separator
	if format.has("decimal_separator"):
		formatted = formatted.replace(".", format.decimal_separator)
	
	# Apply thousands separator
	if format.has("thousands_separator"):
		# Add thousands separators (simplified)
		var parts = formatted.split(format.decimal_separator)
		var integer_part = parts[0]
		var decimal_part = parts[1] if parts.size() > 1 else ""
		
		# Add thousands separators
		var separated = ""
		var count = 0
		for i in range(integer_part.length() - 1, -1, -1):
			if count > 0 and count % 3 == 0:
				separated = format.thousands_separator + separated
			separated = integer_part[i] + separated
			count += 1
		
		formatted = separated
		if decimal_part != "":
			formatted += format.decimal_separator + decimal_part
	
	return formatted
```

### Handle Missing Translation

```gdscript
func handle_missing_translation(key: String, language: String) -> String:
	# Log warning
	if translation_settings.log_missing_translations:
		log_missing_translation(key, language)
	
	# Fallback to English
	if translation_settings.fallback_to_english:
		var english_translation = TranslationServer.translate(key, "en")
		if english_translation != key:  # Translation found
			return english_translation
	
	# Show marker in debug builds
	if translation_settings.show_missing_markers:
		return translation_settings.missing_marker_prefix + key
	
	# Return key as last resort
	return key
```

### Apply Dynamic Sizing

```gdscript
func apply_dynamic_sizing(ui_element: Control, text: String, language: SupportedLanguage) -> void:
	if not translation_settings.use_dynamic_sizing:
		return
	
	# Calculate text expansion factor
	var expansion_factor = text_expansion_handler.get_text_expansion_factor(language)
	
	# Calculate new size
	var base_size = ui_element.size
	var new_width = base_size.x * expansion_factor
	var new_height = base_size.y * expansion_factor
	
	# Apply maximum limits
	var max_width = base_size.x * translation_settings.max_text_expansion_factor
	var max_height = base_size.y * translation_settings.max_text_expansion_factor
	
	new_width = min(new_width, max_width)
	new_height = min(new_height, max_height)
	
	# Update UI element size
	ui_element.custom_minimum_size = Vector2(new_width, new_height)
	
	# If text still doesn't fit, apply ellipsis
	if translation_settings.use_ellipsis_fallback:
		if ui_element is Label:
			var label = ui_element as Label
			if label.get_theme_font("font").get_string_size(text).x > new_width:
				text_expansion_handler.apply_ellipsis(label, new_width)
```

---

## Integration Points

### UI System Integration

- **All UI Text:** Uses `LocalizationManager.translate()` for all text
- **Language Change:** UI elements listen to `language_changed` signal and update
- **Text Sizing:** UI elements use `TextExpansionHandler` for dynamic sizing
- **RTL Support:** UI elements use `RTLHandler` for RTL layout

### Dialogue System Integration

- **Dialogue Text:** Translated via `LocalizationManager.translate()`
- **Speaker Names:** Translated via `LocalizationManager.translate()`
- **Variables:** Dialogue variables substituted via `translate_with_variables()`

### Quest System Integration

- **Quest Names:** Translated via `LocalizationManager.translate()`
- **Quest Descriptions:** Translated via `LocalizationManager.translate()`
- **Objectives:** Translated via `LocalizationManager.translate()`

### Item Database Integration

- **Item Names:** Translated via `LocalizationManager.translate()`
- **Item Descriptions:** Translated via `LocalizationManager.translate()`
- **Item Categories:** Translated via `LocalizationManager.translate()`

### Settings Menu Integration

- **Language Selection:** UI for selecting language, calls `LocalizationManager.set_language()`
- **Formatting Options:** UI for number/date formatting preferences

### Save System Integration

- **Current Language:** Saved/loaded with game data
- **Translation Settings:** Saved/loaded with user settings

---

## Save/Load System

### Localization Save Data

```gdscript
var localization_save_data = {
	"current_language": SupportedLanguage.ENGLISH,
	"fallback_language": SupportedLanguage.ENGLISH,
	"translation_settings": {
		"fallback_to_english": true,
		"log_missing_translations": true,
		"show_missing_markers": false,
		"use_dynamic_sizing": true,
		"use_ellipsis_fallback": true,
		"rtl_support_enabled": true,
		"use_system_locale": true
	}
}
```

### Save/Load Functions

```gdscript
func save_translation_settings() -> void:
	var save_data = {
		"current_language": current_language,
		"fallback_language": translation_settings.fallback_language,
		"translation_settings": serialize_translation_settings()
	}
	
	var config = ConfigFile.new()
	config.set_value("localization", "settings", save_data)
	config.save("user://localization_settings.cfg")

func load_translation_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://localization_settings.cfg")
	if err != OK:
		# Use default settings
		translation_settings = TranslationSettings.new()
		return
	
	var save_data = config.get_value("localization", "settings", {})
	if save_data.has("current_language"):
		set_language(save_data.current_language)
	if save_data.has("translation_settings"):
		deserialize_translation_settings(save_data.translation_settings)
```

---

## Performance Considerations

### Optimization Strategies

1. **Translation Caching:**
   - Cache frequently used translations
   - Cache formatted numbers/dates
   - Cache font lookups

2. **Lazy Loading:**
   - Load translation files on demand
   - Load fonts on demand
   - Load language info on demand

3. **Batch Updates:**
   - Batch UI updates on language change
   - Batch font updates
   - Batch RTL layout updates

4. **Conditional Processing:**
   - Skip RTL processing for LTR languages
   - Skip formatting overrides when using system locale
   - Skip TMS sync when TMS disabled

5. **Memory Management:**
   - Unload unused translation files
   - Unload unused fonts
   - Clean up cached translations

---

## Testing Checklist

### Translation System
- [ ] All translation files load correctly
- [ ] All languages are available
- [ ] Language switching works correctly
- [ ] Missing translations handled correctly (fallback to English)
- [ ] Missing translation warnings logged
- [ ] Translation keys are consistent

### Pluralization
- [ ] Plural forms work correctly for all languages
- [ ] Complex plural rules work (Russian, etc.)
- [ ] Plural forms match language rules

### Gender Forms
- [ ] Gender forms work correctly
- [ ] Gender selection works
- [ ] Gender forms match language rules

### Context Variables
- [ ] Variable substitution works correctly
- [ ] Variables formatted correctly
- [ ] Missing variables handled correctly

### Text Expansion
- [ ] Dynamic sizing works correctly
- [ ] Maximum limits enforced
- [ ] Ellipsis fallback works
- [ ] Text doesn't overflow UI

### Font Support
- [ ] Primary font loads correctly
- [ ] Fallback fonts work correctly
- [ ] CJK fonts load correctly
- [ ] Font fallback chain works

### RTL Support
- [ ] RTL text direction works
- [ ] UI mirroring works
- [ ] RTL languages display correctly

### Number/Date Formatting
- [ ] Number formatting works correctly
- [ ] Date formatting works correctly
- [ ] Time formatting works correctly
- [ ] Currency formatting works correctly
- [ ] System locale respected
- [ ] Per-language overrides work

### TMS Integration
- [ ] TMS export works
- [ ] TMS import works
- [ ] TMS sync works
- [ ] CSV files compatible with TMS

### Integration
- [ ] UI System integrates correctly
- [ ] Dialogue System integrates correctly
- [ ] Quest System integrates correctly
- [ ] Item Database integrates correctly
- [ ] Settings Menu integrates correctly
- [ ] Save System integrates correctly

---

## Error Handling

### Default Values

```gdscript
# Default language if loading fails
var default_language = SupportedLanguage.ENGLISH

# Default translation settings
var default_translation_settings = TranslationSettings.new()
default_translation_settings.current_language = SupportedLanguage.ENGLISH
default_translation_settings.fallback_language = SupportedLanguage.ENGLISH
default_translation_settings.fallback_to_english = true
default_translation_settings.log_missing_translations = true
```

### Error Handling Functions

```gdscript
func handle_translation_error(error_message: String, key: String) -> String:
	push_error("Localization Error: " + error_message + " (Key: " + key + ")")
	
	# Fallback to English
	if translation_settings.fallback_to_english:
		var english_translation = TranslationServer.translate(key, "en")
		if english_translation != key:
			return english_translation
	
	# Return key as last resort
	return key

func validate_translation_file(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		push_error("Translation file not found: " + file_path)
		return false
	
	# Validate CSV format
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open translation file: " + file_path)
		return false
	
	# Check CSV header
	var header = file.get_csv_line()
	if header.size() < 2:
		push_error("Invalid translation file format: " + file_path)
		file.close()
		return false
	
	file.close()
	return true
```

---

## Default Values and Configuration

### Default Translation Files

**Location:** `res://translations/`

**Files:**
- `translations.csv` (base translation file with all keys)
- `en.csv` (English translations)
- `zh_CN.csv` (Simplified Chinese translations)
- `ja.csv` (Japanese translations)
- `ko.csv` (Korean translations)
- `de.csv` (German translations)
- `fr.csv` (French translations)
- `es.csv` (Spanish translations)
- `pt_BR.csv` (Portuguese (Brazilian) translations)
- `ru.csv` (Russian translations)
- `it.csv` (Italian translations)

### CSV File Format

```csv
keys,en,zh_CN,ja,ko,de,fr,es,pt_BR,ru,it
ui.menu.new_game,New Game,新游戏,新しいゲーム,새 게임,Neues Spiel,Nouvelle Partie,Nuevo Juego,Novo Jogo,Новая игра,Nuovo Gioco
ui.menu.load_game,Load Game,加载游戏,ゲームを読み込む,게임 불러오기,Spiel laden,Charger une partie,Cargar Juego,Carregar Jogo,Загрузить игру,Carica Gioco
```

### Language Configuration Files

**Location:** `res://resources/localization/languages/`

**Files:**
- `language_info.tres` (LanguageInfo resources)
- `plural_rules.tres` (PluralRule resources)
- `gender_forms.tres` (GenderForm resources)
- `formatting_overrides.tres` (FormattingOverride resources)

---

## Complete Implementation

### LocalizationManager Implementation

```gdscript
extends Node

var translation_settings: TranslationSettings
var language_info: Dictionary = {}
var plural_rules: Dictionary = {}
var gender_forms: Dictionary = {}
var formatting_overrides: Dictionary = {}

var translation_server: TranslationServer
var font_manager: FontManager
var rtl_handler: RTLHandler
var formatting_handler: FormattingHandler
var text_expansion_handler: TextExpansionHandler
var tms_integration: TMSIntegration

signal language_changed(new_language: SupportedLanguage)
signal translation_missing(key: String, language: String)
signal translation_loaded(language: String)

func _ready() -> void:
	# Initialize TranslationServer
	translation_server = TranslationServer
	
	# Initialize settings
	translation_settings = TranslationSettings.new()
	load_translation_settings()
	
	# Initialize components
	font_manager = FontManager.new(translation_settings)
	rtl_handler = RTLHandler.new(translation_settings)
	formatting_handler = FormattingHandler.new(translation_settings)
	text_expansion_handler = TextExpansionHandler.new(translation_settings)
	
	if translation_settings.tms_enabled:
		tms_integration = TMSIntegration.new(translation_settings)
	
	add_child(font_manager)
	add_child(rtl_handler)
	add_child(formatting_handler)
	add_child(text_expansion_handler)
	if tms_integration:
		add_child(tms_integration)
	
	# Initialize languages
	initialize_languages()
	
	# Load translations
	load_translations()

func set_language(language: SupportedLanguage) -> void:
	translation_settings.current_language = language
	var language_code = get_language_code_for_enum(language)
	
	# Update TranslationServer
	translation_server.set_locale(language_code)
	
	# Update components
	rtl_handler.current_language = language
	font_manager.current_language = language
	
	# Emit signal
	language_changed.emit(language)
	
	# Save settings
	save_translation_settings()

func translate(key: String, context: Dictionary = {}) -> String:
	var language_code = get_language_code()
	var translation = translation_server.translate(key, language_code)
	
	# Check if translation found
	if translation == key:
		# Translation missing
		translation = handle_missing_translation(key, language_code)
	
	return translation

func translate_with_variables(key: String, variables: Dictionary, context: Dictionary = {}) -> String:
	var translation = translate(key, context)
	
	# Substitute variables
	for var_name in variables:
		var placeholder = "{" + var_name + "}"
		var value = str(variables[var_name])
		translation = translation.replace(placeholder, value)
	
	return translation

func translate_plural(key: String, count: int, context: Dictionary = {}) -> String:
	var language_code = get_language_code()
	
	# Get plural rule for language
	if not plural_rules.has(language_code):
		# Fallback to simple plural (English)
		if count == 1:
			return translate(key + "_singular", context)
		else:
			return translate(key + "_plural", context)
	
	var rule = plural_rules[language_code]
	
	# Determine plural form based on count
	var form_index = 0
	match rule.rule_type:
		PluralRule.PluralRuleType.SIMPLE:
			form_index = 0 if count == 1 else 1
		PluralRule.PluralRuleType.COMPLEX:
			# Check ranges
			for range_data in rule.ranges:
				if count >= range_data.min and count <= range_data.max:
					form_index = range_data.form
					break
	
	# Get translation key for this form
	var plural_key = key + "_" + str(form_index)
	return translate(plural_key, context)

func format_number(number: float, language: SupportedLanguage = SupportedLanguage.ENGLISH) -> String:
	return formatting_handler.format_number(number, language)

func format_date(date: Dictionary, language: SupportedLanguage = SupportedLanguage.ENGLISH) -> String:
	return formatting_handler.format_date(date, language)

func format_time(hour: int, minute: int, language: SupportedLanguage = SupportedLanguage.ENGLISH) -> String:
	return formatting_handler.format_time(hour, minute, language)

func format_currency(amount: float, currency_code: String, language: SupportedLanguage = SupportedLanguage.ENGLISH) -> String:
	return formatting_handler.format_currency(amount, currency_code, language)

func handle_missing_translation(key: String, language: String) -> String:
	# Log warning
	if translation_settings.log_missing_translations:
		log_missing_translation(key, language)
	
	# Fallback to English
	if translation_settings.fallback_to_english:
		var english_translation = translation_server.translate(key, "en")
		if english_translation != key:
			return english_translation
	
	# Show marker in debug builds
	if translation_settings.show_missing_markers:
		return translation_settings.missing_marker_prefix + key
	
	# Return key as last resort
	return key

func log_missing_translation(key: String, language: String) -> void:
	push_warning("Missing translation: Key='" + key + "', Language='" + language + "'")
	translation_missing.emit(key, language)
```

---

## Setup Instructions

### 1. Create LocalizationManager Autoload

1. Create `LocalizationManager` script
2. Add to Autoload in Project Settings
3. Set as singleton

### 2. Create Translation Files

1. Create `res://translations/` directory
2. Create CSV files for each language:
   - `en.csv` (English)
   - `zh_CN.csv` (Simplified Chinese)
   - `ja.csv` (Japanese)
   - `ko.csv` (Korean)
   - `de.csv` (German)
   - `fr.csv` (French)
   - `es.csv` (Spanish)
   - `pt_BR.csv` (Portuguese (Brazilian))
   - `ru.csv` (Russian)
   - `it.csv` (Italian)

3. Format CSV files with header: `keys,en,zh_CN,ja,ko,de,fr,es,pt_BR,ru,it`

### 3. Create Language Resources

1. Create `res://resources/localization/languages/` directory
2. Create `LanguageInfo` resources for each language
3. Create `PluralRule` resources for languages with complex plural rules
4. Create `GenderForm` resources for languages with gender forms
5. Create `FormattingOverride` resources for languages needing formatting overrides

### 4. Integrate with UI System

1. Replace all hardcoded text with `LocalizationManager.translate()` calls
2. Connect UI elements to `language_changed` signal
3. Use `TextExpansionHandler` for dynamic text sizing
4. Use `RTLHandler` for RTL language support

### 5. Integrate with Other Systems

1. **Dialogue System:** Use `translate()` for dialogue text
2. **Quest System:** Use `translate()` for quest names/descriptions
3. **Item Database:** Use `translate()` for item names/descriptions
4. **Settings Menu:** Add language selection UI

### 6. Optional: Set Up TMS Integration

1. Configure TMS provider (Crowdin, Lokalise, etc.)
2. Set up API keys and project IDs
3. Enable TMS integration in settings
4. Use export/import functions to sync translations

---

## Tools and Resources

### Godot Features Used

- **TranslationServer:** Godot's built-in translation system
- **CSV Files:** Translation file format
- **Resource System:** Language configuration resources
- **ConfigFile:** Settings persistence

### External Tools (Optional)

- **Translation Management Systems:**
  - [Crowdin](https://crowdin.com/) - TMS platform
  - [Lokalise](https://lokalise.com/) - TMS platform
  - [Phrase](https://phrase.com/) - TMS platform

- **Font Resources:**
  - [Noto Fonts](https://fonts.google.com/noto) - Multilingual font family
  - [Source Han Sans](https://github.com/adobe-fonts/source-han-sans) - CJK fonts

### References

- [Godot 4 Internationalization Documentation](https://docs.godotengine.org/en/stable/tutorials/i18n/internationalizing_games.html) - Official i18n guide
- [Godot 4 TranslationServer Documentation](https://docs.godotengine.org/en/stable/classes/class_translationserver.html) - TranslationServer API
- [Game Developer - 9 Game Localization Best Practices](https://www.gamedeveloper.com/production/9-game-localization-best-practices) - Localization best practices
- [Circle Translations - Video Game Localization](https://circletranslations.com/blog/video-game-localization) - Professional localization guide
- [IGDA Best Practices for Game Localization](https://igda-website.s3.us-east-2.amazonaws.com/wp-content/uploads/2021/04/09142137/Best-Practices-for-Game-Localization-v22.pdf) - Comprehensive localization guide

---

## Editor Support

### Translation File Editor

- CSV files can be edited in any spreadsheet application
- Godot's built-in CSV editor (basic)
- Optional: Custom editor plugin for translation management

### Translation Key Validation

- Validate translation keys exist in all languages
- Check for missing translations
- Validate CSV format

### Translation Context

- Add context/comments to translation keys
- Provide screenshots/references for translators
- Maintain translation glossary

---

## Implementation Notes

### Modularity

- Each component (FontManager, RTLHandler, etc.) is separate
- Components can be enabled/disabled independently
- TMS integration is optional

### Configurability

- All settings exposed as resources (editable in editor)
- Settings can be changed at runtime
- Per-language configuration supported

### Performance

- Translation caching for frequently used strings
- Lazy loading of translation files
- Batch updates on language change

### Extensibility

- Easy to add new languages (add CSV file + LanguageInfo)
- Easy to add new formatting rules
- Easy to add new TMS providers

---

