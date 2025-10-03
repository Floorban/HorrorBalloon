extends Control

@onready var prompt_label: Label = %PromptLabel
@onready var icon_rect: TextureRect = %IconRect

func init_data(data: InteractionUIData) -> void:
	if data.icon: icon_rect.texture = data.icon
	prompt_label.text = data.prompt
