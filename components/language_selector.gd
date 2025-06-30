# ------------------------------------------------
# Class Name: LanguageSelector
# Class Description:
# ------------------------------------------------
class_name LanguageSelector extends OptionButton

func _ready() -> void:
	for locale in TranslationServer.get_loaded_locales():
		self.add_item(TranslationServer.get_locale_name(locale))
	self.item_selected.connect(func(idx):
		TranslationServer.set_locale(TranslationServer.get_loaded_locales()[idx])
	)
