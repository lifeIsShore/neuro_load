# 7. About Section Lacking Region/Language Links

## Description
As a user viewing the About section, I want to see accurate, localized legal contracts (Terms of Service, Privacy Policy), so that I can read the rules applicable to my region.
**Problem Context:** Missing URLs for policy documents.

## Acceptance Criteria
- [ ] The About screen contains functional links to Privacy Policy and Terms of Use.
- [ ] The links direct the user to the correct URL based on their selected language (e.g., `/en/privacy` vs `/tr/privacy`).

## Resolution / Solution Method
- Create a configuration map of URLs mapped to supported locale codes.
- Use `url_launcher` to open the respective links.
- Add UI elements in the About screen for these links.
