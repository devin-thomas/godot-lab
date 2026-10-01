extends Resource
## A deliberately small original resource format. No imported scripts are accepted.
@export var schema_version: int = 1
@export var stable_id: String = "harbor-lantern"
@export var display_name: String = "Harbor lantern"
@export var charge: int = 3
@export var surface: GradientTexture2D

func validated() -> bool:
	return schema_version == 1 and stable_id == "harbor-lantern" and charge >= 0 and charge <= 9 and not display_name.is_empty() and display_name.length() <= 40 and surface != null
