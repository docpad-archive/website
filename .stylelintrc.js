// 2017 April 14
// https://github.com/bevry/base
// https://stylelint.io/user-guide/rules/
module.exports = {
  "extends": "stylelint-config-standard",
  "rules": {
		"indentation": "tab",
		"rule-empty-line-before": null,
		"custom-property-empty-line-before": null,
		"at-rule-empty-line-before": null,
		"declaration-empty-line-before": null,
		"max-empty-lines": 2,
		"selector-list-comma-newline-after": null
	},
	"ignoreFiles": ["**/vendor/*.css"]
}