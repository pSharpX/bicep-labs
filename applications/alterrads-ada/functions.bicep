
@export()
@description('Remove dashes from text')
func removeDash(text string) string => replace(text, '-', '')
