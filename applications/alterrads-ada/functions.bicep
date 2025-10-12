
@export()
@description('Remove dashes from text')
func removeDash(text string) string => replace(text, '-', '')

@export()
@description('Replace underscore from text with dash')
func replaceUnderscore(text string) string => replace(text, '_', '-')

@export()
@description('Replace dash from text with underscore')
func replaceDash(text string) string => replace(text, '-', '_')
