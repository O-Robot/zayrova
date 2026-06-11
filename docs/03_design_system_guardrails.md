# Design System Guardrails

## Main rule

Codex must not replace the current design system.

The project already has a design foundation through colours, themes, assets, reusable buttons, inputs, product cards, navigation components, and shared widgets.

Codex must improve and extend the current design system instead of deleting it or creating a separate one.

## Existing design system areas

The current app already includes:

- `ZayColors`
- `ZayTheme`
- asset constants
- reusable button widgets
- reusable input widgets
- product card component
- bottom navigation component
- banner carousel component
- top navigation component
- confirmation modal
- navigation dots
- profile image picker

These should be treated as the starting point.

## UI implementation rules

- Use existing colour constants where possible.
- Add new colours only inside the central colour file.
- Do not use random inline `Colors.red`, `Colors.blue`, etc. in screens unless there is no proper token yet.
- Do not hardcode repeated spacing everywhere.
- Add spacing constants if needed.
- Do not create one-off button styles in screens.
- Extend the existing button component instead.
- Do not create one-off input styles in screens.
- Extend the existing input component instead.
- Product cards should be reusable and data-driven.
- Layouts should be responsive across common mobile screen sizes.

## Design reference usage

### New design

Use `docs/new/` as the main design flow.

This design should guide:

- screen order
- checkout flow
- account flow
- notification flow
- order flow
- visual layout direction

### Old design

Use `docs/old/` only for:

- useful UI ideas
- auth references
- onboarding references
- any component that still feels stronger than the new design

## Premium quality bar

Zayrova should feel like a resale-ready e-commerce template.

The UI should be:

- clean
- modern
- premium
- consistent
- realistic
- conversion-focused
- easy to rebrand

## Rebrandability rule

Because Zayrova may be resold to different brands, avoid locking the UI too tightly to one niche.

The app should support:

- fashion
- lifestyle
- beauty
- accessories
- general retail

Use neutral naming in code where possible.

For example:

Use `Product`, `Category`, `Collection`, `Cart`, `Order`.

Avoid names that only make sense for clothing unless the field is genuinely clothing-specific.
